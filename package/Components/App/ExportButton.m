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
        % Get the target panel to export based on TargetTag
        function srcPanel = getTargetPanel(Obj, app)
            switch Obj.TargetTag
                case 'DataTab'
                    srcPanel = app.Cmps.MainTabGroup.TabGroup.Children(1).UserData.DataTab;
                case 'ReportTab'
                    srcPanel = app.Cmps.MainTabGroup.TabGroup.Children(2).UserData.ReportTab;
                otherwise
                    error('ExportButton:InvalidTargetTag', 'Invalid TargetTag: %s', Obj.TargetTag);
            end
        end

        % -----------------------------------------------------------------
        % Create and setup temporary directory for PDF export
        function TmpPath = prepareTempEnvironment(~, app)
            TmpPath = fullfile(app.Props.Path, 'Temp');
            if exist(TmpPath, 'dir') ~= 7
                mkdir(TmpPath);
            end
        end

        % -----------------------------------------------------------------
        % Create A4 figure with copied panel content
        function [TmpFig, newPanel] = createExportFigure(~, srcPanel)
            TmpFig = uifigure('Visible', 'off', ...
                'Units', 'centimeters', ...
                'Position', [0.5, 0.5, 21, 29.7]);
            drawnow; pause(0.1);
            TmpFig.Units = 'pixels';
            drawnow; pause(0.1);
            newPanel = srcPanel.deepCopy(TmpFig);
            newPanel.Units = 'normalized';
            newPanel.Position = [0, 0, 1, 1];
            drawnow(); pause(0.1);
        end

        % -----------------------------------------------------------------
        % Configure DataTab-specific layout for export
        function configureDataTabForExport(~, newPanel, figHeight)
            N = floor(newPanel.ActogramLength);
            AddEmpty = N - mod(newPanel.NumPanels, N);
            newPanel.PanelHeight = ((figHeight - (N-1)*18 - 36) / N);
            drawnow();
            newPanel.GridLayout.RowHeight = [...
                newPanel.GridLayout.RowHeight, ...
                repmat(newPanel.GridLayout.RowHeight(1), 1, AddEmpty)];
            TmpPanel = uipanel(newPanel.GridLayout); 
            TmpPanel.Layout.Row = length(newPanel.GridLayout.RowHeight);
            newPanel.GridLayout.Padding = [18, 18, 18, 18];
            newPanel.GridLayout.RowSpacing = 18;
        end

        % -----------------------------------------------------------------
        % Configure ReportTab-specific layout for export
        function configureReportTabForExport(~, newPanel)
            newPanel.GridLayout.Padding = 0;
            newPanel.GridLayout.RowSpacing = 0;
        end

        % -----------------------------------------------------------------
        % Export pages to individual PDF files
        function exportPages(Obj, TmpFig, newPanel, tempPath, tempFileId)
            switch Obj.TargetTag
                case 'DataTab'
                    N = floor(newPanel.ActogramLength);
                    for page = 1:N:length(newPanel.GridLayout.RowHeight)
                        scroll(newPanel.GridLayout, [0, -(page-1)*(newPanel.PanelHeight+18)])
                        drawnow(); pause(0.2);
                        exportapp(TmpFig, fullfile(tempPath, sprintf('%s-%i.pdf', tempFileId, page)));
                    end
                case 'ReportTab'
                    for page = 1:newPanel.NumPages
                        scroll(newPanel.GridLayout, [0, -(page-1)*(newPanel.PageHeight)])
                        drawnow(); pause(0.2);
                        exportapp(TmpFig, fullfile(tempPath, sprintf('%s-%i.pdf', tempFileId, page)));
                    end
            end
        end

        % -----------------------------------------------------------------
        % Merge individual PDFs and cleanup temporary files
        function mergeAndCleanup(~, tmpFig, tempPath, tempFileId, outputPath)
            % Get the list of temp files
            TmpFiles = dir(fullfile(tempPath, sprintf('%s-*.pdf', tempFileId)));
            TmpFiles = arrayfun(@(d) fullfile(d.folder, d.name), TmpFiles, 'UniformOutput', false);
            % Merge them together
            mergepdfs(TmpFiles, outputPath);
            % Delete temp files
            delete(fullfile(tempPath, sprintf('%s-*.pdf', tempFileId)));
            % Delete temp figure
            delete(tmpFig);
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

        % -----------------------------------------------------------------
        % Prompt user for save location
        function [success, filepath] = promptForSaveLocation(~, app)
            [Filename, Path] = app.putfile({'*.pdf'});
            if Filename == 0
                success = false;
                filepath = '';
            else
                success = true;
                filepath = fullfile(Path, Filename);
            end
        end

        % -----------------------------------------------------------------
        % Show export progress dialog
        function progdlg = showExportProgress(~, app)
            progdlg = uiprogressdlg(app.UIFigure, ...
                'Title', 'The Cicada is buzzing, please wait...', ...
                'Indeterminate', 'on');
            drawnow();
        end

        % -----------------------------------------------------------------
        % Hide export progress dialog safely
        function hideExportProgress(~, progdlg)
            if exist('progdlg', 'var') && isvalid(progdlg)
                close(progdlg);
            end
        end

        % -----------------------------------------------------------------
        % Show confirmation dialog and optionally open PDF
        function confirmAndOpenPdf(Obj, app, filepath)
            selection = uiconfirm(app.UIFigure, ...
                'PDF Exported!', 'Good, that went surprisingly well!', ...
                'Icon', 'success', ...
                'Options', {'Open PDF', 'OK'});
            if strcmp(selection, 'Open PDF')
                Obj.openPDF(filepath);
            end
        end

        % -----------------------------------------------------------------
        % Handle export errors
        function handleExportError(Obj, ME, progdlg)
            Obj.hideExportProgress(progdlg);
            getReport(ME);
        end

        % =================================================================
        % MAIN METHODS
        % -----------------------------------------------------------------
        % Main method to orchestrate PDF export process
        function onExportButtonPushed(Obj, src, ~)
            % Disable button to prevent multiple clicks
            src.Enable = 'off';
            drawnow();
            
            try
                % Get app handle
                app = app_gethandle();
                
                % Prompt for save location
                [success, fullfilepath] = Obj.promptForSaveLocation(app);
                if ~success
                    src.Enable = 'on';
                    return; % User cancelled
                end
                
                % Show progress
                progdlg = Obj.showExportProgress(app);
                
                % Get the target panel
                srcPanel = Obj.getTargetPanel(app);
                
                % Setup temp environment
                TmpPath = Obj.prepareTempEnvironment(app);
                TmpFile = getuuid();
                
                % Create export figure with panel content
                [TmpFig, newPanel] = Obj.createExportFigure(srcPanel);
                
                % Configure layout based on target type
                switch Obj.TargetTag
                    case 'DataTab'
                        Obj.configureDataTabForExport(newPanel, TmpFig.Position(4));
                    case 'ReportTab'
                        Obj.configureReportTabForExport(newPanel);
                end
                
                % Export pages
                Obj.exportPages(TmpFig, newPanel, TmpPath, TmpFile);
                
                % Merge and cleanup
                Obj.mergeAndCleanup(TmpFig, TmpPath, TmpFile, fullfilepath);

                
                % Hide progress
                Obj.hideExportProgress(progdlg);
                drawnow();
                
                % Show confirmation and offer to open
                Obj.confirmAndOpenPdf(app, fullfilepath);
                
            catch ME
                Obj.handleExportError(ME, progdlg);
            end
            
            % Re-enable button
            src.Enable = 'on';
        end
    end
end
