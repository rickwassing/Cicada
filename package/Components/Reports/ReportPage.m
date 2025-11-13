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
                'RowHeight', {180, 140, 180, 180}, ...
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
            app_addlisteners([], Obj.PatientInfoTable, {'eDatasetChanged'});
            % ---------------------------------------------------------
            % Recording Information Table
            Obj.RecordingInfoTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.RecordingInfoTable.Layout.Row = 2;
            Obj.RecordingInfoTable.Layout.Column = 1;
            Obj.RecordingInfoTable.Title = 'Recording Information';
            Obj.RecordingInfoTable.TableConfig = Obj.hGetRecordingInfoConfig();
            app_addlisteners([], Obj.RecordingInfoTable, {'eDatasetChanged'});
            % ---------------------------------------------------------
            % Summary Statistics - Entire Recording Table
            Obj.SummaryStatsTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.SummaryStatsTable.Layout.Row = 3;
            Obj.SummaryStatsTable.Layout.Column = 1;
            Obj.SummaryStatsTable.Title = 'Summary Statistics - Entire Recording';
            Obj.SummaryStatsTable.TableConfig = Obj.hGetSummaryStatsConfig();
            app_addlisteners([], Obj.SummaryStatsTable, {'eDatasetChanged'});
            % ---------------------------------------------------------
            % Summary Statistics - Sleep Windows Table
            Obj.SleepWindowStatsTable = ReportTable(Obj.BodyGridLayout, 'Verbose', Obj.Verbose);
            Obj.SleepWindowStatsTable.Layout.Row = 4;
            Obj.SleepWindowStatsTable.Layout.Column = 1;
            Obj.SleepWindowStatsTable.Title = 'Summary Statistics - Average Sleep Windows';
            Obj.SleepWindowStatsTable.TableConfig = Obj.hGetSleepWindowStatsConfig();
            app_addlisteners([], Obj.SleepWindowStatsTable, {'eDatasetChanged'});
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
                % Handle dataset changes and populate tables
                if ~isempty(app) && isfield(app, 'ACT') && ~isempty(app.ACT)
                    Obj.PatientInfoTable.hPopulateFromData(app.ACT);
                    Obj.RecordingInfoTable.hPopulateFromData(app.ACT);
                    Obj.SummaryStatsTable.hPopulateFromData(app.ACT);
                    Obj.SleepWindowStatsTable.hPopulateFromData(app.ACT);
                end
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
            % Configuration for Patient Information table (3 rows x 4 cols)
            config = struct();
            config.type = 'keyvalue';
            config.columns = 4;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'type', 'label', 'text', 'Name', 'field', '', 'editable', false)
                struct('row', 1, 'col', 2, 'type', 'value', 'text', '', 'field', 'info.participant_id', 'editable', true, 'format', 'string')
                struct('row', 1, 'col', 3, 'type', 'label', 'text', 'Date of Birth', 'field', '', 'editable', false)
                struct('row', 1, 'col', 4, 'type', 'value', 'text', '', 'field', 'info.dob', 'editable', true, 'format', 'date')
                % Row 2
                struct('row', 2, 'col', 1, 'type', 'label', 'text', 'Patient ID', 'field', '', 'editable', false)
                struct('row', 2, 'col', 2, 'type', 'value', 'text', '', 'field', 'info.participant_id', 'editable', false, 'format', 'string')
                struct('row', 2, 'col', 3, 'type', 'label', 'text', 'Sex', 'field', '', 'editable', false)
                struct('row', 2, 'col', 4, 'type', 'value', 'text', '', 'field', 'info.sex', 'editable', true, 'format', 'string')
                % Row 3
                struct('row', 3, 'col', 1, 'type', 'label', 'text', 'Referring Physician', 'field', '', 'editable', false)
                struct('row', 3, 'col', 2, 'type', 'value', 'text', '', 'field', 'info.researcher', 'editable', true, 'format', 'string')
                struct('row', 3, 'col', 3, 'type', 'label', 'text', 'Study Date', 'field', '', 'editable', false)
                struct('row', 3, 'col', 4, 'type', 'value', 'text', '', 'field', 'info.study', 'editable', false, 'format', 'string')
            };
        end
        % =================================================================
        function config = hGetRecordingInfoConfig(~)
            % Configuration for Recording Information table (4 rows x 4 cols)
            config = struct();
            config.type = 'keyvalue';
            config.columns = 4;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'type', 'label', 'text', 'Device', 'field', '', 'editable', false)
                struct('row', 1, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.device_type', 'editable', false, 'format', 'string')
                struct('row', 1, 'col', 3, 'type', 'label', 'text', 'Serial Number', 'field', '', 'editable', false)
                struct('row', 1, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.serial_number', 'editable', false, 'format', 'string')
                % Row 2
                struct('row', 2, 'col', 1, 'type', 'label', 'text', 'Start Date/Time', 'field', '', 'editable', false)
                struct('row', 2, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.start_datetime', 'editable', false, 'format', 'string')
                struct('row', 2, 'col', 3, 'type', 'label', 'text', 'End Date/Time', 'field', '', 'editable', false)
                struct('row', 2, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.end_datetime', 'editable', false, 'format', 'string')
                % Row 3
                struct('row', 3, 'col', 1, 'type', 'label', 'text', 'Duration', 'field', '', 'editable', false)
                struct('row', 3, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.duration', 'editable', false, 'format', 'string')
                struct('row', 3, 'col', 3, 'type', 'label', 'text', 'Sampling Rate', 'field', '', 'editable', false)
                struct('row', 3, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.sampling_rate', 'editable', false, 'format', 'string')
                % Row 4
                struct('row', 4, 'col', 1, 'type', 'label', 'text', 'Epoch Length', 'field', '', 'editable', false)
                struct('row', 4, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.epoch_length', 'editable', false, 'format', 'string')
                struct('row', 4, 'col', 3, 'type', 'label', 'text', 'Total Epochs', 'field', '', 'editable', false)
                struct('row', 4, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.total_epochs', 'editable', false, 'format', 'string')
            };
        end
        % =================================================================
        function config = hGetSummaryStatsConfig(~)
            % Configuration for Summary Statistics table (5 rows x 4 cols)
            config = struct();
            config.type = 'keyvalue';
            config.columns = 4;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'type', 'label', 'text', 'Number of Days', 'field', '', 'editable', false)
                struct('row', 1, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.num_days', 'editable', false, 'format', 'number')
                struct('row', 1, 'col', 3, 'type', 'label', 'text', 'Time Rejected (%)', 'field', '', 'editable', false)
                struct('row', 1, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.time_rejected_pct', 'editable', false, 'format', 'number')
                % Row 2
                struct('row', 2, 'col', 1, 'type', 'label', 'text', 'Inter-daily Stability (IS)', 'field', '', 'editable', false)
                struct('row', 2, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.interdaily_stability', 'editable', false, 'format', 'number')
                struct('row', 2, 'col', 3, 'type', 'label', 'text', 'Intra-daily Variability (IV)', 'field', '', 'editable', false)
                struct('row', 2, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.intradaily_variability', 'editable', false, 'format', 'number')
                % Row 3
                struct('row', 3, 'col', 1, 'type', 'label', 'text', 'Time in MVA (hours)', 'field', '', 'editable', false)
                struct('row', 3, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.mva_time', 'editable', false, 'format', 'number')
                struct('row', 3, 'col', 3, 'type', 'label', 'text', 'Mean EN in MVA', 'field', '', 'editable', false)
                struct('row', 3, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.mva_mean_en', 'editable', false, 'format', 'number')
                % Row 4
                struct('row', 4, 'col', 1, 'type', 'label', 'text', 'Most Active 10h Start', 'field', '', 'editable', false)
                struct('row', 4, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.m10_start', 'editable', false, 'format', 'string')
                struct('row', 4, 'col', 3, 'type', 'label', 'text', 'Most Active 10h Amplitude', 'field', '', 'editable', false)
                struct('row', 4, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.m10_amplitude', 'editable', false, 'format', 'number')
                % Row 5
                struct('row', 5, 'col', 1, 'type', 'label', 'text', 'Least Active 5h Start', 'field', '', 'editable', false)
                struct('row', 5, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.l5_start', 'editable', false, 'format', 'string')
                struct('row', 5, 'col', 3, 'type', 'label', 'text', 'Least Active 5h Amplitude', 'field', '', 'editable', false)
                struct('row', 5, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.l5_amplitude', 'editable', false, 'format', 'number')
            };
        end
        % =================================================================
        function config = hGetSleepWindowStatsConfig(~)
            % Configuration for Sleep Window Statistics table (5 rows x 4 cols)
            config = struct();
            config.type = 'keyvalue';
            config.columns = 4;
            config.cells = {
                % Row 1
                struct('row', 1, 'col', 1, 'type', 'label', 'text', 'Number of Sleep Windows', 'field', '', 'editable', false)
                struct('row', 1, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.num_sleep_windows', 'editable', false, 'format', 'number')
                struct('row', 1, 'col', 3, 'type', 'label', 'text', 'Lights Out Time', 'field', '', 'editable', false)
                struct('row', 1, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.lights_out_time', 'editable', false, 'format', 'string')
                % Row 2
                struct('row', 2, 'col', 1, 'type', 'label', 'text', 'Sleep Onset Latency (min)', 'field', '', 'editable', false)
                struct('row', 2, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.sleep_onset_latency', 'editable', false, 'format', 'number')
                struct('row', 2, 'col', 3, 'type', 'label', 'text', 'WASO (min)', 'field', '', 'editable', false)
                struct('row', 2, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.waso', 'editable', false, 'format', 'number')
                % Row 3
                struct('row', 3, 'col', 1, 'type', 'label', 'text', 'Final Awakening Time', 'field', '', 'editable', false)
                struct('row', 3, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.final_awakening', 'editable', false, 'format', 'string')
                struct('row', 3, 'col', 3, 'type', 'label', 'text', 'Lights On Time', 'field', '', 'editable', false)
                struct('row', 3, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.lights_on_time', 'editable', false, 'format', 'string')
                % Row 4
                struct('row', 4, 'col', 1, 'type', 'label', 'text', 'Sleep Window Duration (hours)', 'field', '', 'editable', false)
                struct('row', 4, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.sleep_window_duration', 'editable', false, 'format', 'number')
                struct('row', 4, 'col', 3, 'type', 'label', 'text', 'Total Time in Sustained Inactivity (hours)', 'field', '', 'editable', false)
                struct('row', 4, 'col', 4, 'type', 'value', 'text', '', 'field', 'stats.sustained_inactivity', 'editable', false, 'format', 'number')
                % Row 5
                struct('row', 5, 'col', 1, 'type', 'label', 'text', 'Sleep Efficiency (%)', 'field', '', 'editable', false)
                struct('row', 5, 'col', 2, 'type', 'value', 'text', '', 'field', 'stats.sleep_efficiency', 'editable', false, 'format', 'number')
                struct('row', 5, 'col', 3, 'type', 'label', 'text', '', 'field', '', 'editable', false)
                struct('row', 5, 'col', 4, 'type', 'value', 'text', '', 'field', '', 'editable', false, 'format', 'string')
            };
        end
    end
end
