% COLORPICKER
% Shows an interface to change the data-trace color settings 

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-08-10, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ColorPicker < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Fcn;
        EventName;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        Buttons
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            Colors = app_colors();
            Names = {'teal', 'blue', 'violet', 'pink', 'orange', 'green'};
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.Tag = 'ColorPicker';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'ColorPicker_Panel', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'ColorPicker_GridLayout', ...
                'ColumnWidth', {18, 18, 18, 18, 18, 18}, ...
                'RowHeight', {18, 18, 18}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            % Buttons to select colors
            for col = 1:6
                for row = 1:3
                    Obj.Buttons(row, col).h = uibutton(Obj.GridLayout, ...
                        'Tag', 'color', ...
                        'Text', '', ...
                        'BackgroundColor', eval(sprintf('Colors.lab_%s_%i', Names{col}, row)), ...
                        'ButtonPushedFcn', @(~, event) Obj.SetColor(event));
                    Obj.Buttons(row, col).h.Layout.Column = col;
                    Obj.Buttons(row, col).h.Layout.Row = row;
                end
            end
        end
        % =================================================================
        function SetColor(Obj, event)
            event.Source.UserData = Obj.UserData;
            event = AppEventData(event, [Obj.UserData, {'Color', event.Source.BackgroundColor}]);
            app_callback(event, Obj.Fcn, Obj.EventName)
            delete(Obj)
        end
        % =================================================================
        function update(Obj)
            try
                % -------------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: ColorPicker updated in %.1g s.\n', (now-Time)*18*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ColorPicker.m')
            end
        end
    end
end