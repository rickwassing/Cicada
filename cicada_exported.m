classdef cicada_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        Menu_File                      matlab.ui.container.Menu
        Menu_File_New                  matlab.ui.container.Menu
        Menu_File_New_GeneActiv        matlab.ui.container.Menu
        Menu_File_New_Actigraph        matlab.ui.container.Menu
        Menu_File_OpenDataset          matlab.ui.container.Menu
        Menu_File_OpenRecent           matlab.ui.container.Menu
        Menu_File_CloseDataset         matlab.ui.container.Menu
        Menu_File_SaveDataset          matlab.ui.container.Menu
        Menu_File_SaveDatasetAs        matlab.ui.container.Menu
        Menu_File_ImportOther          matlab.ui.container.Menu
        Menu_File_ImportOther_NoOptions  matlab.ui.container.Menu
        Menu_File_ImportEvents         matlab.ui.container.Menu
        Menu_File_ImportEvents_SleepDiary  matlab.ui.container.Menu
        Menu_File_Export               matlab.ui.container.Menu
        Menu_File_Export_Metrics       matlab.ui.container.Menu
        Menu_File_Export_Stats         matlab.ui.container.Menu
        Menu_File_Export_Report        matlab.ui.container.Menu
        Menu_File_Export_Code          matlab.ui.container.Menu
        Menu_File_Quit                 matlab.ui.container.Menu
        Menu_Edit                      matlab.ui.container.Menu
        Menu_Edit_Info                 matlab.ui.container.Menu
        Menu_Edit_Select               matlab.ui.container.Menu
        Menu_Edit_ChangeTime           matlab.ui.container.Menu
        Menu_Edit_ChangeEpoch          matlab.ui.container.Menu
        Menu_Preproc                   matlab.ui.container.Menu
        Menu_Preproc_Calibrate         matlab.ui.container.Menu
        Menu_Preproc_NonWear           matlab.ui.container.Menu
        Menu_Analysis                  matlab.ui.container.Menu
        Menu_Analysis_Annot            matlab.ui.container.Menu
        Menu_Analysis_Annot_Accelaration  matlab.ui.container.Menu
        Menu_Analysis_Annot_Light      matlab.ui.container.Menu
        Menu_Analysis_Events           matlab.ui.container.Menu
        Menu_Analysis_Events_Daily     matlab.ui.container.Menu
        Menu_Analysis_Events_Relative  matlab.ui.container.Menu
        Menu_Analysis_Events_SleepWin  matlab.ui.container.Menu
        Menu_Help                      matlab.ui.container.Menu
        Menu_Help_About                matlab.ui.container.Menu
        EditregistrationMenu           matlab.ui.container.Menu
        Menu_Help_Documentation        matlab.ui.container.Menu
        Menu_Help_Bugs                 matlab.ui.container.Menu
        MainGridLayout                 matlab.ui.container.GridLayout
        MainPanel                      matlab.ui.container.Panel
        ContentGridLayout              matlab.ui.container.GridLayout
        InfoPanel                      matlab.ui.container.Panel
        InfoGridLayout                 matlab.ui.container.GridLayout
        CicadaLogo                     matlab.ui.control.Image
    end

    % CICADA
    % Application for the concerted analysis of data from wearable devices.

    % Authors:
    %   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
    %
    % History:
    %   Created 2023-03-17, Rick Wassing

    % Cicada (C) 2023 by Rick Wassing is licensed under
    % Attribution-NonCommercial-ShareAlike 4.0 International
    % This license requires that reusers give credit to the creator. It allows
    % reusers to distribute, remix, adapt, and build upon the material in any
    % medium or format, for noncommercial purposes only. If others modify or
    % adapt the material, they must license the modified material under
    % identical terms.

    % *********************************************************************
    % PROPERTIES
    properties (Access = public)
        ACT; % Holds all data
        Cmps; % Holds all dynamic components
        Props; % Holds all state variables
        Status;
        URL = struct();
        % TODO: variable font size
    end
    % *********************************************************************
    % EVENTS
    events
        eRecentListChanged; % TODO: When a new dataset has changed
        eDatasetChanged; % When the entire dataset has changed e.g., new, load, import, close
        eDatasetStatusChanged; % When the dataset is saved
        eDataChanged; % The values in ACT.data, or ACT.metric, or ACT.analysis.events has changed
        eActogramSettingsChanged; % When the values in ACT.info.actogram have changed
        eDisplaySettingsChanged; % When the display settings change
        eEventSettingsChanged; % When the event settings change
        eDataPanelPulled; % When a new data panel is pulled, re-render its components
        eStyleChanged; % When any style has changed for the report
        eLogoChanged; % When the report logo has changed
        eContentChanged; % When the report content has changed
        eMouseMotion; % When the mouse moves
        eMouseDown; % When the mouse is pressed
        eMouseUp; % When the mouse is released
        eKeyPress; % When keyboard input occurs
    end
    % *********************************************************************
    % METHODS
    methods (Access = public)
        % =================================================================
        % HREGISTERUSER Asks the user to register and subscribe
        % First variable input argument is a boolean to indicate a forced
        % re-registration.
        % -----------------------------------------------------------------
        function hRegisterUser(app, varargin)
            force = false;
            if nargin > 1
                force = varargin{1};
            end
            if ~isfield(app.Props.Settings, 'Auth')
                dt = datetime('now', 'TimeZone', 'local');
                app.Props.Settings.Auth = struct();
                app.Props.Settings.Auth.name = '';
                app.Props.Settings.Auth.institute = '';
                app.Props.Settings.Auth.email = '';
                app.Props.Settings.Auth.shareusagedata = 'yes';
                app.Props.Settings.Auth.subscribe = 'yes';
                app.Props.Settings.Auth.accept = 'no';
                app.Props.Settings.Auth.is_registered = 'no';
                app.Props.Settings.Auth.datetime = sprintf('%s (%s)', char(dt, 'uuuu-MM-dd''T''HH:mm:ss'), dt.TimeZone);
            end
            if ~force && strcmpi(app.Props.Settings.Auth.is_registered, 'yes')
               return 
            end
            % TODO: add a 'cancel' button in case the user wants to re-register
            app.hModal([], 'RegisterUser', 'DisableBackdropClose', true, 'ComponentProps', app.Props.Settings.Auth);
        end
        % =================================================================
        % HSETUP Initializes all components
        % -----------------------------------------------------------------
        function hSetup(app)
            % -------------------------------------------------------------
            % RECENTLY OPENED DATASETS
            % -------------------------------------------------------------
            if isfield(app.Props.Settings, 'Recent')
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Enable or disable the recent menu and create menu items
                if isempty(app.Props.Settings.Recent)
                    app.Menu_File_OpenRecent.Enable = 'off';
                else
                    app.Menu_File_OpenRecent.Enable = 'on';
                    for i = 1:length(app.Props.Settings.Recent)
                        app.Cmps.OpenRecentMenu(i) = uimenu(app.Menu_File_OpenRecent);
                        app.Cmps.OpenRecentMenu(i).MenuSelectedFcn = createCallbackFcn(app, @Menu_File_OpenDatasetSelected, true);
                        app.Cmps.OpenRecentMenu(i).Accelerator = sprintf('%i', i);
                        [~, app.Cmps.OpenRecentMenu(i).Text] = fileparts(app.Props.Settings.Recent{i});
                        app.Cmps.OpenRecentMenu(i).UserData = app.Props.Settings.Recent{i};
                    end
                end
            else
                app.Menu_File_OpenRecent.Enable = 'off';
            end
            % -------------------------------------------------------------
            % INFO PANELS
            % -------------------------------------------------------------
            % Info panel: Study
            KeyValues = {...
                'Institute', ''; ...
                'Name', ''; ...
                'Researcher', ''};
            app.Cmps.InfoPanel_Study = InfoPanel(app.InfoGridLayout, ...
                'Title', 'STUDY', ...
                'KeyValues', KeyValues, ...
                'Enable', 'off', ...
                'Row', 4, ...
                'Verbose', app.Props.Verbose); %#ok<ADPROP>
            % -------------------------------------------------------------
            % Info panel: Participant
            KeyValues = {...
                'ID', ''; ...
                'Group', ''; ...
                'Session', ''; ...
                'Condition', ''; ...
                'DOB', ''; ...
                'Sex', ''; ...
                'Height', ''; ...
                'Weight', ''; ...
                'Handedness', ''};
            app.Cmps.InfoPanel_Participant = InfoPanel(app.InfoGridLayout, ...
                'Title', 'PARTICIPANT', ...
                'KeyValues', KeyValues, ...
                'Enable', 'off', ...
                'Row', 5, ...
                'Verbose', app.Props.Verbose); %#ok<ADPROP>
            % -------------------------------------------------------------
            % Info panel: Recording
            KeyValues = {...
                'Start_date', ''; ...
                'End_date', ''; ...
                'Duration', ''};
            app.Cmps.InfoPanel_Recording = InfoPanel(app.InfoGridLayout, ...
                'Title', 'RECORDING', ...
                'KeyValues', KeyValues, ...
                'Enable', 'off', ...
                'Row', 6, ...
                'Verbose', app.Props.Verbose); %#ok<ADPROP>
            % -------------------------------------------------------------
            % Info panel: Recording
            app.Cmps.InfoPanel_Modalities = InfoPanel(app.InfoGridLayout, ...
                'Title', 'MODALITIES', ...
                'KeyValues', {}, ...
                'Enable', 'off', ...
                'Row', 7, ...
                'Verbose', app.Props.Verbose); %#ok<ADPROP>
            % -------------------------------------------------------------
            % MAIN TAB GROUP AND CHILDREN
            % -------------------------------------------------------------
            app.Cmps.MainTabGroup = MainTabGroup(app.ContentGridLayout, ...
                'IsVisible', 'off', ......
                'Verbose', app.Props.Verbose);
            app.Cmps.MainTabGroup.Layout.Column = 2;
            app.Cmps.MainTabGroup.Layout.Row = 1;
            % -------------------------------------------------------------
            % SIDE TAB GROUP AND CHILDREN
            % -------------------------------------------------------------
            app.Cmps.SideTabGroup = SideTabGroup(app.ContentGridLayout, ...
                'IsVisible', 'off', ......
                'Verbose', app.Props.Verbose);
            app.Cmps.SideTabGroup.Layout.Column = 3;
            app.Cmps.SideTabGroup.Layout.Row = 1;
            % -------------------------------------------------------------
            % MODALS
            % -------------------------------------------------------------
            app.Cmps.ProgressDialog = [];
            app.Cmps.ConfirmDialog = [];
            app.Cmps.Toasts = struct();
            app.Cmps.Modal = Modal(app.UIFigure);
            % -------------------------------------------------------------
            % TOOLTIP
            % -------------------------------------------------------------
            app.Cmps.Tooltip = Tooltip(app.UIFigure);
        end
        % =================================================================
        function hUpdate(app, ~, event) %#ok<INUSD>
            % -------------------------------------------------------------
            % Check if there is a file loaded i.e., 'Name' is not empty
            if ~isempty(app.Props.Name)
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Diplay filename in title of figure
                app.UIFigure.Name = sprintf('Cicada - %s%s', app.Props.Name, ifelse(strcmpi(app.ACT.status, 'saved'), '', '*'));
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Enable menu items
                app.Menu_File_CloseDataset.Enable = 'on';
                app.Menu_File_ImportOther.Enable = 'on';
                app.Menu_File_ImportEvents.Enable = 'on';
                app.Menu_File_Export.Enable = 'on';
                app.Menu_Edit.Enable = 'on';
                app.Menu_Preproc.Enable = 'on';
                app.Menu_Analysis.Enable = 'on';
                % Enable/disable some menu items depending on file status
                switch app.ACT.status % 'saved', 'unsaved', 'neversaved', 'error'
                    case {'unsaved', 'neversaved'}
                        if isempty(app.ACT.filepath)
                            app.Menu_File_SaveDataset.Enable = 'off'; % if no filepath exists yet, then user must select 'Save as'
                        else
                            app.Menu_File_SaveDataset.Enable = 'on';
                        end
                        app.Menu_File_SaveDatasetAs.Enable = 'on';
                    case 'saved'
                        app.Menu_File_SaveDataset.Enable = 'off';
                        app.Menu_File_SaveDatasetAs.Enable = 'on';
                    case 'error'
                        app.Menu_File_SaveDataset.Enable = 'off';
                        app.Menu_File_SaveDatasetAs.Enable = 'off';
                end
            else
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % No file loaded, only show 'Cicada' in figure title
                app.UIFigure.Name = 'Cicada';
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Disable menu items
                app.Menu_File_CloseDataset.Enable = 'off';
                app.Menu_File_SaveDataset.Enable = 'off';
                app.Menu_File_SaveDatasetAs.Enable = 'off';
                app.Menu_File_ImportOther.Enable = 'off';
                app.Menu_File_ImportEvents.Enable = 'off';
                app.Menu_File_Export.Enable = 'off';
                app.Menu_Edit.Enable = 'off';
                app.Menu_Preproc.Enable = 'off';
                app.Menu_Analysis.Enable = 'off';
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                app.Cmps.Tooltip.Label = '';
                app.Cmps.Tooltip.hUpdate();
            end
        end
        % =================================================================
        function hStatus(app, event, status, cfg)
            % -------------------------------------------------------------
            % Validate cfg input
            if nargin < 4
                cfg = struct();
            end
            if ~isfield(cfg, 'DoShow')
                cfg.DoShow = false;
            end
            if ~isfield(cfg, 'Message')
                cfg.Message = '';
            end
            switch lower(status)
                % ---------------------------------------------------------
                case 'loading'
                    % Set the status
                    app.Status.Label = 'loading';
                    % Command window log if requested
                    if isempty(event) || iscell(event)
                        app.Status.EventName = 'no-event-name';
                    else
                        app.Status.EventName = event.EventName;
                    end
                    if app.Props.Verbose
                        app.Status.Time = now; %#ok<TNOW1>
                        fprintf('=============================================================\n')
                        fprintf('>> CIC: Event ''%s'' started (%s).\n', app.Status.EventName, datenum2iso(now)); %#ok<TNOW1>
                        fprintf('-------------------------------------------------------------\n')
                    end
                    % Render
                    if cfg.DoShow
                        app = app_progressdlg(app, 'Message', cfg.Message);
                    end
                    app.UIFigure.Pointer = 'watch';
                    drawnow();
                case 'idle'
                    % Render
                    drawnow();
                    app.UIFigure.Pointer = 'arrow';
                    app.Cmps.ProgressDialog = [];
                    % Set the status
                    app.Status.Label = 'idle';
                    % Check if the event name was set (sometimes it can't be set)
                    if ~isfield(app.Status, 'EventName')
                        app.Status.EventName = 'no-event-name';
                        app.Status.Time = now(); %#ok<TNOW1>
                    end
                    if app.Props.Verbose && ~isempty(event) % otherwise 'app.Status.EventName' would not be set
                        fprintf('-------------------------------------------------------------\n')
                        fprintf('>> CIC: Event ''%s'' completed in %.1g s.\n', app.Status.EventName, (now-app.Status.Time)*24*60*60) %#ok<TNOW1>
                        fprintf('=============================================================\n')
                    end
                case 'info'
                    % Render
                    drawnow();
                    app.UIFigure.Pointer = 'arrow';
                    app.Cmps.ProgressDialog = [];
                    app = app_confirmdlg(app, ...
                        'Icon', 'info', ...
                        'Title', 'Ding dong. Information.', ...
                        'Message', cfg.Message, ...
                        'Options', {'OK'}, ...
                        'DefaultOption', 'OK');
                    % Set the status
                    app.Status.Label = 'idle';
                case 'warning'
                    % Render
                    drawnow();
                    app.UIFigure.Pointer = 'arrow';
                    app.Cmps.ProgressDialog = [];
                    % Set the status
                    app.Status.Label = 'warning';
                case 'error'
                    % Render
                    drawnow();
                    app.UIFigure.Pointer = 'arrow';
                    app.Cmps.ProgressDialog = [];
                    printerrormessage(cfg.Message);
                    app = app_confirmdlg(app, 'Message', getReport(cfg.Message), 'Options', {'Close', 'Report bug'}, 'DefaultOption', 'Report bug');
                    switch app.Cmps.ConfirmDialog
                        case 'Report bug'
                            Prefill = getReport(cfg.Message, 'extended', 'hyperlinks', 'off');
                            web([app.URL.GoogleFormBugs, Prefill], '-browser')
                    end
                    % Set the status
                    app.Status.Label = 'error';
                case 'reset'
                    % Render
                    drawnow();
                    app.UIFigure.Pointer = 'arrow';
                    app.Cmps.ProgressDialog = [];
                    % Set the status
                    app.Status.Label = 'idle';
            end
        end
        % =================================================================
        function res = hAskToSaveDataset(app, event)
            % ---------------------------------------------------------
            res = true;
            if isempty(app.ACT) % If there is no data, return
                return
            end
            % ---------------------------------------------------------
            % If the data is currently unsaved ...
            if ~strcmpi(app.ACT.status, 'saved')
                % ... show dialog to ask if the user wants to save the data
                app = app_confirmdlg(app, 'Title', 'You''ve got unsaved changes', 'Message', 'Do you want to save this dataset?', 'Options', {'Cancel', 'No', 'Yes'}, 'DefaultOption', 'Yes', 'Icon', 'question');
                switch app.Cmps.ConfirmDialog
                    case 'Cancel'
                        % ---------------------------------------------------------
                        % User asked to cancel
                        res = false; % return false and cancel what you were doing
                    case 'Yes'
                        % ---------------------------------------------------------
                        % Save dataset
                        app.Menu_File_SaveDatasetSelected(event)
                        % Check that no errors occurred
                        if strcmpi(app.ACT.status, 'error')
                            res = false;%  return false and cancel what you were doing
                        end
                end
            end
        end
        % =================================================================
        function hModal(app, event, component, varargin)
            % TODO: disable all menu's when modal is open
            DisableBackdropClose = false;
            ComponentProps = struct([]);
            for i = 1:2:length(varargin)
                switch lower(varargin{i})
                    case 'disablebackdropclose'
                        DisableBackdropClose = varargin{i+1};
                    case 'componentprops'
                        ComponentProps = varargin{i+1};
                end
            end
            % -------------------------------------------------------------
            % Toggle
            app.Props.ToggleModal = ~app.Props.ToggleModal;
            app.Cmps.Modal.hUpdate(app, event, component, 'DisableBackdropClose', DisableBackdropClose, 'ComponentProps', ComponentProps);
            if ~app.Props.ToggleModal
                app.Props.SelectedSegment = [];
            end
            % -------------------------------------------------------------
            % Set status
            app.hStatus(event, 'Idle');
        end
        % =================================================================
        function hToast(app, event, cfg) %#ok<INUSL>
            % -------------------------------------------------------------
            % Validate cfg input
            if ~isfield(cfg, 'Title')
                return
            end
            if ~isfield(cfg, 'Color')
                return
            end
            if ~isfield(cfg, 'Message')
                cfg.Message = '';
            end
            if ~isfield(cfg, 'Timeout')
                cfg.Timeout = 5;
            end
            % -------------------------------------------------------------
            % Calculate position
            YPos = max(arrayfun(@(t) sum(t.Position([2, 4])), findall(app.UIFigure, 'Type', 'Toast')));
            if isempty(YPos)
                YPos = 6;
            end
            Position = [12, 6 + YPos, 250, 50];
            Toast(app.UIFigure, ...
                'Title', cfg.Title, ...
                'Message', cfg.Message, ...
                'Color', cfg.Color, ...
                'Timeout', cfg.Timeout, ...
                'Position', Position, ...
                'Verbose', app.Props.Verbose);
        end
        % =================================================================
        function [Filename, Path] = getfile(app, filter)
            dummy = figure(...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'DockControls', 'off', ...
                'WindowState', 'minimized'); % Create dummy figure
            [Filename, Path] = uigetfile(filter);
            delete(dummy);
            figure(app.UIFigure);
        end
        % =================================================================
        function [Filename, Path] = putfile(app, filter, varargin)
            RemoveExt = false;
            for i = 1:2:length(varargin)
                switch lower(varargin{i})
                    case 'removeext'
                        RemoveExt = varargin{i+1};
                end
            end
            dummy = figure(...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'DockControls', 'off', ...
                'WindowState', 'minimized'); % Create dummy figure
            [Filename, Path] = uiputfile(filter);
            delete(dummy);
            figure(app.UIFigure);
            % If the user requested to remove the extension
            if RemoveExt
                cnt = 0; % limiter
                while contains(Filename, '.') && cnt < 100
                    [~, Filename] = fileparts(Filename);
                    cnt = cnt+1;
                end
            end
        end
        % =================================================================
        % Helper function to check if a point is inside an object
        function inside = IsHovered(app, obj)
            if ~isvalid(obj)
                inside = false;
                return
            end
            point = app.UIFigure.CurrentPoint;
            pos = app.GetAbsolutePosition(obj);
            inside = (point(1) > pos(1)) && (point(1) < (pos(1) + obj.Position(3))) && (point(2) > pos(2)) && (point(2) < (pos(2) + obj.Position(4)));
        end
        % =================================================================
        % Hover functionality: get the absolute position of an element relative to the UIFigure
        function pos = GetAbsolutePosition(~, obj)
            % Get the position of the current UI element relative to its parent
            pos = obj.Position(1:2); % Take x, y (ignore width, height)
            parent = obj.Parent;
            % Recursively add the positions of parent elements until we reach the UIFigure
            while ~isa(parent, 'matlab.ui.Figure') % Stop if parent is UIFigure
                pos = pos + parent.Position(1:2); % Add parent position
                % Check if the parent is a scrollable container (like uipanel or uigridlayout)
                if isprop(parent, 'Scrollable') 
                    if strcmpi(parent.Scrollable, 'on')
                        pos = pos - parent.ScrollableViewportLocation(1:2); % Subtract the scroll offset
                    end
                end
                parent = parent.Parent; % Move up one level
            end
            % Adjustment
            pos = pos + [-12, -12];
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % =============================================================
            % INIT
            % -------------------------------------------------------------
            Path = fileparts(which('cicada.mlapp'));
            addpath(genpath(Path));
            if ~exist('org.apache.pdfbox.multipdf.PDFMergerUtility', 'class')
                javaaddpath(fullfile(Path, 'Package/Libraries/PDFBox/pdfbox-app-3.0.6.jar'));
            end
            % Set position
            app = app_setposition(app);
            % Set images
            app.CicadaLogo.ImageSource = 'cicadalogo.png';
            % Delete all timers
            Timers = timerfindall();
            if ~isempty(Timers)
                stop(Timers);
                delete(Timers);
            end
            % -------------------------------------------------------------
            % Get default properties
            app.URL.GoogleFormBugs = 'https://docs.google.com/forms/d/e/1FAIpQLSdQ89Yl-VncKGlThaICfgtukrqbE590nreWlIyrJcg-o-7gBQ/viewform?usp=pp_url&entry.165730575=';
            app.URL.Documentation = 'https://cicada-actigraphy-suite.readthedocs.io';
            app.URL.MSFlow = 'https://default82c514c1a7174087be06d40d2070ad.52.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/7d6c317a55e9432c843a21f172302746/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Ri7GHT0vi1EY8x1qslVEYW_gptq1-Y04H1ZFNhuYdh8';
            app.Props.Name = '';
            app.Props.Path = Path;
            app.Props.SelectedSegment = [];
            app.Props.IsMouseDown = false;
            app.Props.ToggleModal = false;
            app.Props.Verbose = true;
            % -------------------------------------------------------------
            % App settings
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % This function loads settings file, or initializes a new one.
            app.Props.Settings = app_loadsettings();
            % =============================================================
            % INITIAL CONSTRUCTION OF COMPONENTS
            app.hSetup();
            % =============================================================
            % POINTER MANAGER
            iptPointerManager(app.UIFigure, 'enable');
            % =============================================================
            % CREATE EVENT LISTENERS
            app_addlisteners(app, app, {'eDatasetChanged', 'eDatasetStatusChanged'}); % TODO: when the dataset status changed, broadcast 'eDatasetStatusChanged'
            app_addlisteners(app, app.Cmps.InfoPanel_Study, {'eDatasetChanged'});
            app_addlisteners(app, app.Cmps.InfoPanel_Participant, {'eDatasetChanged'});
            app_addlisteners(app, app.Cmps.InfoPanel_Recording, {'eDatasetChanged'});
            app_addlisteners(app, app.Cmps.InfoPanel_Modalities, {'eDatasetChanged'});
            app_addlisteners(app, app.Cmps.MainTabGroup, {'eDatasetChanged'});
            app_addlisteners(app, app.Cmps.SideTabGroup, {'eDatasetChanged'});
            % =============================================================
            % Show logo and info
            app_asciilogo();
            % =============================================================
            % ASK THE USER TO SUBSCRIBE
            app.hRegisterUser();
            % =============================================================
            % SEND TELEMETRY DATA
            p = struct();
            p.status = 'start';
            Telemetry.post('session', p)
        end

        % Menu selected function: Menu_File_New_Actigraph, 
        % ...and 1 other component
        function Menu_File_NewDatasetSelected(app, event)
            try
                % =========================================================
                % WHAT TYPE OF FILE TO IMPORT?
                switch event.Source.Text
                    case 'Import GeneActiv (.bin)'
                        FileExtension = '*.bin';
                        Type = 'geneactiv';
                    case 'Import Actigraph (.gt3x)'
                        FileExtension = '*.gt3x';
                        Type = 'actigraph';
                    otherwise
                        return
                end
                % =========================================================
                % USER INPUT
                % ---------------------------------------------------------
                % Ask to save the current dataset
                res = app.hAskToSaveDataset(event);
                if ~res
                    return
                end
                % ---------------------------------------------------------
                % Keep the current dataset in memory in case we need to retrieve it later
                CurACT = app.ACT;
                % ---------------------------------------------------------
                % User selects a file to open
                [Filename, Path] = app.getfile(FileExtension);
                % If user pressed cancel, return
                if Filename == 0; return; end
                % =========================================================
                % STATUS
                cfg = struct();
                cfg.DoShow = true;
                cfg.Message = sprintf('Importing ''%s''', Filename);
                app.hStatus(event, 'Loading', cfg);
                % =========================================================
                % SET STATE
                cfg = struct();
                cfg.FullFilePath = fullfile(Path, Filename);
                cfg.Type = Type;
                app.ACT = cic_newdataset([], cfg);
                % ---------------------------------------------------------
                % Check if the returned dataset is empty (e.g., cancel button pressed)
                if isempty(app.ACT)
                    app.ACT = CurACT;
                    app.hStatus(event, 'Idle');
                    return
                end
                % ---------------------------------------------------------
                app.Props.Name = app.ACT.filename;
                % =========================================================
                % TRIGGER CALLBACKS
                % ---------------------------------------------------------
                % Existing listeners
                app_notify(app, {'eDatasetChanged'});
                % ---------------------------------------------------------
                % Dynamic listeners
                drawnow();
                app_notify(app, {'eDataChanged'});
                % =========================================================
                % STATUS
                if strcmpi(app.ACT.status, 'error')
                    cfg.DoShow = true;
                    cfg.Message = app.ACT.etc.error;
                    app.hStatus(event, 'Error', cfg);
                else
                    % TODO: Show 'Toast' for each warning in the dataset
                    % and a 'do not show' again button to silence the
                    % warning (do not delete from dataset).
                    app.hStatus(event, 'Idle');
                end
                % =========================================================
            catch ME % Something went wrong
                cfg.DoShow = true;
                cfg.Message = ME;
                app.hStatus(event, 'Error', cfg)
            end
        end

        % Menu selected function: Menu_File_OpenDataset
        function Menu_File_OpenDatasetSelected(app, event)
            try
                % =========================================================
                % Ask to save the current dataset
                res = app.hAskToSaveDataset(event);
                if ~res
                    return
                end
                if isempty(event.Source.UserData)
                    % =========================================================
                    % Then ask to select a dataset to load
                    % ---------------------------------------------------------
                    % User selects a file to open
                    [Filename, Path] = app.getfile('*.mat');
                    % If user pressed cancel, return
                    if Filename == 0; return; end
                else
                    % ---------------------------------------------------------
                    % Then a 'recent' file was selected, extract filepath and name
                    [Path, Filename] = fileparts(event.Source.UserData);
                    Filename = [Filename, '.mat'];
                end
                % =========================================================
                % STATUS
                cfg.DoShow = true;
                cfg.Message = sprintf('Loading ''%s''', Filename);
                app.hStatus(event, 'Loading', cfg);
                % =========================================================
                % SET STATE
                cfg = struct();
                cfg.FullFilePath = fullfile(Path, Filename);
                app.ACT = cic_loaddataset([], cfg);
                app.Props.Name = app.ACT.filename;
                % ---------------------------------------------------------
                % Update recently loaded files
                if isfield(app.Props.Settings, 'Recent')
                    app.Props.Settings.Recent = [{cfg.FullFilePath}; app.Props.Settings.Recent];
                    app.Props.Settings.Recent = unique(app.Props.Settings.Recent, 'stable');
                    if length(app.Props.Settings.Recent) > 10
                        app.Props.Settings.Recent = app.Props.Settings.Recent(1:10);
                    end
                else
                    app.Props.Settings.Recent = {cfg.FullFilePath};
                end
                % ---------------------------------------------------------
                % Save app settings
                app_savesettings(app.Props.Settings);
                % =========================================================
                % TRIGGER CALLBACKS
                % ---------------------------------------------------------
                % Existing listeners
                app_notify(app, {'eDatasetChanged'});
                % ---------------------------------------------------------
                % Dynamic listeners
                drawnow();
                app_notify(app, {'eDataChanged'});
                % =========================================================
                % STATUS
                if strcmpi(app.ACT.status, 'error')
                    cfg.DoShow = true;
                    cfg.Message = app.ACT.etc.error;
                    app.hStatus(event, 'Error', cfg);
                else
                    app.hStatus(event, 'Idle');
                end
                % =========================================================
            catch ME % Something went wrong
                cfg.DoShow = true;
                cfg.Message = ME;
                app.hStatus(event, 'Error', cfg);
            end
        end

        % Menu selected function: Menu_File_CloseDataset
        function Menu_File_CloseDatasetSelected(app, event)
            try
                % =========================================================
                % Check if there even is a dataset
                if isempty(app.ACT)
                    return
                end
                % =========================================================
                % Ask to save the current dataset
                res = app.hAskToSaveDataset(event);
                if ~res
                    return
                end
                % =========================================================
                % STATUS
                app.hStatus(event, 'Loading');
                % =========================================================
                % SET STATE
                app.ACT = struct([]);
                app.Props.Name = '';
                % =========================================================
                % TRIGGER CALLBACKS
                % ---------------------------------------------------------
                % Existing listeners
                app_notify(app, {'eDatasetChanged'});
                % ---------------------------------------------------------
                % Dynamic listeners
                drawnow();
                app_notify(app, {'eDataChanged'});
                % =========================================================
                % STATUS
                app.hStatus(event, 'Idle')
                % =========================================================
            catch ME % Something went wrong
                cfg.DoShow = true;
                cfg.Message = ME;
                app.hStatus(event, 'Error', cfg);
            end
        end

        % Menu selected function: Menu_File_SaveDataset
        function Menu_File_SaveDatasetSelected(app, event)
            try
                % =========================================================
                % Check if there even is a dataset
                if isempty(app.ACT)
                    return
                end
                % =========================================================
                % If the dataset has already been saved, then return
                if strcmpi(app.ACT.status, 'saved')
                    % Show status message that the dataset is already saved
                    cfg.DoShow = true;
                    cfg.Message = 'This dataset is already saved.';
                    app.hStatus(event, 'Info', cfg);
                    return
                end
                % =========================================================
                % If the dataset has never been saved, ask a location
                if strcmpi(app.ACT.status, 'neversaved')
                    app.Menu_File_SaveDatasetAsSelected(event);
                end
                % =========================================================
                % STATUS
                cfg.DoShow = true;
                cfg.Message = sprintf('Saving ''%s''', app.ACT.filename);
                app.hStatus(event, 'Loading', cfg);
                % =========================================================
                % SET STATE
                cfg = struct();
                cfg.FullFilePath = fullfile(app.ACT.filepath, [app.ACT.filename, '.mat']);
                app.ACT = cic_savedataset(app.ACT, cfg);
                % =========================================================
                % TRIGGER CALLBACKS
                app_notify(app, {'eDatasetStatusChanged'});
                % =========================================================
                % STATUS
                if strcmpi(app.ACT.status, 'error')
                    cfg.DoShow = true;
                    cfg.Message = app.ACT.etc.error;
                    app.hStatus(event, 'Error', cfg);
                else
                    cfg.Title = 'Succesfully saved!';
                    cfg.Color = 'success'; % 'success', 'warning', 'danger', 'info'
                    app.hToast(event, cfg);
                    app.hStatus(event, 'Idle');
                end
                % =========================================================
            catch ME % Something went wrong
                cfg.DoShow = true;
                cfg.Message = ME;
                app.hStatus(event, 'Error', cfg);
            end
        end

        % Menu selected function: Menu_File_SaveDatasetAs
        function Menu_File_SaveDatasetAsSelected(app, event)
            % =========================================================
            % Check if there even is a dataset
            if isempty(app.ACT)
                return
            end
            % =============================================================
            % USER INPUT
            % -------------------------------------------------------------
            % User selects a file to open
            [Filename, Path] = app.putfile([app.ACT.filename, '.mat']);
            % If user pressed cancel, return
            if Filename == 0; return; end
            % -------------------------------------------------------------
            % Replace backslashes in the filepath
            Path = strrep(Path, filesep, '/');
            % =========================================================
            % SET STATE
            [app.ACT.filepath, app.ACT.filename] = fileparts([Path, '/', Filename]);
            app.ACT.status = 'unsaved';
            % =========================================================
            % Execute the SAVEDATASETSELECTED Callback
            app.Menu_File_SaveDatasetSelected(event);
        end

        % Menu selected function: Menu_File_ImportEvents_SleepDiary
        function Menu_File_ImportEvents_SleepDiarySelected(app, event)
            try
                % =========================================================
                % Check if there even is a dataset
                if isempty(app.ACT)
                    return
                end
                % ---------------------------------------------------------
                % Check if the settings include the sleep diary format
                init = false;
                if ~isfield(app.Props.Settings, 'ImportEvents')
                    init = true;
                elseif ~isfield(app.Props.Settings.ImportEvents, 'SleepDiary')
                    init = true;
                end
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Initialize the import settings
                if init
                    cfg = struct();
                    cfg.Format = struct();
                    cfg.Format.Date = 'dd/mm/yyyy';
                    cfg.Format.LightsOut = 'HH:MM';
                    cfg.Format.LightsOn = 'HH:MM';
                    cfg.Format.FinAwake = 'HH:MM';
                    cfg.Format.SL = 'minutes';
                    cfg.Format.WASO = 'minutes';
                    cfg.Format.NumAwake = 'integer';
                    cfg.Idx.Date = 1;
                    cfg.Idx.LightsOut = 2;
                    cfg.Idx.LightsOn = 3;
                    cfg.Idx.FinAwake = 4;
                    cfg.Idx.SL = 5;
                    cfg.Idx.WASO = 6;
                    cfg.Idx.NumAwake = 7;
                    app.Props.Settings.ImportEvents.SleepDiary = cfg;
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    app_savesettings(app.Props.Settings);
                end
                % Call the modal
                app.hModal(event, 'ImportEvents_SleepDiary')
                % =========================================================
            catch ME % Something went wrong
                cfg.DoShow = true;
                cfg.Message = ME;
                app.hStatus(event, 'Error', cfg);
            end
        end

        % Menu selected function: Menu_File_Export_Metrics
        function Menu_File_Export_MetricsSelected(app, event)
            % =========================================================
            % Check if there even is a dataset
            if isempty(app.ACT)
                return
            end
            % =============================================================
            % USER INPUT
            % -------------------------------------------------------------
            % User selects a file to open
            [Filename, Path] = app.putfile('*.csv', 'RemoveExt', true);
            % If user pressed cancel, return
            if Filename == 0; return; end
            % -------------------------------------------------------------
            % Replace backslashes in the filepath
            Path = strrep(Path, filesep, '/');
            % =============================================================
            % STATUS
            cfg.DoShow = true;
            cfg.Message = sprintf('Exporting metrics to ''%s''', [Filename, '.csv']);
            app.hStatus(event, 'Loading', cfg);
            % =============================================================
            % Call the function to export the metrics to file
            cfg = struct();
            cfg.FullFilePath = fullfile(Path, [Filename, '.csv']);
            cfg.type = 'metrics';
            app.ACT = cic_export(app.ACT, cfg);
            % =========================================================
            % STATUS
            if strcmpi(app.ACT.status, 'error')
                cfg.DoShow = true;
                cfg.Message = app.ACT.etc.error;
                app.hStatus(event, 'Error', cfg);
            else
                cfg.Title = 'Succesfully exported!';
                cfg.Color = 'success'; % 'success', 'warning', 'danger', 'info'
                app.hToast(event, cfg);
                app.hStatus(event, 'Idle');
            end
        end

        % Menu selected function: Menu_File_Quit
        function Menu_File_QuitSelected(app, event)
            % =========================================================
            % Check if there even is a dataset
            if isempty(app.ACT)
                % Ask to save the current dataset
                res = app.hAskToSaveDataset(event);
                if ~res
                    return
                end
            end
            % =========================================================
            % All good and delete the app
            app.delete();
        end

        % Menu selected function: EditregistrationMenu
        function Menu_Help_EditRegistration(app, ~)
            app.hRegisterUser(true); % 'true' to force re-registration
        end

        % Menu selected function: Menu_Help_Bugs
        function Menu_Help_BugsSelected(app, ~)
            web(app.URL.GoogleFormBugs, '-browser');
        end

        % Menu selected function: Menu_Help_Documentation
        function Menu_Help_DocumentationSelected(app, ~)
            web(app.URL.Documentation, '-browser');
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            % =========================================================
            % CHECKS
            if isempty(app.UIFigure.CurrentObject)
                return
            end
            if ~isvalid(app.UIFigure.CurrentObject)
                return
            end
            % =========================================================
            % SET STATE
            app.Props.IsMouseDown = true;
            if isfield(app.Props, 'SelectedInputRef')
                if ~isempty(app.Props.SelectedInputRef)
                    app.Props.SelectedInputRef.OnBlur(event);
                    app.Props.SelectedInputRef = [];
                end
            end
            % ---------------------------------------------------------
            if contains(event.Source.CurrentObject.Tag, 'EditableEventTrace')
                % Extract the event id and its onset and offset
                id = strsplit(event.Source.CurrentObject.Tag, '_id-');
                app.Props.SelectedSegment = event.Source.CurrentObject.XData(1:2);
                app.Props.SelectedEventId = str2double(id{2});
                app.Props.SelectionMade = true;
            elseif strcmpi(event.Source.CurrentObject.Tag, 'clickable')
                lbl = event.Source.CurrentObject;
                parentComp = ancestor(lbl, 'matlab.ui.componentcontainer.ComponentContainer');
                if isa(parentComp, 'InlineEditField')
                    app.Props.SelectedInputRef = parentComp;
                    parentComp.OnClick(event);
                end
            else
                % Initialize new selection boolean
                app.Props.SelectionMade = false;
            end
            % =========================================================
            % TRIGGER CALLBACKS
            event = AppEventData(event, 'eMouseDown');
            app_notify(app, {'eMouseDown'}, event);
        end

        % Window button up function: UIFigure
        function UIFigureWindowButtonUp(app, event)
            % =========================================================
            % SET STATE
            app.Props.IsMouseDown = false;
            % =========================================================
            % Close ColorPicker if its open
            if isfield(app.Cmps, 'ColorPicker') && ~strcmpi(event.Source.CurrentObject.Tag, 'color')
                if ~isempty(app.Cmps.ColorPicker)
                    delete(app.Cmps.ColorPicker)
                    app.Cmps.ColorPicker = [];
                end
            end
            % =========================================================
            % TRIGGER CALLBACKS
            event = AppEventData(event, 'eMouseUp');
            app_notify(app, {'eMouseUp'}, event);
            % =========================================================
            % SET MODAL FOR CREATING/UPDATING AN EVENT
            if app.Props.SelectionMade
                app.hModal(event, 'EventExcerpt');
            end
        end

        % Window button motion function: UIFigure
        function UIFigureWindowButtonMotion(app, ~)
            % =========================================================
            % USE THE DRAWNOW FCN TO ENABLE INTERUPTIONS
            drawnow();
            % =========================================================
            % TRIGGER CALLBACKS
            app_notify(app, {'eMouseMotion'});
        end

        % Window key press function: UIFigure
        function UIFigureWindowKeyPress(app, event)
            % =========================================================
            % TRIGGER CALLBACKS
            % ---------------------------------------------------------
            % If the user is editing an event-label, don't do anything yet
            if ~isempty(event.Source.CurrentObject)
                switch event.Source.CurrentObject.Tag
                    case 'EventExcerpt_Labels_GroupValue'
                        return
                end
            end
            % -------------------------------------------------------------
            % Check if arrow keys are pressed (then we need to update the selected segment)
            if length(app.Props.SelectedSegment) == 2
                switch event.Key
                    case 'rightarrow' % Increase onset
                        app.Props.SelectedSegment = app.Props.SelectedSegment + 1/(24*60);
                    case 'leftarrow' % Decrease onset
                        app.Props.SelectedSegment = app.Props.SelectedSegment - 1/(24*60);
                    case 'uparrow' % Increase duration
                        app.Props.SelectedSegment(2) = app.Props.SelectedSegment(2) + 1/(24*60);
                    case 'downarrow' % Decrease duration
                        if diff(app.Props.SelectedSegment) < 1/(24*60)
                            return % prevent negative duration
                        end
                        app.Props.SelectedSegment(2) = app.Props.SelectedSegment(2) - 1/(24*60);
                    otherwise
                        % do nothing
                end
            end
            % -------------------------------------------------------------
            event = AppEventData(event, {'eKeyPress', event.Key});
            app_notify(app, {'eKeyPress'}, event);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, ~)
            % -------------------------------------------------------------
            % Send telemetry data
            p = struct();
            p.status = 'stop';
            Telemetry.post('session', p)
            % -------------------------------------------------------------
            % Close the app
            delete(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [1 1 1024 768];
            app.UIFigure.Name = 'Cicada';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UIFigure.WindowButtonUpFcn = createCallbackFcn(app, @UIFigureWindowButtonUp, true);
            app.UIFigure.WindowButtonMotionFcn = createCallbackFcn(app, @UIFigureWindowButtonMotion, true);
            app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @UIFigureWindowKeyPress, true);
            app.UIFigure.Tag = 'Cicada';

            % Create Menu_File
            app.Menu_File = uimenu(app.UIFigure);
            app.Menu_File.Text = ' File ';

            % Create Menu_File_New
            app.Menu_File_New = uimenu(app.Menu_File);
            app.Menu_File_New.Text = 'New dataset';

            % Create Menu_File_New_GeneActiv
            app.Menu_File_New_GeneActiv = uimenu(app.Menu_File_New);
            app.Menu_File_New_GeneActiv.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_NewDatasetSelected, true);
            app.Menu_File_New_GeneActiv.Text = 'Import GeneActiv (.bin)';

            % Create Menu_File_New_Actigraph
            app.Menu_File_New_Actigraph = uimenu(app.Menu_File_New);
            app.Menu_File_New_Actigraph.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_NewDatasetSelected, true);
            app.Menu_File_New_Actigraph.Enable = 'off';
            app.Menu_File_New_Actigraph.Text = 'Import Actigraph (.gt3x)';

            % Create Menu_File_OpenDataset
            app.Menu_File_OpenDataset = uimenu(app.Menu_File);
            app.Menu_File_OpenDataset.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_OpenDatasetSelected, true);
            app.Menu_File_OpenDataset.Separator = 'on';
            app.Menu_File_OpenDataset.Accelerator = 'o';
            app.Menu_File_OpenDataset.Text = 'Open dataset (.mat)';

            % Create Menu_File_OpenRecent
            app.Menu_File_OpenRecent = uimenu(app.Menu_File);
            app.Menu_File_OpenRecent.Enable = 'off';
            app.Menu_File_OpenRecent.Text = 'Open recent';

            % Create Menu_File_CloseDataset
            app.Menu_File_CloseDataset = uimenu(app.Menu_File);
            app.Menu_File_CloseDataset.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_CloseDatasetSelected, true);
            app.Menu_File_CloseDataset.Enable = 'off';
            app.Menu_File_CloseDataset.Text = 'Close dataset';

            % Create Menu_File_SaveDataset
            app.Menu_File_SaveDataset = uimenu(app.Menu_File);
            app.Menu_File_SaveDataset.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_SaveDatasetSelected, true);
            app.Menu_File_SaveDataset.Enable = 'off';
            app.Menu_File_SaveDataset.Separator = 'on';
            app.Menu_File_SaveDataset.Accelerator = 's';
            app.Menu_File_SaveDataset.Text = 'Save dataset';

            % Create Menu_File_SaveDatasetAs
            app.Menu_File_SaveDatasetAs = uimenu(app.Menu_File);
            app.Menu_File_SaveDatasetAs.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_SaveDatasetAsSelected, true);
            app.Menu_File_SaveDatasetAs.Enable = 'off';
            app.Menu_File_SaveDatasetAs.Text = 'Save dataset as';

            % Create Menu_File_ImportOther
            app.Menu_File_ImportOther = uimenu(app.Menu_File);
            app.Menu_File_ImportOther.Enable = 'off';
            app.Menu_File_ImportOther.Separator = 'on';
            app.Menu_File_ImportOther.Text = 'Import other data';

            % Create Menu_File_ImportOther_NoOptions
            app.Menu_File_ImportOther_NoOptions = uimenu(app.Menu_File_ImportOther);
            app.Menu_File_ImportOther_NoOptions.Text = 'No options yet';

            % Create Menu_File_ImportEvents
            app.Menu_File_ImportEvents = uimenu(app.Menu_File);
            app.Menu_File_ImportEvents.Enable = 'off';
            app.Menu_File_ImportEvents.Text = 'Import events';

            % Create Menu_File_ImportEvents_SleepDiary
            app.Menu_File_ImportEvents_SleepDiary = uimenu(app.Menu_File_ImportEvents);
            app.Menu_File_ImportEvents_SleepDiary.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_ImportEvents_SleepDiarySelected, true);
            app.Menu_File_ImportEvents_SleepDiary.Text = 'Sleep diary';

            % Create Menu_File_Export
            app.Menu_File_Export = uimenu(app.Menu_File);
            app.Menu_File_Export.Enable = 'off';
            app.Menu_File_Export.Separator = 'on';
            app.Menu_File_Export.Text = 'Export';

            % Create Menu_File_Export_Metrics
            app.Menu_File_Export_Metrics = uimenu(app.Menu_File_Export);
            app.Menu_File_Export_Metrics.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_Export_MetricsSelected, true);
            app.Menu_File_Export_Metrics.Text = 'Epoched metrics';

            % Create Menu_File_Export_Stats
            app.Menu_File_Export_Stats = uimenu(app.Menu_File_Export);
            app.Menu_File_Export_Stats.Text = 'Statistics';

            % Create Menu_File_Export_Report
            app.Menu_File_Export_Report = uimenu(app.Menu_File_Export);
            app.Menu_File_Export_Report.Text = 'Report';

            % Create Menu_File_Export_Code
            app.Menu_File_Export_Code = uimenu(app.Menu_File_Export);
            app.Menu_File_Export_Code.Text = 'Matlab code';

            % Create Menu_File_Quit
            app.Menu_File_Quit = uimenu(app.Menu_File);
            app.Menu_File_Quit.MenuSelectedFcn = createCallbackFcn(app, @Menu_File_QuitSelected, true);
            app.Menu_File_Quit.Separator = 'on';
            app.Menu_File_Quit.Text = 'Quit';

            % Create Menu_Edit
            app.Menu_Edit = uimenu(app.UIFigure);
            app.Menu_Edit.Enable = 'off';
            app.Menu_Edit.Text = ' Edit ';

            % Create Menu_Edit_Info
            app.Menu_Edit_Info = uimenu(app.Menu_Edit);
            app.Menu_Edit_Info.Text = 'Dataset info';

            % Create Menu_Edit_Select
            app.Menu_Edit_Select = uimenu(app.Menu_Edit);
            app.Menu_Edit_Select.Separator = 'on';
            app.Menu_Edit_Select.Text = 'Select data';

            % Create Menu_Edit_ChangeTime
            app.Menu_Edit_ChangeTime = uimenu(app.Menu_Edit);
            app.Menu_Edit_ChangeTime.Text = 'Change time zone';

            % Create Menu_Edit_ChangeEpoch
            app.Menu_Edit_ChangeEpoch = uimenu(app.Menu_Edit);
            app.Menu_Edit_ChangeEpoch.Text = 'Change epoch length';

            % Create Menu_Preproc
            app.Menu_Preproc = uimenu(app.UIFigure);
            app.Menu_Preproc.Enable = 'off';
            app.Menu_Preproc.Text = ' Preprocess ';

            % Create Menu_Preproc_Calibrate
            app.Menu_Preproc_Calibrate = uimenu(app.Menu_Preproc);
            app.Menu_Preproc_Calibrate.Text = 'Calibrate (GGIR)';

            % Create Menu_Preproc_NonWear
            app.Menu_Preproc_NonWear = uimenu(app.Menu_Preproc);
            app.Menu_Preproc_NonWear.Text = 'Non-wear detection (GGIR)';

            % Create Menu_Analysis
            app.Menu_Analysis = uimenu(app.UIFigure);
            app.Menu_Analysis.Enable = 'off';
            app.Menu_Analysis.Text = ' Analysis ';

            % Create Menu_Analysis_Annot
            app.Menu_Analysis_Annot = uimenu(app.Menu_Analysis);
            app.Menu_Analysis_Annot.Text = 'Annotate epochs';

            % Create Menu_Analysis_Annot_Accelaration
            app.Menu_Analysis_Annot_Accelaration = uimenu(app.Menu_Analysis_Annot);
            app.Menu_Analysis_Annot_Accelaration.Text = 'Acceleration';

            % Create Menu_Analysis_Annot_Light
            app.Menu_Analysis_Annot_Light = uimenu(app.Menu_Analysis_Annot);
            app.Menu_Analysis_Annot_Light.Text = 'Light';

            % Create Menu_Analysis_Events
            app.Menu_Analysis_Events = uimenu(app.Menu_Analysis);
            app.Menu_Analysis_Events.Text = 'Events';

            % Create Menu_Analysis_Events_Daily
            app.Menu_Analysis_Events_Daily = uimenu(app.Menu_Analysis_Events);
            app.Menu_Analysis_Events_Daily.Text = 'Create daily events';

            % Create Menu_Analysis_Events_Relative
            app.Menu_Analysis_Events_Relative = uimenu(app.Menu_Analysis_Events);
            app.Menu_Analysis_Events_Relative.Text = 'Create relative events';

            % Create Menu_Analysis_Events_SleepWin
            app.Menu_Analysis_Events_SleepWin = uimenu(app.Menu_Analysis_Events);
            app.Menu_Analysis_Events_SleepWin.Separator = 'on';
            app.Menu_Analysis_Events_SleepWin.Text = 'Sleep window detection (GGIR)';

            % Create Menu_Help
            app.Menu_Help = uimenu(app.UIFigure);
            app.Menu_Help.Text = ' Help ';

            % Create Menu_Help_About
            app.Menu_Help_About = uimenu(app.Menu_Help);
            app.Menu_Help_About.Text = 'About';

            % Create EditregistrationMenu
            app.EditregistrationMenu = uimenu(app.Menu_Help);
            app.EditregistrationMenu.MenuSelectedFcn = createCallbackFcn(app, @Menu_Help_EditRegistration, true);
            app.EditregistrationMenu.Text = 'Edit registration';

            % Create Menu_Help_Documentation
            app.Menu_Help_Documentation = uimenu(app.Menu_Help);
            app.Menu_Help_Documentation.MenuSelectedFcn = createCallbackFcn(app, @Menu_Help_DocumentationSelected, true);
            app.Menu_Help_Documentation.Text = 'Online documentation';

            % Create Menu_Help_Bugs
            app.Menu_Help_Bugs = uimenu(app.Menu_Help);
            app.Menu_Help_Bugs.MenuSelectedFcn = createCallbackFcn(app, @Menu_Help_BugsSelected, true);
            app.Menu_Help_Bugs.Separator = 'on';
            app.Menu_Help_Bugs.Text = 'Submit bug report';

            % Create MainGridLayout
            app.MainGridLayout = uigridlayout(app.UIFigure);
            app.MainGridLayout.ColumnWidth = {'1x'};
            app.MainGridLayout.RowHeight = {'1x'};
            app.MainGridLayout.ColumnSpacing = 0;
            app.MainGridLayout.RowSpacing = 0;
            app.MainGridLayout.Padding = [0 0 0 0];

            % Create MainPanel
            app.MainPanel = uipanel(app.MainGridLayout);
            app.MainPanel.BorderType = 'none';
            app.MainPanel.Layout.Row = 1;
            app.MainPanel.Layout.Column = 1;

            % Create ContentGridLayout
            app.ContentGridLayout = uigridlayout(app.MainPanel);
            app.ContentGridLayout.ColumnWidth = {200, '1x', 250};
            app.ContentGridLayout.RowHeight = {'1x'};
            app.ContentGridLayout.ColumnSpacing = 0;
            app.ContentGridLayout.RowSpacing = 3;
            app.ContentGridLayout.Padding = [0 0 0 0];
            app.ContentGridLayout.BackgroundColor = [0.9137 0.9255 0.9373];

            % Create InfoPanel
            app.InfoPanel = uipanel(app.ContentGridLayout);
            app.InfoPanel.ForegroundColor = [1 1 1];
            app.InfoPanel.BackgroundColor = [0.6392 0.8118 0.7294];
            app.InfoPanel.Layout.Row = 1;
            app.InfoPanel.Layout.Column = 1;
            app.InfoPanel.FontWeight = 'bold';
            app.InfoPanel.FontSize = 11;

            % Create InfoGridLayout
            app.InfoGridLayout = uigridlayout(app.InfoPanel);
            app.InfoGridLayout.ColumnWidth = {'1x'};
            app.InfoGridLayout.RowHeight = {1, 75, 1, 76, 178, 76, '1x'};
            app.InfoGridLayout.ColumnSpacing = 3;
            app.InfoGridLayout.RowSpacing = 3;
            app.InfoGridLayout.Padding = [3 3 3 3];
            app.InfoGridLayout.BackgroundColor = [0.6392 0.8118 0.7294];

            % Create CicadaLogo
            app.CicadaLogo = uiimage(app.InfoGridLayout);
            app.CicadaLogo.Layout.Row = 2;
            app.CicadaLogo.Layout.Column = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = cicada_exported

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
