% REPORTPAGE
% A single page component for the report

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

classdef ReportPage < CicadaComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        PageNum = 1;
        HeaderHeight = 72;
        FooterHeight = 24;
        Margin = 36;  % Page margin in pixels
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        HeaderPanel matlab.ui.container.Panel
        HeaderGridLayout matlab.ui.container.GridLayout
        BodyPanel matlab.ui.container.Panel
        BodyGridLayout matlab.ui.container.GridLayout
        FooterPanelContainer matlab.ui.container.Panel
        FooterGridLayout matlab.ui.container.GridLayout
        % Sub-components
        HeaderLeftPanel PageHeaderLeftPanel
        HeaderRightPanel PageHeaderRightPanel
        FooterPanel PageFooterPanel
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            % Create the main panel (represents the page)
            Obj.Tag = 'ReportPage';
            Obj.Panel = uipanel(Obj, ...
                'Units', 'normalized', ...
                'BorderColor', [0.651, 0.651, 0.651], ...
                'HighlightColor', [0.651, 0.651, 0.651], ...
                'BorderType', 'none', ...
                'BackgroundColor', [1, 1, 1], ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            % Create the main grid layout (3 rows: header/body/footer)
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {Obj.HeaderHeight, '1x', Obj.FooterHeight}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [Obj.Margin, Obj.Margin, Obj.Margin, Obj.Margin], ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Create the header panel
            Obj.HeaderPanel = uipanel(Obj.GridLayout, ...
                'BorderColor', [1, 1, 1], ...
                'HighlightColor', [1, 1, 1], ...
                'BackgroundColor', [1, 1, 1]);
            Obj.HeaderPanel.Layout.Row = 1;
            Obj.HeaderPanel.Layout.Column = 1;
            
            Obj.HeaderGridLayout = uigridlayout(Obj.HeaderPanel, ...
                'ColumnWidth', {'2x', '1x'}, ...
                'RowHeight', {'1x'}, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Create left header panel
            Obj.HeaderLeftPanel = PageHeaderLeftPanel(Obj.HeaderGridLayout);
            Obj.HeaderLeftPanel.Layout.Row = 1;
            Obj.HeaderLeftPanel.Layout.Column = 1;
            % Add event listeners
            app_addlisteners([], Obj.HeaderLeftPanel, {'eStyleChanged', 'eLogoChanged', 'eContentChanged', 'eDatasetChanged'});
            % ---------------------------------------------------------
            % Create right header panel
            Obj.HeaderRightPanel = PageHeaderRightPanel(Obj.HeaderGridLayout);
            Obj.HeaderRightPanel.Layout.Row = 1;
            Obj.HeaderRightPanel.Layout.Column = 2;
            % Add event listeners
            app_addlisteners([], Obj.HeaderRightPanel, {'eStyleChanged', 'eContentChanged', 'eDatasetChanged'});
            % -------------------------------------------------------------
            % Create the body panel
            % -------------------------------------------------------------
            Obj.BodyPanel = uipanel(Obj.GridLayout, ...
                'BorderColor', [1, 1, 1], ...
                'HighlightColor', [1, 1, 1], ...
                'BackgroundColor', [1, 1, 1]);
            Obj.BodyPanel.Layout.Row = 2;
            Obj.BodyPanel.Layout.Column = 1;
            
            Obj.BodyGridLayout = uigridlayout(Obj.BodyPanel, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Create the footer panel container
            % -------------------------------------------------------------
            Obj.FooterPanel = PageFooterPanel(Obj.GridLayout);
            Obj.FooterPanel.Layout.Row = 3;
            Obj.FooterPanel.Layout.Column = 1;
            % Add event listeners
            app_addlisteners([], Obj.FooterPanel, {'eStyleChanged', 'eDatasetChanged'});
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                % Update panel tags with current page number
                Obj.Tag = sprintf('ReportPage_%i', Obj.PageNum);
                % ---------------------------------------------------------
                % Initialize the components
                Obj.HeaderLeftPanel.hInit();
                Obj.HeaderRightPanel.hInit();
                Obj.FooterPanel.PageNum = Obj.PageNum;
                Obj.FooterPanel.hInit();
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: ReportPage %i updated in %.1g s.\n', Obj.PageNum, (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ReportPage.m')
            end
        end
    end
    % *********************************************************************
    methods (Access = public)
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % ---------------------------------------------------------
                % Do nothing
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportPage.m')
            end
        end
    end
end
