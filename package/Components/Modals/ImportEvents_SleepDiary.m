% IMPORTEVENTS_SLEEPDIARY
% Import sleep diary events from plain text, csv, or excel file.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-11-01, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ImportEvents_SleepDiary < CicadaComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Size = [827, 286];
        Settings;
        FilePath;
        RawData = table();
        ParsedData = table();
        IsValid = false;
        Auth;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        TabGroup
        Tabs
        TabGridLayouts
        TabPanels
        TabLabels
        TabTables
        TabDropDowns
        TabInputs
        Buttons
        Placeholder
        FailIcon = uistyle('Icon', 'warning', 'IconAlignment', 'rightmargin');
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
            % -------------------------------------------------------------
            Obj.Tag = 'ImportEvents_SleepDiary';
            Obj.Panel = uipanel(Obj, ...
                'Title', 'IMPORT EVENTS FROM SLEEP DIARY', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'Tag', 'ImportEvents_SleepDiary_Panel', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'ImportEvents_SleepDiary_GridLayout', ...
                'ColumnWidth', {'1x', 96, 96, 96}, ...
                'RowHeight', {'1x', 22}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            Obj.TabGroup = uitabgroup(Obj.GridLayout);
            Obj.TabGroup.SelectionChangedFcn = @(source, event) set(Obj, 'IsValid', true);
            Obj.TabGroup.Layout.Column = [1, 4];
            % -------------------------------------------------------------
            Obj.Tabs(1).h = uitab(Obj.TabGroup, ...
                'Title', '(1) Import table');
            Obj.Tabs(2).h = uitab(Obj.TabGroup, ...
                'Title', '(2) Select variables');
            % -------------------------------------------------------------
            % Grid layout for first tab
            Obj.TabGridLayouts(1).h = uigridlayout(Obj.Tabs(1).h, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {48, '1x'}, ...
                'ColumnSpacing', 6, ...
                'RowSpacing', 6, ...
                'Padding', 6, ...
                'BackgroundColor', Colors.bg_grey);
            % -------------------------------------------------------------
            % Grid layout for second tab
            Obj.TabGridLayouts(2).h = uigridlayout(Obj.Tabs(2).h, ...
                'ColumnWidth', {284, '1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_grey);
            % -------------------------------------------------------------
            % Tab 1: Browse panel
            Obj.TabPanels(1).h = uipanel(Obj.TabGridLayouts(1).h, ...
                'Title', 'SELECT TABULAR DATA FILE', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_secondary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized');
            Obj.TabPanels(1).h.Layout.Row = 1;
            Obj.TabPanels(1).h.Layout.Column = 1;
            % -------------------------------------------------------------
            % Tab 1: Inspect raw data panel
            Obj.TabPanels(2).h = uipanel(Obj.TabGridLayouts(1).h, ...
                'Title', 'INSPECT RAW DATA', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_secondary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized');
            Obj.TabPanels(2).h.Layout.Row = 2;
            Obj.TabPanels(2).h.Layout.Column = 1;
            % -------------------------------------------------------------
            % Tab 2: Column index and formatting panel
            Obj.TabPanels(3).h = uipanel(Obj.TabGridLayouts(2).h, ...
                'Title', 'SELECT VARIABLES', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_secondary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Visible', 'off', ...
                'Units', 'normalized');
            Obj.TabPanels(3).h.Layout.Row = 1;
            Obj.TabPanels(3).h.Layout.Column = 1;
            % -------------------------------------------------------------
            % Tab 2: Inspect parsed data
            Obj.TabPanels(4).h = uipanel(Obj.TabGridLayouts(2).h, ...
                'Title', 'INSPECT PARSED DATA', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_secondary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Visible', 'off', ...
                'Units', 'normalized');
            Obj.TabPanels(4).h.Layout.Row = 1;
            Obj.TabPanels(4).h.Layout.Column = 2;
            % -------------------------------------------------------------
            % Tab 1: Browse panel layout
            Obj.TabGridLayouts(3).h = uigridlayout(Obj.TabPanels(1).h, ...
                'ColumnWidth', {64, '1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', 'w');
            % -------------------------------------------------------------
            % Tab 1: Inspect panel layout
            Obj.TabGridLayouts(4).h = uigridlayout(Obj.TabPanels(2).h, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', 'w');
            % -------------------------------------------------------------
            % Tab 2: Placeholder
            Obj.Placeholder = Placeholder(Obj.TabGridLayouts(2).h, ...
                'ImageSrc', 'no-data.png', ...
                'Header', 'No data.', ...
                'SubHeader', 'Import tabular data.', ...
                'Size', 95, ...
                'BackgroundColor', Colors.bg_primary); %#ok<CPROP>
            Obj.Placeholder.Layout.Row = 1;
            Obj.Placeholder.Layout.Column = [1, 2];
            % -------------------------------------------------------------
            % Tab 2: Column index and formatting panel layout
            Obj.TabGridLayouts(5).h = uigridlayout(Obj.TabPanels(3).h, ...
                'ColumnWidth', {70, 92, 108}, ...
                'RowHeight', {18, 20, 20, 20, 20, 20, 20, 20}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', 'w');
            % -------------------------------------------------------------
            % Tab 2: Inspect panel layout
            Obj.TabGridLayouts(6).h = uigridlayout(Obj.TabPanels(4).h, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {24, '1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', 'w');
            % -------------------------------------------------------------
            % Tab 1: Browse button
            Obj.Buttons.Browse = uibutton(Obj.TabGridLayouts(3).h, ...
                'Text', 'BROWSE', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_primary, ...
                'ButtonPushedFcn', @(source, event) Obj.browse(event));
            Obj.Buttons.Browse.Layout.Row = 1;
            Obj.Buttons.Browse.Layout.Column = 1;
            % -------------------------------------------------------------
            % Tab 1: File path label
            Obj.TabLabels(1).h = uilabel(Obj.TabGridLayouts(3).h, ...
                'Text', '', ...
                'FontSize', 10);
            Obj.TabLabels(1).h.Layout.Row = 1;
            Obj.TabLabels(1).h.Layout.Column = 2;
            % -------------------------------------------------------------
            % Tab 2: Select variable labels
            Obj.TabLabels(2).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Variable', ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'FontSize', 10);
            Obj.TabLabels(2).h.Layout.Row = 1;
            Obj.TabLabels(2).h.Layout.Column = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(3).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Format', ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'FontSize', 10);
            Obj.TabLabels(3).h.Layout.Row = 1;
            Obj.TabLabels(3).h.Layout.Column = 3;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(4).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Date*', ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', 'bold', ...
                'FontSize', 10);
            Obj.TabLabels(4).h.Layout.Row = 2;
            Obj.TabLabels(4).h.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(5).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Lights out*', ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', 'bold', ...
                'FontSize', 10);
            Obj.TabLabels(5).h.Layout.Row = 3;
            Obj.TabLabels(5).h.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(6).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Sleep latency', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.TabLabels(6).h.Layout.Row = 4;
            Obj.TabLabels(6).h.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(7).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', '# Awakenings', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.TabLabels(7).h.Layout.Row = 5;
            Obj.TabLabels(7).h.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(8).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'WASO', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.TabLabels(8).h.Layout.Row = 6;
            Obj.TabLabels(8).h.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(9).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Fin. Awakening', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.TabLabels(9).h.Layout.Row = 7;
            Obj.TabLabels(9).h.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.TabLabels(10).h = uilabel(Obj.TabGridLayouts(5).h, ...
                'Text', 'Lights on*', ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', 'bold', ...
                'FontSize', 10);
            Obj.TabLabels(10).h.Layout.Row = 8;
            Obj.TabLabels(10).h.Layout.Column = 1;
            % -------------------------------------------------------------
            Tags =  {'Date', 'LightsOut', 'SL', 'NumAwake', 'WASO', 'FinAwake', 'LightsOn'};
            for i = 1:7
                Obj.TabDropDowns(i).h = uidropdown(Obj.TabGridLayouts(5).h, ...
                    'Tag', Tags{i}, ...
                    'Items', {'x'}, ...
                    'Value', 'x', ...
                    'FontSize', 10, ...
                    'ValueChangedFcn', @(source, event) Obj.setImportSettings(event));
                Obj.TabDropDowns(i).h.Layout.Row = i+1;
                Obj.TabDropDowns(i).h.Layout.Column = 2;
            end
            % -------------------------------------------------------------
            for i = 1:7
                Obj.TabInputs(i).h = uieditfield(Obj.TabGridLayouts(5).h, 'text', ...
                    'Tag', Tags{i}, ...
                    'FontSize', 10, ...
                    'ValueChangedFcn', @(source, event) Obj.setImportSettings(event));
                if ismember(Tags{i}, {'SL', 'NumAwake', 'WASO'})
                    Obj.TabInputs(i).h.Editable = 'off';
                end
                Obj.TabInputs(i).h.Layout.Row = i+1;
                Obj.TabInputs(i).h.Layout.Column = 3;
            end
            % -------------------------------------------------------------
            % Tab 1: Tables
            Obj.TabTables(1).h = uitable(Obj.TabGridLayouts(4).h, ...
                'ColumnWidth', 'fit', ...
                'FontSize', 10, ...
                'Data', []);
            Obj.TabTables(1).h.Layout.Row = 1;
            Obj.TabTables(1).h.Layout.Column = 1;
            % -------------------------------------------------------------
            % Tab 2: Tables
            Obj.TabTables(2).h = uitable(Obj.TabGridLayouts(6).h, ...
                'ColumnWidth', 'fit', ...
                'FontSize', 10, ...
                'Data', []);
            Obj.TabTables(2).h.Layout.Row = [1, 2];
            Obj.TabTables(2).h.Layout.Column = 1;
            % -------------------------------------------------------------
            % Tab 2: Parse error message
            Obj.TabLabels(11).h = uilabel(Obj.TabGridLayouts(6).h, ...
                'Text', '', ...
                'Visible', 'off', ...
                'BackgroundColor', Colors.bs_warning_subtle, ...
                'FontSize', 10);
            Obj.TabLabels(11).h.Layout.Row = 1;
            Obj.TabLabels(11).h.Layout.Column = 1;
            % -------------------------------------------------------------
            Obj.Buttons.Help = uibutton(Obj.GridLayout, ...
                'Text', 'HELP', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_primary, ...
                'ButtonPushedFcn', @(source, event) web('https://cicada-actigraphy-suite.readthedocs.io/en/latest/docs/file-import-sleep-diary.html', '-browser'));
            Obj.Buttons.Help.Layout.Row = 2;
            Obj.Buttons.Help.Layout.Column = 2;
            % -------------------------------------------------------------
            Obj.Buttons.Cancel = uibutton(Obj.GridLayout, ...
                'Text', 'CANCEL', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_secondary, ...
                'ButtonPushedFcn', @(source, event) Obj.cancel(event));
            Obj.Buttons.Cancel.Layout.Row = 2;
            Obj.Buttons.Cancel.Layout.Column = 3;
            % -------------------------------------------------------------
            Obj.Buttons.Submit = uibutton(Obj.GridLayout, ...
                'Text', 'IMPORT', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_success, ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(source, event) Obj.submit(event));
            Obj.Buttons.Submit.Layout.Row = 2;
            Obj.Buttons.Submit.Layout.Column = 4;
        end
        % =================================================================
        function update(Obj)
            try
                % Start performance tracking
                Obj.startPerformanceTracking();
                % ---------------------------------------------------------
                % Check if there is raw data and set visibilty of tab 2 objects
                if ~isempty(Obj.RawData)
                    Obj.Placeholder.Visible = 'off';
                    Obj.TabPanels(3).h.Visible = 'on';
                    Obj.TabPanels(4).h.Visible = 'on';
                else
                    Obj.Placeholder.Visible = 'on';
                    Obj.TabPanels(3).h.Visible = 'off';
                    Obj.TabPanels(4).h.Visible = 'off';
                end
                % ---------------------------------------------------------
                % Check validity of data and dis/enable the import button
                if Obj.IsValid
                    Obj.Buttons.Submit.Enable = 'on';
                else
                    Obj.Buttons.Submit.Enable = 'off';
                end
                % ---------------------------------------------------------
                % Set the filepath and the raw data table on tab 1
                Obj.TabLabels(1).h.Text = Obj.FilePath;
                Obj.TabTables(1).h.Data = Obj.RawData;
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Set warning icons to missing values
                Missing = ismissing(Obj.RawData);
                removeStyle(Obj.TabTables(1).h)
                for r = 1:size(Missing, 1)
                    for c = 1:size(Missing, 2)
                        if Missing(r, c)
                            addStyle(Obj.TabTables(1).h, Obj.FailIcon, 'cell', [r, c]);
                        end
                    end
                end
                % ---------------------------------------------------------
                % Set the variable column dropdowns on tab 2
                if ~isempty(Obj.RawData)
                    for i = 1:7
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Get the tag and the column index
                        tag = Obj.TabInputs(i).h.Tag;
                        idx = Obj.Settings.ImportEvents.SleepDiary.Idx.(tag);
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Set the input items
                        Obj.TabInputs(i).h.Value = Obj.Settings.ImportEvents.SleepDiary.Format.(tag);
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Set the dropdown menu items
                        Obj.TabDropDowns(i).h.Items = [{'Select...'}, Obj.RawData.Properties.VariableNames];
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Make sure the index is within range
                        if idx < 0
                            idx = 0;
                            Obj.Settings.ImportEvents.SleepDiary.Idx.(tag) = idx;
                        end
                        if idx > size(Obj.RawData, 2)
                            idx = size(Obj.RawData, 2);
                            Obj.Settings.ImportEvents.SleepDiary.Idx.(tag) = idx;
                        end
                        Obj.TabDropDowns(i).h.Value = Obj.TabDropDowns(i).h.Items{idx+1};
                    end
                else
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % No raw data loaded so remove items and value
                    for i = 1:7
                        Obj.TabInputs(i).h.Value = '';
                        Obj.TabDropDowns(i).h.Items = {};
                        Obj.TabDropDowns(i).h.Value = {};
                    end
                end
                % Parse data
                if ~isempty(Obj.RawData)
                    Obj.parseRawData();
                end
                % TODO check data validity
                % ---------------------------------------------------------
                % Set the  parsed data table on tab 2
                 Obj.TabTables(2).h.Data = Obj.ParsedData;
                % ---------------------------------------------------------
                % End performance tracking
                Obj.endPerformanceTracking();
            catch ME
                % Ensure tracking ends even on error
                if Obj.Verbose > 0
                    Obj.endPerformanceTracking();
                end
                printerrormessage(ME, 'The error occurred during ''update'' in ImportEvents_SleepDiary.m')
            end
        end
    end
    % *********************************************************************
    methods (Access = public)
        % Browse for CSV file
        function browse(Obj, event)
            % -------------------------------------------------------------
            % Disable the button to prevent double clicks
            event.Source.Enable = 'off';
            drawnow();
            % -------------------------------------------------------------
            app = app_gethandle();
            % -------------------------------------------------------------
            % User selects a file to open
            [Filename, Path] = app.getfile({'*.txt; *.csv; *.dat; *.tsv'});
            % Enable the button again
            event.Source.Enable = 'on';
            % If user pressed cancel, return
            if Filename == 0; return; end
            % -------------------------------------------------------------
            % Try reading the data
            [data, ME] = flexiblereadtable(fullfile(Path, Filename));
            if ~isempty(ME)
                % Data could not be read
                return
            end
            % -------------------------------------------------------------
            % Set properties
            Obj.FilePath = fullfile(Path, Filename);
            Obj.RawData = data;
        end
        % =================================================================
        % Save settings
        function setImportSettings(Obj, event)
            % -------------------------------------------------------------
            % Get app handle so we have access to its methods
            app = app_gethandle();
            switch class(event.Source)
                case 'matlab.ui.control.DropDown'
                    idx = find(strcmpi(event.Source.Value, event.Source.Items)) - 1; % Minus 1 to account for the 'Select...' option
                    app.Props.Settings.ImportEvents.SleepDiary.Idx.(event.Source.Tag) = idx;
                case 'matlab.ui.control.EditField'
                    app.Props.Settings.ImportEvents.SleepDiary.Format.(event.Source.Tag) = event.Source.Value;
            end
            % -------------------------------------------------------------
            % Save settings and overwrite local copy of the settings
            app_savesettings(app.Props.Settings);
            Obj.Settings = app.Props.Settings;
        end
        % =================================================================
        % Parse raw data
        function parseRawData(Obj)
            % -------------------------------------------------------------
            % Init empty table
            Obj.ParsedData = table();
            Obj.TabTables(2).h.Layout.Row = [1, 2];
            Obj.TabLabels(11).h.Visible = 'off';
            % -------------------------------------------------------------
            % If nothing to parse, return
            if isempty(Obj.RawData)
                return
            end
            % -------------------------------------------------------------
            % Try to parse the data, and return empty table if it fails
            [Obj.ParsedData, errormessage] = parserawsleepdiarydata(Obj.RawData, Obj.Settings.ImportEvents.SleepDiary);
            if ~isempty(errormessage)
                Obj.TabTables(2).h.Layout.Row = 2;
                Obj.TabLabels(11).h.Visible = 'on';
                Obj.TabLabels(11).h.Text = errormessage;
            end
        end
        % =================================================================
        % Cancel
        function cancel(Obj, event) %#ok<INUSD>
            % -------------------------------------------------------------
            % Get app handle so we have access to its methods
            app = app_gethandle();
            % -------------------------------------------------------------
            % Close modal
            app.hModal(event, '');
        end
        % =================================================================
        % Create or update event
        function submit(Obj, event)
            % -------------------------------------------------------------
            % Get app handle so we have access to its methods
            app = app_gethandle();
            Payload = {
                'Settings', Obj.Settings.ImportEvents.SleepDiary, ...
                'Filepath', Obj.FilePath};
            event = AppEventData(event, Payload);
            % -------------------------------------------------------------
            % Close modal
            app.hModal(event, '');
            % -------------------------------------------------------------
            % Execute callback function
            app_callback(event, 'set_sleepdiaryevents', {'eDataChanged'});
        end
        % =================================================================
        function hUpdate(Obj, app, ~) %#ok<INUSD>
            try
                % Do something
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ImportEvents_SleepDiary.m')
            end
        end
    end
end