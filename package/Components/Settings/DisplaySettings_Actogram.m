% DISPLAYSETTINGS_ACTOGRAM
% Shows visualization settings for the actogram 'ACT.etc.display'.

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

classdef DisplaySettings_Actogram < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Settings;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        KeyLabels matlab.ui.control.Label
        UnitLabels matlab.ui.control.Label
        Inputs
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
            Obj.Tag = 'DisplaySettingsActogram';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'DisplaySettingsActogram_Panel', ...
                'Title', 'ACTOGRAM', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'DisplaySettingsActogram_GridLayout', ...
                'ColumnWidth', {36, '1x', '1x', 36}, ...
                'RowHeight', {18, 18, 18}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            % Input field for length
            Obj.KeyLabels(1) = uilabel(Obj.GridLayout, ...
                'Text', 'Length', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.KeyLabels(1).Layout.Column = 1;
            Obj.KeyLabels(1).Layout.Row = 1;
            Obj.Inputs(1).h = uidropdown(Obj.GridLayout, ...
                'Tag', 'length', ...
                'Value', '5', ...
                'Items', {'3', '5', '7', '10', '14', '21', '28', '31', '60', '90', 'all'}, ...
                'FontSize', 10, ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_actogram', {'eActogramSettingsChanged'}));
            Obj.Inputs(1).h.Layout.Column = [2, 3];
            Obj.Inputs(1).h.Layout.Row = 1;
            Obj.UnitLabels(1) = uilabel(Obj.GridLayout, ...
                'Text', 'days', ...
                'FontColor', Colors.body_secondary, ...
                'FontSize', 10);
            Obj.UnitLabels(1).Layout.Column = 4;
            Obj.UnitLabels(1).Layout.Row = 1;
            % -------------------------------------------------------------
            % Input field for single or double plot
            Obj.KeyLabels(2) = uilabel(Obj.GridLayout, ...
                'Text', 'Width', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.KeyLabels(2).Layout.Column = 1;
            Obj.KeyLabels(2).Layout.Row = 2;
            Obj.Inputs(2).h = uidropdown(Obj.GridLayout, ...
                'Tag', 'width', ...
                'Value', 'single', ...
                'Items', {'single', 'double'}, ...
                'FontSize', 10, ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_actogram', {'eActogramSettingsChanged', 'eDisplaySettingsChanged'}));
            Obj.Inputs(2).h.Layout.Column = [2, 3];
            Obj.Inputs(2).h.Layout.Row = 2;
            % -------------------------------------------------------------
            % Input field for clock start and end times
            Obj.KeyLabels(3) = uilabel(Obj.GridLayout, ...
                'Text', 'Clock', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.KeyLabels(3).Layout.Column = 1;
            Obj.KeyLabels(3).Layout.Row = 3;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Inputs(3).h = uidropdown(Obj.GridLayout, ...
                'Tag', 'clockstart', ...
                'Value', '15:00', ...
                'Items', {'00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'}, ...
                'FontSize', 10, ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_actogram', {'eActogramSettingsChanged', 'eDisplaySettingsChanged'}));
            Obj.Inputs(3).h.Layout.Column = 2;
            Obj.Inputs(3).h.Layout.Row = 3;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Inputs(4).h = uidropdown(Obj.GridLayout, ...
                'Tag', 'clockend', ...
                'Value', '15:00', ...
                'Items', {'00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'}, ...
                'FontSize', 10, ...
                'ValueChangedFcn', @(~, event) app_callback(event, 'set_actogram', {'eActogramSettingsChanged', 'eDisplaySettingsChanged'}));
            Obj.Inputs(4).h.Layout.Column = 3;
            Obj.Inputs(4).h.Layout.Row = 3;
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                if isempty(Obj.Settings)
                    return
                end
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                Value = num2str(Obj.Settings.length);
                if ismember(Value, Obj.Inputs(1).h.Items)
                    Obj.Inputs(1).h.Value = Value;
                else
                    Obj.Inputs(1).h.Value = 'all';
                end
                % ---------------------------------------------------------
                Value = Obj.Settings.width;
                if ismember(Value, Obj.Inputs(2).h.Items)
                    Obj.Inputs(2).h.Value = Value;
                else
                    Obj.Inputs(2).h.Value = 'single';
                end
                % ---------------------------------------------------------
                Value = Obj.Settings.start;
                if ismember(Value, Obj.Inputs(3).h.Items)
                    Obj.Inputs(3).h.Value = Value;
                else
                    Obj.Inputs(3).h.Value = '15:00';
                end
                % ---------------------------------------------------------
                Value = Obj.Settings.end;
                if ismember(Value, Obj.Inputs(4).h.Items)
                    Obj.Inputs(4).h.Value = Value;
                else
                    Obj.Inputs(4).h.Value = '15:00';
                end
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DisplaySettingsActogram updated in %.1g s.\n', (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DisplaySettings_Actogram.m')
            end
        end
    end
end