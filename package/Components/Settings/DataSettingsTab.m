% DATASETTINGSTAB
% Shows visualization settings in 'ACT.etc.display'.

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

classdef DataSettingsTab < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Metric;
        Settings;
        NumModalities = 0;
        NumEventGroups = 0;
        Modalities;
        RowHeights;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
        KeyLabels matlab.ui.control.Label
        ValueLabels matlab.ui.control.Label
        Input matlab.ui.control.EditField
        ExportButton ExportButton
        ActogramSettings DataSettings_Actogram
        ModalitySettings DataSettings_Modality
        EventSettings EventGroupPanel
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            Colors = app_colors();
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.Tag = 'DataSettingsTab';
            Obj.BackgroundColor = Colors.bg_primary;
            Obj.GridLayout = uigridlayout(Obj, ...
                'Tag', 'DataSettingsTab_GridLayout', ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {24, 85, 85}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_primary);
            % Button to export the actogram
            Obj.ExportButton = ExportButton(Obj.GridLayout, ...
                'Text', 'EXPORT ACTOGRAM', ...
                'TargetTag', 'DataTab'); %#ok<PROP>
            % Event settings panel
            Obj.EventSettings = EventGroupPanel(Obj.GridLayout, 'Verbose', Obj.Verbose);
            Obj.EventSettings.Layout.Row = 2;
            Obj.EventSettings.Layout.Column = 1;
            app_addlisteners([], Obj.EventSettings, ...
                {'eDatasetChanged', 'eDataChanged'});
        end
        % =================================================================
        function Subset = getModalityMetrics(Obj, Modality)
            % -------------------------------------------------------------
            % Extract subset
            Subset = Obj.Metric(strcmpi({Obj.Metric.modality}, Modality));
            % Sort by Z-index
            [~, idx] = sort([Subset.zindex], 'descend');
            Subset = Subset(idx);
        end
        % =================================================================
        function update(Obj)
            try
                % -------------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % -------------------------------------------------------------
                h = Obj.NumEventGroups;
                h = h*26 + (h+1)*Obj.EventSettings.GridLayout.RowSpacing + 12;
                if Obj.NumEventGroups == 0
                    h = 161;
                end
                Obj.GridLayout.RowHeight = [{24}, repmat({85}, 1, Obj.NumModalities+1), {h}];
                % -------------------------------------------------------------
                % Display settings for the actogram
                if isempty(Obj.ActogramSettings)
                    Obj.ActogramSettings = DataSettings_Actogram(Obj.GridLayout, 'Verbose', Obj.Verbose, 'Settings', Obj.Settings);
                    Obj.ActogramSettings.Layout.Column = 1;
                    Obj.ActogramSettings.Layout.Row = 2;
                else
                    Obj.ActogramSettings.Settings = Obj.Settings;
                end
                % -------------------------------------------------------------
                % First delete any excess modality-settings panels
                delete(Obj.ModalitySettings(Obj.NumModalities+1:end));
                Obj.ModalitySettings(Obj.NumModalities+1:end) = [];
                % -------------------------------------------------------------
                % Create or update modality-settings panels
                for i = 1:Obj.NumModalities
                    % ---------------------------------------------------------
                    % Check if the panel should be rendered or not
                    DoRender = false;
                    if i > length(Obj.ModalitySettings)
                        DoRender = true;
                    elseif ~isvalid(Obj.ModalitySettings(i))
                        DoRender = true;
                    end
                    % ---------------------------------------------------------
                    if DoRender % Render the panel
                        Obj.ModalitySettings(i) = DataSettings_Modality(Obj.GridLayout, 'Verbose', Obj.Verbose);
                        Obj.ModalitySettings(i).Layout.Column = 1;
                        Obj.ModalitySettings(i).Layout.Row = i+2;
                    end
                    % Set the properties and update will be called automatically
                    Obj.ModalitySettings(i).Modality = Obj.Modalities{i};
                    Obj.ModalitySettings(i).Metric = Obj.getModalityMetrics(Obj.Modalities{i});
                    % ---------------------------------------------------------
                    % Set the gridlayout height
                    Obj.GridLayout.RowHeight{i+2} = 70 + 21*length(Obj.ModalitySettings(i).Metric);
                end
                % -------------------------------------------------------------
                Obj.EventSettings.Layout.Row = Obj.NumModalities+3;
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DataSettingsTab updated in %.1g s.\n', (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DataSettingsTab.m')
            end
        end
    end
    % *********************************************************************
    methods (Access = public)
        % -----------------------------------------------------------------
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                if isempty(app.ACT)
                    Obj.Settings = [];
                    Obj.Metric = struct([]);
                    Obj.NumModalities = 0;
                    Obj.NumEventGroups = 0;
                    Obj.Modalities = {};
                    Obj.RowHeights = [];
                else
                    idx = ismember(app.ACT.analysis.events.Properties.VariableNames, {'label', 'type'});
                    Obj.Settings = app.ACT.info.actogram;
                    Obj.Metric = app.ACT.metric;
                    Obj.NumModalities = length(app.ACT.info.modalities);
                    Obj.NumEventGroups = size(unique(app.ACT.analysis.events(:, idx)), 1);
                    Obj.Modalities = unique(fliplr({app.ACT.metric.modality}), 'stable');
                    Obj.RowHeights = [];
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in DataSettingsTab.m')
            end
        end
    end
end