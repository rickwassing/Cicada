% DISPLAYSETTINGS_MODALITY
% Shows visualization settings for a single modality.

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

classdef DisplaySettings_Modality < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Modality;
        Metric = struct('y', [], 'modality', '', 'device', '', 'labels', {}, 'srate', [], 'pnts', [], 'xmin', '', 'xmax', '', 'showSingleMetric', [], 'show', [], 'height', [], 'log', [], 'ylim', [], 'color', [], 'zindex', []);
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        TracePanel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        TraceGridLayout matlab.ui.container.GridLayout
        KeyLabels matlab.ui.control.Label
        UnitLabels matlab.ui.control.Label
        Inputs
        Buttons
        TraceLabels matlab.ui.control.Label
        TraceCheckboxes matlab.ui.control.CheckBox
        TraceColorPickers matlab.ui.control.Button
        TraceMoveUpButtons matlab.ui.control.Button
        TraceMoveDownButtons matlab.ui.control.Button
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
            Obj.Tag = 'DisplaySettingsModality';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'DisplaySettingsModality_Panel', ...
                'Title', '...', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'DisplaySettingsModality_GridLayout', ...
                'ColumnWidth', {36, '1x', '1x', 48}, ...
                'RowHeight', {18, 18, 20}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            % Input field for length
            Obj.KeyLabels(1) = uilabel(Obj.GridLayout, ...
                'Text', 'Height', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.KeyLabels(1).Layout.Column = 1;
            Obj.KeyLabels(1).Layout.Row = 1;
            Obj.Inputs(1).h = uispinner(Obj.GridLayout, ...
                'Tag', 'height', ...
                'Value', 1, ...
                'ValueDisplayFormat', '%i', ...
                'RoundFractionalValues', 'on', ...
                'Step', 1, ...
                'Limits', [1, Inf], ...
                'FontSize', 10, ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'}));
            Obj.Inputs(1).h.Layout.Column = [2, 3];
            Obj.Inputs(1).h.Layout.Row = 1;
            % -------------------------------------------------------------
            % Input fields for range limits
            Obj.KeyLabels(2) = uilabel(Obj.GridLayout, ...
                'Text', 'Range', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.KeyLabels(2).Layout.Column = 1;
            Obj.KeyLabels(2).Layout.Row = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Inputs(2).h = uieditfield(Obj.GridLayout, 'numeric', ...
                'Tag', 'ymin', ...
                'Value', 0, ...
                'FontSize', 10, ...
                'Limits', [-Inf, Inf], ...
                'UpperLimitInclusive', 'off', ...
                'RoundFractionalValues','off', ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'}));
            Obj.Inputs(2).h.Layout.Column = 2;
            Obj.Inputs(2).h.Layout.Row = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Inputs(3).h = uieditfield(Obj.GridLayout, 'numeric', ...
                'Tag', 'ymax', ...
                'Value', 1, ...
                'FontSize', 10, ...
                'Limits', [-Inf, Inf], ...
                'LowerLimitInclusive', 'off', ...
                'RoundFractionalValues','off', ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'}));
            Obj.Inputs(3).h.Layout.Column = 3;
            Obj.Inputs(3).h.Layout.Row = 2;
            % -------------------------------------------------------------
            % Checkbox for linear/log
            Obj.Inputs(4).h = uicheckbox(Obj.GridLayout, ...
                'Tag', 'log', ...
                'Value', 0, ...
                'Text', 'log', ...
                'FontSize', 10, ...
                'WordWrap', 'off', ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'}));
            Obj.Inputs(4).h.Layout.Column = 4;
            Obj.Inputs(4).h.Layout.Row = 2;
            % -------------------------------------------------------------
            % Sub-panel for data trace settings
            Obj.TracePanel = uipanel(Obj.GridLayout, ...
                'Tag', 'DisplaySettingsModality_SubPanel', ...
                'Title', '', ...
                'BackgroundColor', [1, 1, 1], ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Position', [0, 0, 1, 1]);
            Obj.TracePanel.Layout.Column = [1, 4];
            Obj.TracePanel.Layout.Row = 3;
            Obj.TraceGridLayout = uigridlayout(Obj.TracePanel, ...
                'Tag', 'DisplaySettingsModality_SubGridLayout', ...
                'ColumnWidth', {'1x', 42, 18, 18, 18}, ...
                'RowHeight', {18}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', [1, 1, 1]);
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                Colors = app_colors();
                % ---------------------------------------------------------
                Obj.Panel.Title = upper(Obj.Modality);
                % ---------------------------------------------------------
                % Set values of the input to the correct parameter value
                Obj.Inputs(1).h.Value = Obj.Metric(1).height;
                Obj.Inputs(2).h.Value = min([Obj.Metric([Obj.Metric.show]).ymin]);
                Obj.Inputs(3).h.Value = max([Obj.Metric([Obj.Metric.show]).ymax]);
                Obj.Inputs(4).h.Value = any([Obj.Metric.log]);
                % ---------------------------------------------------------
                % Set limits for range inputs
                Obj.Inputs(2).h.Limits = [-Inf, max([Obj.Metric([Obj.Metric.show]).ymax])];
                Obj.Inputs(3).h.Limits = [min([Obj.Metric([Obj.Metric.show]).ymin]), Inf];
                % ---------------------------------------------------------
                % Set user data so the callback function gets the parameters
                Obj.Inputs(1).h.UserData = {'Metric', Obj.Metric};
                Obj.Inputs(4).h.UserData = {'Metric', Obj.Metric};
                if strcmpi(Obj.Modality, 'ACCEL')
                    Obj.Inputs(2).h.UserData = {'Metric', Obj.Metric([Obj.Metric.show]), 'Obj', Obj};
                    Obj.Inputs(3).h.UserData = {'Metric', Obj.Metric([Obj.Metric.show]), 'Obj', Obj};
                else
                    Obj.Inputs(2).h.UserData = {'Metric', Obj.Metric, 'Obj', Obj};
                    Obj.Inputs(3).h.UserData = {'Metric', Obj.Metric, 'Obj', Obj};
                end
                % ---------------------------------------------------------
                Obj.GridLayout.RowHeight = {18, 18, 5+21*length(Obj.Metric)};
                Obj.TraceGridLayout.ColumnWidth = {'1x', 42, 18, 18, 18};
                Obj.TraceGridLayout.RowHeight = repmat({18}, 1, length(Obj.Metric));
                for i = 1:length(Obj.Metric)
                    % -----------------------------------------------------
                    % Label
                    DoRender = false;
                    if i > length(Obj.TraceLabels)
                        DoRender = true;
                    elseif ~isvalid(Obj.TraceLabels(i))
                        DoRender = true;
                    end
                    if DoRender
                        Obj.TraceLabels(i) = uilabel(Obj.TraceGridLayout, ...
                            'Text', Obj.Metric(i).label, ...
                            'WordWrap', 'off', ...
                            'FontSize', 10, ...
                            'Tooltip', [Obj.Metric(i).device, ' ', Obj.Metric(i).loc, ' ', Obj.Metric(i).label]);
                        Obj.TraceLabels(i).Layout.Row = i;
                        Obj.TraceLabels(i).Layout.Column = 1;
                    else
                        Obj.TraceLabels(i).Text = Obj.Metric(i).label;
                        Obj.TraceLabels(i).Tooltip = [Obj.Metric(i).device, ' ', Obj.Metric(i).loc, ' ', Obj.Metric(i).label];
                    end
                    % -----------------------------------------------------
                    % Checkbox for show/hide
                    DoRender = false;
                    if i > length(Obj.TraceCheckboxes)
                        DoRender = true;
                    elseif ~isvalid(Obj.TraceCheckboxes(i))
                        DoRender = true;
                    end
                    if DoRender
                        Obj.TraceCheckboxes(i) = uicheckbox(Obj.TraceGridLayout, ...
                            'Tag', 'show', ...
                            'Value', Obj.Metric(i).show, ...
                            'Text', 'show', ...
                            'FontSize', 10, ...
                            'WordWrap', 'off', ...
                            'UserData', {'Metric', Obj.Metric(i)}, ...
                            'ValueChangedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'}));
                        Obj.TraceCheckboxes(i).Layout.Row = i;
                        Obj.TraceCheckboxes(i).Layout.Column = 2;
                    else
                        Obj.TraceCheckboxes(i).Value = Obj.Metric(i).show;
                        Obj.TraceCheckboxes(i).UserData = {'Metric', Obj.Metric(i)};
                    end
                    % -----------------------------------------------------
                    % Color button
                    DoRender = false;
                    if i > length(Obj.TraceColorPickers)
                        DoRender = true;
                    elseif ~isvalid(Obj.TraceColorPickers(i))
                        DoRender = true;
                    end
                    if DoRender
                        Obj.TraceColorPickers(i) = uibutton(Obj.TraceGridLayout, ...
                            'Text', '', ...
                            'BackgroundColor', Obj.Metric(i).color, ...
                            'Tooltip', 'Change color', ...
                            'ButtonPushedFcn', @(~, event) Obj.OpenColorPicker(event));
                        Obj.TraceColorPickers(i).Layout.Row = i;
                        Obj.TraceColorPickers(i).Layout.Column = 3;
                        Obj.TraceColorPickers(i).UserData = {'Metric', Obj.Metric(i), 'Obj', Obj};
                    else
                        Obj.TraceColorPickers(i).BackgroundColor = Obj.Metric(i).color;
                        Obj.TraceColorPickers(i).UserData = {'Metric', Obj.Metric(i), 'Obj', Obj};
                    end
                    % -----------------------------------------------------
                    % Increase Z-index
                    DoRender = false;
                    if i > length(Obj.TraceMoveUpButtons)
                        DoRender = true;
                    elseif ~isvalid(Obj.TraceMoveUpButtons(i))
                        DoRender = true;
                    end
                    if DoRender && ~strcmpi(Obj.Modality, 'ACCEL')
                        Obj.TraceMoveUpButtons(i) = uibutton(Obj.TraceGridLayout, ...
                            'Tag', 'moveup', ...
                            'Text', '▲', ...
                            'FontSize', 7, ...
                            'VerticalAlignment', 'top', ...
                            'BackgroundColor', Colors.bg_primary, ...
                            'Tooltip', 'Move up', ...
                            'Enable', ifelse(i == 1, 'off', 'on'), ...
                            'UserData', {'Metric', Obj.Metric(i), 'Obj', Obj}, ...
                            'ButtonPushedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'}));
                        Obj.TraceMoveUpButtons(i).Layout.Row = i;
                        Obj.TraceMoveUpButtons(i).Layout.Column = 4;
                    elseif ~strcmpi(Obj.Modality, 'ACCEL')
                        Obj.TraceMoveUpButtons(i).Enable = ifelse(i == 1, 'off', 'on');
                        Obj.TraceMoveUpButtons(i).UserData = {'Metric', Obj.Metric(i), 'Obj', Obj};
                    end
                    % -----------------------------------------------------
                    % Decrease Z-index
                    DoRender = false;
                    if i > length(Obj.TraceMoveDownButtons)
                        DoRender = true;
                    elseif ~isvalid(Obj.TraceMoveDownButtons(i))
                        DoRender = true;
                    end
                    if DoRender && ~strcmpi(Obj.Modality, 'ACCEL')
                        Obj.TraceMoveDownButtons(i) = uibutton(Obj.TraceGridLayout, ...
                            'Tag', 'movedown', ...
                            'Text', '▼', ...
                            'FontSize', 7, ...
                            'VerticalAlignment', 'bottom', ...
                            'BackgroundColor', Colors.bg_primary, ...
                            'Tooltip', 'Move down', ...
                            'Enable', ifelse(i == length(Obj.Metric), 'off', 'on'), ...
                            'UserData', {'Metric', Obj.Metric(i), 'Obj', Obj}, ...
                            'ButtonPushedFcn', @(~, event) app_callback(event, 'set_display', {'eDisplaySettingsChanged'})); % TODO: convert all these to a this ibject's method and place source.userdata into event.UserData.Payload
                        Obj.TraceMoveDownButtons(i).Layout.Row = i;
                        Obj.TraceMoveDownButtons(i).Layout.Column = 5;
                    elseif ~strcmpi(Obj.Modality, 'ACCEL')
                        Obj.TraceMoveDownButtons(i).Enable = ifelse(i == length(Obj.Metric), 'off', 'on');
                        Obj.TraceMoveDownButtons(i).UserData = {'Metric', Obj.Metric(i), 'Obj', Obj};
                    end
                end
                % ---------------------------------------------------------
                % For ACCEL modalities, add the object handle because
                % only one data trace can be checked at any time
                if strcmpi(Obj.Modality, 'ACCEL')
                    for i = 1:length(Obj.TraceCheckboxes)
                        Obj.TraceCheckboxes(i).UserData = {'Metric', Obj.Metric(i), 'Obj', Obj};
                    end
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DisplaySettingsModality ''%s'' updated in %.1g s.\n', Obj.Modality, (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DisplaySettings_Modality.m')
            end
        end
        % =================================================================
        function OpenColorPicker(Obj, event) %#ok<INUSD>
            % Get handle to the app
            app = app_gethandle();
            if isempty(app)
                return;
            end
            % Check if we need to render the colorpicker
            DoRender = false;
            if isfield(app.Cmps, 'ColorPicker')
                if isempty(app.Cmps.ColorPicker) || ~isvalid(app.Cmps.ColorPicker)
                    DoRender = true;
                end
            else
                DoRender = true;
            end
            if DoRender
                app.Cmps.ColorPicker = ColorPicker(app.UIFigure, ...
                    'UserData', event.Source.UserData);
            end
            app.Cmps.ColorPicker.Fcn = 'set_display';
            app.Cmps.ColorPicker.EventName = {'eDisplaySettingsChanged'};
            app.Cmps.ColorPicker.Position = [app.UIFigure.CurrentPoint, 131, 68] - [85, 86, 0, 0];
        end
    end
end