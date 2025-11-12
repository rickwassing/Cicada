% EXPORTBUTTON
% Button component to export reports as PDF

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-06, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ExportButton < handle
    % *********************************************************************
    % PROPERTIES
    properties
        % ParentApp;  % Reference to the reports app for callbacks
        Verbose = false;
        TargetTag
        EventFlag = '';
        Parent
        Graphics matlab.ui.control.Button
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        % Constructor
        function Obj = ExportButton(Parent, varargin)
            % -------------------------------------------------------------
            % Set parent
            Obj.Parent = Parent;
            Text = 'EXPORT PDF';
            % -------------------------------------------------------------
            % Set other parameters using name-value pairs
            if nargin > 1
                for i = 1:2:length(varargin)
                    switch lower(varargin{i})
                        case 'verbose'
                            Obj.Verbose = varargin{i+1};
                        case 'text'
                            Text = upper(varargin{i+1});
                        case 'targettag'
                            Obj.TargetTag = varargin{i+1};
                    end
                end
            end
            % -------------------------------------------------------------
            % Create the button
            Colors = app_colors();
            Obj.Graphics = uibutton(Parent, 'push');
            Obj.Graphics.ButtonPushedFcn = @(src, event) Obj.onExportButtonPushed(src, event);
            Obj.Graphics.BackgroundColor = Colors.cic_indigo;
            Obj.Graphics.FontSize = 10;
            Obj.Graphics.FontWeight = 'bold';
            Obj.Graphics.FontColor = [1, 1, 1];
            Obj.Graphics.Text = Text;
        end
        % =================================================================
        % Helper functions
        % -----------------------------------------------------------------
        % Creates a new UIFigure with the same dimensions as a A4 paper
        function fig = createA4Figure(~)
            fig = uifigure('Visible', 'on', ...
                'Units', 'centimeters', ...
                'Position', [0.5, 0.5, 21, 29.7]);
            drawnow; pause(0.1);
            fig.Units = 'pixels';
            drawnow; pause(0.1);
        end

        % -----------------------------------------------------------------
        % Used to copy the grid layout of the original component
        function copyLayoutInfo(~, src, dst)
            try
                if isprop(src, 'Layout') && isprop(dst, 'Layout') && ~isempty(src.Layout)
                    % Some components have Layout objects with Row/Column properties
                    try dst.Layout.Row = src.Layout.Row; end %#ok<TRYNC>
                    try dst.Layout.Column = src.Layout.Column; end %#ok<TRYNC>
                    try dst.Layout.RowSpan = src.Layout.RowSpan; end %#ok<TRYNC>
                    try dst.Layout.ColumnSpan = src.Layout.ColumnSpan; end %#ok<TRYNC>
                end
            catch
                % ignore
            end
        end

        % -----------------------------------------------------------------
        % Copy writable properties from source to destination
        function copyProps(~, src, dst)
            pList = properties(src);
            if isa(src.Parent, 'matlab.ui.container.GridLayout')
                skip = {'Children', 'Parent', 'Position', 'InnerPosition', 'OuterPosition'};
            else
                skip = {'Children', 'Parent'};
            end
            for i = 1:numel(pList)
                prop = pList{i};
                if any(strcmp(prop, skip))
                    continue
                end
                if isprop(dst, prop)
                    try
                        val = src.(prop);
                        % Avoid copying handles to objects belonging to the source figure
                        % (e.g. callbacks or Parent handles). Best-effort attempt.
                        dst.(prop) = val;
                    catch
                        % ignore read-only or incompatible props
                    end
                end
            end
        end

        % -----------------------------------------------------------------
        % Recursively copy children from srcParent into dstParent
        function syncUIProperties(Obj, srcParent, dstParent)
            % Rules:
            % - If child is a ComponentContainer subclass -> call deepCopy(dstParent)
            % - Else if child has children (container) -> create new empty container in dstParent and recurse
            % - Else (leaf control) -> copyobj(child, dstParent)
            srcChildren = srcParent.GridLayout.Children; % this preserves on-screen ordering
            for k = 1:numel(srcChildren)
                srcChild = srcChildren(k);
                if isa(srcChild, 'DataPanelPool')
                    continue
                end
                if isa(srcChild, 'CicadaComponentContainer')
                    % Custom component: use its deepCopy(parent) contract
                    try
                        newChild = srcChild.deepCopy(dstParent);
                    catch ME
                        printwarningmessage(ME)
                        % fallback: create an instance and copy public props
                        newChild = feval(class(srcChild), 'Parent', dstParent);
                        Obj.copyProps(srcChild, newChild);
                        if ismethod(newChild, 'update'); newChild.update(); end
                    end

                elseif isprop(srcChild, 'Children') && ~isempty(srcChild.Children)
                    % Standard container (has children) -> create new container and recurse
                    newChild = feval(class(srcChild), 'Parent', dstParent);
                    Obj.copyProps(srcChild, newChild);
                    % Copy layout hints (if present)
                    Obj.copyLayoutInfo(srcChild, newChild);
                    % Recurse into children
                    syncUIProperties(Obj, srcChild, newChild);

                else
                    % Leaf standard control: safe to use copyobj
                    try
                        newChild = copyobj(srcChild, dstParent);
                    catch
                        % If copyobj fails for some reason, fallback to constructing
                        % same class with parent and copying props.
                        newChild = feval(class(srcChild), 'Parent', dstParent);
                        Obj.copyProps(srcChild, newChild);
                    end
                    % Force reload of resource-based properties (images, etc.)
                    try
                        if isprop(srcChild, 'ImageSource') && isprop(newChild, 'ImageSource')
                            newChild.ImageSource = srcChild.ImageSource;
                        end
                        if isprop(srcChild, 'LogoSource') && isprop(newChild, 'LogoSource')
                            newChild.LogoSource = srcChild.LogoSource;
                        end
                    catch
                        % ignore
                    end

                    % preserve layout hints
                    Obj.copyLayoutInfo(srcChild, newChild);
                end

                % Some components need a redraw to settle (do it per-child cheaply)
                drawnow();
            end
        end

        % -----------------------------------------------------------------
        % Method to export the panel (and its contents) to PDF
        function ExportToPdf(Obj, app, fullfilepath)

            % Get a handle to the target panel to print
            switch Obj.TargetTag
                case 'DataTab'
                    srcPanel = app.Cmps.MainTabGroup.TabGroup.Children(1).UserData.DataTab;
                case 'ReportTab'
                    srcPanel = app.Cmps.MainTabGroup.TabGroup.Children(2).UserData.ReportTab;
                otherwise
                    Obj.TargetTag
                    return
            end

            % Create a new A4-sized figure
            TmpFig = Obj.createA4Figure();

            % Create a fresh top-level container of the same class in TmpFig
            newPanel = srcPanel.deepCopy(TmpFig);
            newPanel.Units = 'normalized';
            newPanel.Position = [0, 0, 1, 1];

            drawnow(); pause(0.1);

            % Create temporary output for each page in the PDF and we merge them later
            TmpFile = getuuid();
            TmpPath = fullfile(app.Props.Path, 'Temp');
            if exist(TmpPath, 'dir') ~= 7
                mkdir(TmpPath);
            end

            switch Obj.TargetTag
                case 'DataTab'
                    N = floor(newPanel.ActogramLength);
                    AddEmpty = N - mod(newPanel.NumPanels, N);
                    newPanel.PanelHeight = ((TmpFig.Position(4) - (N-1)*18 - 36) / N);
                    drawnow();
                    newPanel.GridLayout.RowHeight = [newPanel.GridLayout.RowHeight, repmat(newPanel.GridLayout.RowHeight(1), 1, AddEmpty)];
                    TmpPanel = uipanel(newPanel.GridLayout); 
                    TmpPanel.Layout.Row = length(newPanel.GridLayout.RowHeight);
                    newPanel.GridLayout.Padding = [18, 18, 18, 18];
                    newPanel.GridLayout.RowSpacing = 18;
                    for page = 1:N:length(newPanel.GridLayout.RowHeight)
                        scroll(newPanel.GridLayout, [0, -(page-1)*(newPanel.PanelHeight+18)])
                        drawnow(); pause(0.2);
                        exportapp(TmpFig, fullfile(TmpPath, sprintf('%s-%i.pdf', TmpFile, page)));
                    end
                case 'ReportTab'
                    newPanel.GridLayout.Padding = 0;
                    exportapp(TmpFig, fullfile(TmpPath, sprintf('%s-%i.pdf', TmpFile, 1)));
            end

            % Get the list of temp files
            TmpFiles = dir(fullfile(TmpPath, sprintf('%s-*.pdf', TmpFile)));
            TmpFiles = arrayfun(@(d) fullfile(d.folder, d.name), TmpFiles, 'UniformOutput', false);
            % Merge them together
            mergepdfs(TmpFiles, fullfilepath)
            % Delete temp files.
            delete(fullfile(TmpPath, sprintf('%s-*.pdf', TmpFile)))

            % Delete temp figure
            delete(TmpFig);
        end

        % -----------------------------------------------------------------
        % Open the PDF in a native app
        function openPDF(~, fullfilepath)
            if ispc
                winopen(fullfilepath);
            elseif ismac
                system(['open "', fullfilepath, '"']);
            else
                system(['xdg-open "', fullfilepath, '"']);
            end
        end
        % =================================================================
        % Event calls
        function onExportButtonPushed(Obj, src, ~)
            try
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Disable the button immediately
                src.Enable = 'off';
                drawnow();
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Ask the user where to save it
                app = app_gethandle();
                % [Filename, Path] = app.putfile({'*.pdf'});
                % if Filename == 0
                %     src.Enable = 'on';
                %     return % user pressed cancel
                % end
                Path = '/Users/rickwassing';
                Filename = 'cicadatest.pdf';
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Show waitbar
                progdlg = uiprogressdlg(app.UIFigure, ...
                    'Title', 'The Cicada is buzzing, please wait...',...
                    'Indeterminate','on');
                drawnow();
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Now we can generate and save it
                Obj.ExportToPdf(app, fullfile(Path, Filename));
                close(progdlg)
                drawnow();
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Done, ask the user to confirm or open the PDF
                selection = uiconfirm(app.UIFigure, ...
                    'PDF Exported!', 'Good, that went surprisingly well!', ...
                    'Icon' , 'success', ...
                    'Options', {'Open PDF', 'OK'});
                switch selection
                    case 'Open PDF'
                        Obj.openPDF(fullfile(Path, Filename))
                end
            catch ME
                % Only close progress dialog if it exists and is still valid
                if exist('progdlg', 'var') && isvalid(progdlg)
                    close(progdlg);
                end                
                getReport(ME)
            end
            src.Enable = 'on';
        end
    end
end
