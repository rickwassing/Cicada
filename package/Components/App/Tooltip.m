% TOOLTIP
% A small indicator at the mouse pointed to label actions.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-09-04, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef Tooltip < handle
    % *********************************************************************
    % PROPERTIES
    properties
        Label;
        Visible;
        Position;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        LabelObj;
        HiddenAxes;
        HiddenText;
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = Tooltip(parent)
            % -------------------------------------------------------------
            Colors = app_colors();
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.LabelObj = uilabel(parent, ...
                'Visible', 'off', ...
                'Text', '<p> mylabel </p>',  ...
                'Interpreter', 'html', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 10, ...
                'BackgroundColor', Colors.bg_tooltip, ...
                'Position', [100, 100, 10, 16], ...
                'FontColor', 'w');
            % -------------------------------------------------------------
            Obj.HiddenAxes = uiaxes(parent, 'Visible', 'off');
            % -------------------------------------------------------------
            Obj.HiddenText = text(Obj.HiddenAxes, 0, 0, ' mylabel ', ...
                'Units', 'pixels', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 10);
            Obj.LabelObj.Position(3) = Obj.HiddenText.Extent(3);
        end
        % =================================================================
        function hUpdate(Obj, app, varargin)
            try
                % -------------------------------------------------------------
                Colors = app_colors();
                % -------------------------------------------------------------
                BackgroundColor = Colors.bg_tooltip;
                Editable = 'off';
                for i = 1:2:length(varargin)
                    switch lower(varargin{i})
                        case 'backgroundcolor'
                            BackgroundColor = varargin{i+1};
                        case 'editable'
                            Editable = varargin{i+1};
                    end
                end
                % ---------------------------------------------------------
                if isempty(Obj.Label)
                    Obj.LabelObj.Visible = 'off';
                else
                    Obj.HiddenText.String = sprintf(' %s ', ifelse(strcmpi(Editable, 'on'), sprintf('✎ %s', Obj.Label), Obj.Label));
                    Obj.LabelObj.Visible = 'on';
                    Obj.LabelObj.Text = sprintf('<p> %s </p>', ifelse(strcmpi(Editable, 'on'), sprintf('✎ %s', Obj.Label), Obj.Label));
                    Obj.LabelObj.Position(3) = Obj.HiddenText.Extent(3);
                    Obj.LabelObj.Position(1:2) = app.UIFigure.CurrentPoint(1:2) + [-Obj.HiddenText.Extent(3)/2, 6];
                    Obj.LabelObj.BackgroundColor = BackgroundColor;
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in Tooltip.m')
            end
        end
    end
end