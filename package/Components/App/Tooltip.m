% TOOLTIP
% A small indicator at the mouse pointed to label actions.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-06-27, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef Tooltip < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Id;
        Text = '';
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Axis
        Label
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
            Obj.Tag = 'Tooltip';
            Obj.Visible = 'off';
            Obj.BackgroundColor = Colors.bg_tooltip;
            Obj.Position = [1, 1, 100, 18];
            % -------------------------------------------------------------
            Obj.Axis = axes(Obj, ...
                'XLim', [0, 1], ...
                'Units', 'normalized', ...
                'Visible', 'off', ...
                'Interactions', [], ...
                'InnerPosition', [0, 0, 1, 1]);
            Obj.Axis.Toolbar.Visible = 'off';
            % -------------------------------------------------------------
            Obj.Label = text(Obj.Axis, 0, 0, 'label', ...
                'Units', 'pixels', ...
                'FontSize', 10, ...
                'Color', 'w');
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                Obj.Label.Units = 'pixels';
                Obj.Label.String = sprintf(' %s ', Obj.Text);
                Obj.Position(3) = Obj.Label.Extent(3);
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in Tooltip.m')
            end
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, event) %#ok<INUSD>
            % do something
        end
    end
end