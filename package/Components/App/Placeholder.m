% PLACEHOLDER
% Shows an image and heading to indicate nothing exist.

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-11-04, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

classdef Placeholder < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        ImageSrc;
        Header;
        SubHeader;
        Verbose;
        Size;
    end
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        Image matlab.ui.control.Image
        Heading matlab.ui.control.Label
        SubHeading matlab.ui.control.Label
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
            Obj.Tag = 'Placeholder';
            % -------------------------------------------------------------
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'Placeholder_Panel', ...
                'BackgroundColor', Colors.bg_primary, ...
                'HighLightColor', Colors.bg_primary, ...
                'BorderType', 'none', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'Placeholder_GridLayout', ...
                'ColumnWidth', {'1x', 211, '1x'}, ...
                'RowHeight', {'1x', 211, 48, 24, '1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_primary);
            % -------------------------------------------------------------
            Obj.Image = uiimage(Obj.GridLayout, ...
                'Tag', 'Placeholder_Image', ...
                'ImageSource', 'no-data.png');
            Obj.Image.Layout.Column = 2;
            Obj.Image.Layout.Row = 2;
            % -------------------------------------------------------------
            Obj.Heading = uilabel(Obj.GridLayout, ...
                'Tag', 'Placeholder_HeadingLabel', ...
                'Text', '<Header>', ...
                'FontWeight', 'bold', ...
                'FontColor', [0.0157, 0.2373, 0.2824], ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14);
            Obj.Heading.Layout.Column = 2;
            Obj.Heading.Layout.Row = 3;
            % -------------------------------------------------------------
            Obj.SubHeading = uilabel(Obj.GridLayout, ...
                'Tag', 'Placeholder_SubHeadingLabel', ...
                'Text', '<Subheader>', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 10);
            Obj.SubHeading.Layout.Column = 2;
            Obj.SubHeading.Layout.Row = 4;
        end
        % =================================================================
        function update(Obj)
            Obj.Image.ImageSource = Obj.ImageSrc;
            Obj.Heading.Text = Obj.Header;
            Obj.SubHeading.Text = Obj.SubHeader;
            Obj.Panel.BackgroundColor = Obj.BackgroundColor;
            Obj.GridLayout.BackgroundColor = Obj.BackgroundColor;
            Obj.GridLayout.ColumnWidth{2} = Obj.Size;
            Obj.GridLayout.RowHeight{2} = Obj.Size;
        end
    end
end