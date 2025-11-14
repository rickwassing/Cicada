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
        % Table components
        PatientInfoTable ReportTable
        RecordingInfoTable ReportTable
        SummaryStatsTable ReportTable
        SleepWindowStatsTable ReportTable
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
                'RowHeight', {...
                    getpanelheight('georgia', 14, 0, 3, 20, 0), ... % fontName, fontSize, padding, numRows, rowHeight, rowSpacing
                    getpanelheight('georgia', 14, 0, 4, 20, 0), ...
                    getpanelheight('georgia', 14, 0, 5, 20, 0), ...
                    getpanelheight('georgia', 14, 0, 5, 20, 0), ...
                    }, ...
                'RowSpacing', 12, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Create table components
            % -------------------------------------------------------------
            % Patient Information Table
            Obj.PatientInfoTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.PatientInfoTable.Layout.Row = 1;
            Obj.PatientInfoTable.Layout.Column = 1;
            Obj.PatientInfoTable.Title = 'Patient Information';
            Obj.PatientInfoTable.TableConfig = Obj.hGetPatientInfoConfig();
            app_addlisteners([], Obj.PatientInfoTable, {'eStyleChanged', 'eDatasetChanged'});
            % ---------------------------------------------------------
            % Recording Information Table
            Obj.RecordingInfoTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.RecordingInfoTable.Layout.Row = 2;
            Obj.RecordingInfoTable.Layout.Column = 1;
            Obj.RecordingInfoTable.Title = 'Recording Information';
            Obj.RecordingInfoTable.TableConfig = Obj.hGetRecordingInfoConfig();
            app_addlisteners([], Obj.RecordingInfoTable, {'eStyleChanged', 'eDatasetChanged', 'eDataChanged'});
            % ---------------------------------------------------------
            % Summary Statistics - Entire Recording Table
            Obj.SummaryStatsTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.SummaryStatsTable.Layout.Row = 3;
            Obj.SummaryStatsTable.Layout.Column = 1;
            Obj.SummaryStatsTable.Title = 'Summary Statistics - Entire Recording';
            Obj.SummaryStatsTable.TableConfig = Obj.hGetSummaryStatsConfig();
            app_addlisteners([], Obj.SummaryStatsTable, {'eStyleChanged', 'eDatasetChanged', 'eDataChanged'});
            % ---------------------------------------------------------
            % Summary Statistics - Sleep Windows Table
            Obj.SleepWindowStatsTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.SleepWindowStatsTable.Layout.Row = 4;
            Obj.SleepWindowStatsTable.Layout.Column = 1;
            Obj.SleepWindowStatsTable.Title = 'Summary Statistics - Average Sleep Windows';
            Obj.SleepWindowStatsTable.TableConfig = Obj.hGetSleepWindowStatsConfig();
            app_addlisteners([], Obj.SleepWindowStatsTable, {'eStyleChanged', 'eDatasetChanged', 'eDataChanged'});
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
                % Get app handle
                app = app_gethandle();
                % ---------------------------------------------------------
                % Initialize the components
                Obj.HeaderLeftPanel.hInit(app);
                Obj.HeaderRightPanel.hInit(app);
                Obj.FooterPanel.PageNum = Obj.PageNum;
                Obj.FooterPanel.hInit(app);
                % Initialize tables with styling
                Obj.PatientInfoTable.hInit(app);
                Obj.RecordingInfoTable.hInit(app);
                Obj.SummaryStatsTable.hInit(app);
                Obj.SleepWindowStatsTable.hInit(app);
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
                style = app.Props.Settings.Report.style.title;
                Obj.BodyGridLayout.RowHeight = {...
                    getpanelheight(style.fontFamily, style.fontSize, 0, 3, 20, 0), ... % fontName, fontSize, padding, numRows, rowHeight, rowSpacing
                    getpanelheight(style.fontFamily, style.fontSize, 0, 4, 20, 0), ...
                    getpanelheight(style.fontFamily, style.fontSize, 0, 5, 20, 0), ...
                    getpanelheight(style.fontFamily, style.fontSize, 0, 5, 20, 0), ...
                    };
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportPage.m')
            end
        end
    end
    % *********************************************************************
    % PRIVATE METHODS - TABLE CONFIGURATIONS
    methods (Access = private)
        % =================================================================
        function config = hGetPatientInfoConfig(~)
            % Configuration for Patient Information table (3 rows x 2 cols)
            config = struct();
            config.columns = 2;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'keyLabel', 'Patient Name', 'text', '', 'field', 'info.participant_id', 'editable', true, 'format', 'string')
                struct('row', 1, 'col', 2, 'keyLabel', 'Date of Birth', 'text', '', 'field', 'info.dob', 'editable', true, 'format', 'date')
                % Row 2
                struct('row', 2, 'col', 1, 'keyLabel', 'Patient ID', 'text', '', 'field', 'info.participant_id', 'editable', true, 'format', 'string')
                struct('row', 2, 'col', 2, 'keyLabel', 'Sex', 'text', '', 'field', 'info.sex', 'editable', true, 'format', 'string')
                % Row 3
                struct('row', 3, 'col', 1, 'keyLabel', 'Referring Physician', 'text', '', 'field', 'info.researcher', 'editable', true, 'format', 'string')
                struct('row', 3, 'col', 2, 'keyLabel', 'Study', 'text', '', 'field', 'info.study', 'editable', false, 'format', 'string')
            };
        end
        % =================================================================
        function config = hGetRecordingInfoConfig(~)
            % Configuration for Recording Information table (4 rows x 2 cols)
            config = struct();
            config.columns = 2;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'keyLabel', 'Device', 'text', '', 'field', 'info.devices(1).name', 'editable', false, 'format', 'string')
                struct('row', 1, 'col', 2, 'keyLabel', 'Serial Number', 'text', '', 'field', 'info.devices(1).serial', 'editable', false, 'format', 'string')
                % Row 2
                struct('row', 2, 'col', 1, 'keyLabel', 'Start Date/Time', 'text', '', 'field', 'xmin', 'editable', false, 'format', 'datetime')
                struct('row', 2, 'col', 2, 'keyLabel', 'End Date/Time', 'text', '', 'field', 'xmax', 'editable', false, 'format', 'datetime')
                % Row 3
                struct('row', 3, 'col', 1, 'keyLabel', 'Duration', 'text', '', 'field', '<duration>', 'editable', false, 'format', 'string')
                struct('row', 3, 'col', 2, 'keyLabel', 'Location', 'text', '', 'field', 'data(1).loc', 'editable', false, 'format', 'string')
                % Row 4
                struct('row', 4, 'col', 1, 'keyLabel', 'Sampling Rate', 'text', '', 'field', 'data(1).srate', 'editable', false, 'format', '%.0f Hz')
                struct('row', 4, 'col', 2, 'keyLabel', 'Epoch Length', 'text', '', 'field', 'epoch', 'editable', false, 'format', '%i s')
            };
        end
        % =================================================================
        function config = hGetSummaryStatsConfig(~)
            % Configuration for Summary Statistics table (5 rows x 2 cols)
            config = struct();
            config.columns = 2;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'keyLabel', 'Number of Days', 'text', '', 'field', 'stats.num_days', 'editable', false, 'format', 'number')
                struct('row', 1, 'col', 2, 'keyLabel', 'Time Rejected', 'text', '', 'field', 'stats.time_rejected_pct', 'editable', false, 'format', 'number')
                % Row 2
                struct('row', 2, 'col', 1, 'keyLabel', 'Inter-daily Stability', 'text', '', 'field', 'stats.interdaily_stability', 'editable', false, 'format', 'number')
                struct('row', 2, 'col', 2, 'keyLabel', 'Intra-daily Variability', 'text', '', 'field', 'stats.intradaily_variability', 'editable', false, 'format', 'number')
                % Row 3
                struct('row', 3, 'col', 1, 'keyLabel', 'Time in MVA', 'text', '', 'field', 'stats.mva_time', 'editable', false, 'format', 'number')
                struct('row', 3, 'col', 2, 'keyLabel', 'Mean ENMO in MVA', 'text', '', 'field', 'stats.mva_mean_en', 'editable', false, 'format', 'number')
                % Row 4
                struct('row', 4, 'col', 1, 'keyLabel', 'Most Active 10h Start', 'text', '', 'field', 'stats.m10_start', 'editable', false, 'format', 'string')
                struct('row', 4, 'col', 2, 'keyLabel', 'Most Active 10h Amplitude', 'text', '', 'field', 'stats.m10_amplitude', 'editable', false, 'format', 'number')
                % Row 5
                struct('row', 5, 'col', 1, 'keyLabel', 'Least Active 5h Start', 'text', '', 'field', 'stats.l5_start', 'editable', false, 'format', 'string')
                struct('row', 5, 'col', 2, 'keyLabel', 'Least Active 5h Amplitude', 'text', '', 'field', 'stats.l5_amplitude', 'editable', false, 'format', 'number')
            };
        end
        % =================================================================
        function config = hGetSleepWindowStatsConfig(~)
            % Configuration for Sleep Window Statistics table (5 rows x 2 cols)
            config = struct();
            config.columns = 2;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'keyLabel', 'Number of Sleep Windows', 'text', '', 'field', 'stats.num_sleep_windows', 'editable', false, 'format', 'number')
                struct('row', 1, 'col', 2, 'keyLabel', 'Lights Out Time', 'text', '', 'field', 'stats.lights_out_time', 'editable', false, 'format', 'string')
                % Row 2
                struct('row', 2, 'col', 1, 'keyLabel', 'Sleep Onset Latency (min)', 'text', '', 'field', 'stats.sleep_onset_latency', 'editable', false, 'format', 'number')
                struct('row', 2, 'col', 2, 'keyLabel', 'WASO (min)', 'text', '', 'field', 'stats.waso', 'editable', false, 'format', 'number')
                % Row 3
                struct('row', 3, 'col', 1, 'keyLabel', 'Final Awakening Time', 'text', '', 'field', 'stats.final_awakening', 'editable', false, 'format', 'string')
                struct('row', 3, 'col', 2, 'keyLabel', 'Lights On Time', 'text', '', 'field', 'stats.lights_on_time', 'editable', false, 'format', 'string')
                % Row 4
                struct('row', 4, 'col', 1, 'keyLabel', 'Sleep Window Duration (hours)', 'text', '', 'field', 'stats.sleep_window_duration', 'editable', false, 'format', 'number')
                struct('row', 4, 'col', 2, 'keyLabel', 'Total Time in Sustained Inactivity (hours)', 'text', '', 'field', 'stats.sustained_inactivity', 'editable', false, 'format', 'number')
                % Row 5
                struct('row', 5, 'col', 1, 'keyLabel', 'Sleep Efficiency (%)', 'text', '', 'field', 'stats.sleep_efficiency', 'editable', false, 'format', 'number')
                struct('row', 5, 'col', 2, 'keyLabel', '', 'text', '', 'field', '', 'editable', false, 'format', 'string')
            };
        end
    end
end
