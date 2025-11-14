% REPORTTAB
% The content of the tab that displays report pages

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-11, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ReportTab < CicadaComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        NumPages = 2;
        PageHeight = 842;  % A4 height at 72 DPI
        PageWidth = 595;   % A4 width at 72 DPI
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        Pages ReportPage
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Colors = app_colors();
            Obj.Tag = 'ReportTab';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'ReportTab_Panel', ...
                'Units', 'normalized', ...
                'BorderType', 'none', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'ReportTab_GridLayout', ...
                'ColumnWidth', {'1x', 595, '1x'}, ...
                'RowHeight', {842}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 24, ...
                'Padding', [0, 24, 0, 24], ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_secondary);
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                Obj.GridLayout.RowHeight = repmat({Obj.PageHeight}, 1, Obj.NumPages);
                for i = 1:Obj.NumPages
                    DoRender = false;
                    if i > length(Obj.Pages)
                        DoRender = true;
                    elseif ~isvalid(Obj.Pages(i))
                        DoRender = true;
                    end
                    if DoRender
                        Obj.Pages(i) = ReportPage(Obj.GridLayout);
                        % Add event listeners for each new page
                        app_addlisteners([], Obj.Pages(i), {'eDataChanged', 'eDatasetChanged', 'eStyleChanged'});
                    else
                        Obj.Pages(i).Parent = Obj.GridLayout;
                    end
                    Obj.Pages(i).PageNum = i;
                    Obj.Pages(i).Verbose = Obj.Verbose;
                    Obj.Pages(i).Layout.Column = 2;
                    Obj.Pages(i).Layout.Row = i;
                end
                for i = length(Obj.Pages):-1:Obj.NumPages+1
                    delete(Obj.Pages(i));
                    Obj.Pages(i) = [];
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: ReportTab updated ''%i'' pages in %.1g s.\n', Obj.NumPages, (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ReportTab.m')
            end
        end
    end
    % *********************************************************************
    methods (Access = public)
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % ---------------------------------------------------------
                % Do nothing
            catch ME %#ok<UNRCH>
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportTab.m')
            end
        end
    end
end
