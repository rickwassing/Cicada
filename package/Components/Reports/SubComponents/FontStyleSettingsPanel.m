% FONTSTYLESETTINGSPANEL
% Reusable panel component for font style settings (family, size, color)

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

classdef FontStyleSettingsPanel < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties (Access = public)
        Title (1, :) char = 'FONT STYLE'
        TagPrefix (1, :) char = 'style'
        FontFamily (1, :) char = 'Helvetica'
        FontSize (1, 1) double = 11
        FontColor (1, 3) double = [0, 0, 0]
    end
    properties (Access = private, Transient, NonCopyable)
        Panel
        GridLayout
        FontFamilyInput
        FontSizeInput
        ColorPicker
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
            % Create the main panel
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'ReportSettings_Panel', ...
                'Title', '<type>', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'ReportSettings_GridLayout', ...
                'ColumnWidth', {'1x', 50, 34}, ...
                'RowHeight', {20}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            % Create font family dropdown
            Obj.FontFamilyInput = uidropdown(Obj.GridLayout);
            Obj.FontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            Obj.FontFamilyInput.FontSize = 10;
            Obj.FontFamilyInput.Layout.Row = 1;
            Obj.FontFamilyInput.Layout.Column = 1;
            Obj.FontFamilyInput.ValueChangedFcn = @(~, event) app_callback(event, 'set_reportstyle', {'eStyleChanged'});
            % -------------------------------------------------------------
            % Create font size dropdown
            Obj.FontSizeInput = uidropdown(Obj.GridLayout);
            Obj.FontSizeInput.FontSize = 10;
            Obj.FontSizeInput.Layout.Row = 1;
            Obj.FontSizeInput.Layout.Column = 2;
            Obj.FontSizeInput.ValueChangedFcn = @(~, event) app_callback(event, 'set_reportstyle', {'eStyleChanged'});
            % -------------------------------------------------------------
            % Create color picker
            Obj.ColorPicker = uicolorpicker(Obj.GridLayout);
            Obj.ColorPicker.Layout.Row = 1;
            Obj.ColorPicker.Layout.Column = 3;
            Obj.ColorPicker.ValueChangedFcn = @(~, event) app_callback(event, 'set_reportstyle', {'eStyleChanged'});
        end

        function update(Obj)
            % Update panel title
            Obj.Panel.Title = Obj.Title;

            % Update tags
            Obj.FontFamilyInput.Tag = sprintf('%s-fontFamily', Obj.TagPrefix);
            Obj.FontSizeInput.Tag = sprintf('%s-fontSize', Obj.TagPrefix);
            Obj.ColorPicker.Tag = sprintf('%s-fontColor', Obj.TagPrefix);

            % Initialize font family dropdown
            Obj.initFontFamilyInput();

            % Initialize font size dropdown
            Obj.initFontSizeInput();

            % Set color picker value
            Obj.ColorPicker.Value = Obj.FontColor;
        end

    end

    methods (Access = private)

        % Initialize font family dropdown
        function initFontFamilyInput(Obj)
            val = Obj.FontFamily;
            if ~ischar(val)
                val = 'Helvetica';
            end
            switch lower(val)
                case {'georgia', 'times new roman', 'calibri', 'helvetica', 'arial'}
                    val = lower(val);
                    val(1) = upper(val(1));
                otherwise
                    val = 'Helvetica';
            end
            Obj.FontFamilyInput.Value = val;
        end

        % Initialize font size dropdown
        function initFontSizeInput(Obj)
            val = Obj.FontSize;
            if ~isnumeric(val)
                val = 11;
            end
            Obj.FontSizeInput.Items = arrayfun(@(i) sprintf('%i', i), unique([8:24, val]), 'UniformOutput', false);
            Obj.FontSizeInput.Value = sprintf('%i', val);
        end

    end

end
