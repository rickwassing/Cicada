% EVENTGROUP
% A list item to show the event group label, and edit/delete it.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-11-0, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef EventGroup < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        LabelText;
        TypeText;
        NumEvents;
        DoShow;
        Color;
        IsSelected = false;
        EditStatus = false;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        LabelObj matlab.ui.control.Label
        TypeObj matlab.ui.control.Label
        Input matlab.ui.control.EditField
        Badge matlab.ui.control.Label
        ShowCheckbox matlab.ui.control.CheckBox
        ColorPicker matlab.ui.control.Button
        EditSaveButton matlab.ui.control.Button
        DeleteUndoButton matlab.ui.control.Button
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
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'EventGroup_Panel', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', [1, 1, 1], ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'EventGroup_GridLayout', ...
                'ColumnWidth', {18, '1x', '1x', 18, 18, 18, 18}, ...
                'RowHeight', {18}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            Obj.ColorPicker = uibutton(Obj.GridLayout, ...
                'Text', '', ...
                'BackgroundColor', [0.94, 0.94, 0.94], ...
                'Tooltip', 'Change color', ...
                'ButtonPushedFcn', @(~, event) Obj.OpenColorPicker(event));
            Obj.ColorPicker.Layout.Row = 1;
            Obj.ColorPicker.Layout.Column = 1;
            % -------------------------------------------------------------
            Obj.LabelObj = uilabel(Obj.GridLayout, ...
                'Text', '<label>', ...
                'FontColor', Colors.body_primary, ...
                'FontWeight', 'bold', ...
                'FontSize', 10);
            Obj.LabelObj.Layout.Column = 2;
            Obj.LabelObj.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.Input = uieditfield(Obj.GridLayout, ...
                'Value', '<label>', ...
                'Visible', 'off', ...
                'FontSize', 10);
            Obj.Input.Layout.Column = 2;
            Obj.Input.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.TypeObj = uilabel(Obj.GridLayout, ...
                'Text', '<type>', ...
                'FontSize', 10);
            Obj.TypeObj.Layout.Column = 3;
            Obj.TypeObj.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.Badge = uilabel(Obj.GridLayout, ...
                'Text', 'n', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 8);
            Obj.Badge.Layout.Column = 4;
            Obj.Badge.Layout.Row = 1;
            % -------------------------------------------------------------
            % Checkbox for show/hide
            Obj.ShowCheckbox = uicheckbox(Obj.GridLayout, ...
                'Text', '', ...
                'Tag', 'show', ...
                'Value', 1, ...
                'Tooltip', 'Show', ...
                'ValueChangedFcn', @(~, event) disp('show'));
            Obj.ShowCheckbox.Layout.Column = 5;
            Obj.ShowCheckbox.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.EditSaveButton = uibutton(Obj.GridLayout, ...
                'Text', '', ...
                'BackgroundColor', Colors.body_secondary, ...
                'Tooltip', 'Edit', ...
                'Icon', 'icon-edit.png', ...
                'ButtonPushedFcn', @(~, event) Obj.ToggleEditStatus());
            Obj.EditSaveButton.Layout.Column = 6;
            Obj.EditSaveButton.Layout.Row = 1;
            % -------------------------------------------------------------
            % TODO: this button does not do anything yet...
            Obj.DeleteUndoButton = uibutton(Obj.GridLayout, ...
                'Text', '', ...
                'BackgroundColor', Colors.bs_danger, ...
                'Tooltip', 'Delete event group', ...
                'Icon', 'icon-trash.png', ...
                'ButtonPushedFcn', @(~, event) disp('delete group'));
            Obj.DeleteUndoButton.Layout.Column = 7;
            Obj.DeleteUndoButton.Layout.Row = 1;
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                Colors = app_colors();
                Obj.Tag = ['EventGroup_label-', Obj.LabelText, '_type-', Obj.TypeText];
                % TODO: think about the enable/disable rules
                Obj.EditSaveButton.Enable = ifelse(strcmpi(Obj.TypeText, 'custom'), 'on', 'off');
                Obj.ColorPicker.UserData = {'Obj', Obj, 'Method', 'color', 'Label', Obj.LabelText, 'Type', Obj.TypeText};
                Obj.ColorPicker.BackgroundColor = Obj.Color;
                Obj.LabelObj.Text = Obj.LabelText;
                Obj.Input.Value = Obj.LabelText;
                Obj.TypeObj.Text = Obj.TypeText;
                Obj.Badge.Text = ['(', num2str(Obj.NumEvents), ')'];
                % TODO: this checkbox does not do anything yet...
                Obj.ShowCheckbox.Value = Obj.DoShow;
                if Obj.EditStatus
                    Obj.LabelObj.Visible = 'off';
                    Obj.Input.Visible = 'on';
                    Obj.EditSaveButton.Icon = 'icon-save.png';
                    Obj.DeleteUndoButton.Icon = 'icon-undo.png';
                    Obj.EditSaveButton.Tooltip = 'Save';
                    Obj.DeleteUndoButton.Tooltip = 'Undo';
                    Obj.EditSaveButton.BackgroundColor = Colors.bs_success;
                    Obj.DeleteUndoButton.BackgroundColor = Colors.body_secondary;
                else
                    Obj.LabelObj.Visible = 'on';
                    Obj.Input.Visible = 'off';
                    Obj.EditSaveButton.Icon = 'icon-edit.png';
                    Obj.DeleteUndoButton.Icon = 'icon-trash.png';
                    Obj.EditSaveButton.Tooltip = 'Edit';
                    Obj.DeleteUndoButton.Tooltip = 'Delete event group';
                    Obj.EditSaveButton.BackgroundColor = Colors.body_secondary;
                    Obj.DeleteUndoButton.BackgroundColor = Colors.bs_danger;
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: EventGroup updated in %.1g s.\n', (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in EventGroup.m')
            end
        end
        % =================================================================
        function ToggleEditStatus(Obj)
            Obj.EditStatus = ~Obj.EditStatus;
        end
        % =================================================================
        function OpenColorPicker(Obj, event)
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
                    'UserData', event.Source.UserData); %#ok<CPROPLC>
            end
            app.Cmps.ColorPicker.Fcn = 'set_event';
            app.Cmps.ColorPicker.EventName = {'eDataChanged'};
            app.Cmps.ColorPicker.UserData = {'Obj', Obj, 'Method', 'setcolor', 'EventGroup', Obj.LabelText, 'EventType', Obj.TypeText};
            app.Cmps.ColorPicker.Position = [app.UIFigure.CurrentPoint, 131, 68] - [85, 86, 0, 0];
        end
    end
end