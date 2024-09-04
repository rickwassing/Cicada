% CURSOR
% The cusor in DataPanels

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-03-24, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef Cursor < handle
    % *********************************************************************
    % PROPERTIES
    properties
        Tag char;
    end
    properties (Access = private, Transient, NonCopyable)
        Line (1,1) matlab.graphics.chart.primitive.Line
        Text (1,1) matlab.graphics.primitive.Text
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = Cursor(Parent)
            % -------------------------------------------------------------
            % Create line
            % Create the original and smooth lines
            Obj.Tag = 'Cursor';
            Obj.Line = plot(Parent, [NaN, NaN], [NaN, NaN], '-k', ...
                'Tag', 'Cursor_Line', ...
                'LineWidth', 0.25);
            Obj.Text = text(Parent, NaN, NaN, '', ...
                'Tag', 'Cursor_Text', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'Color', 'w', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'BackgroundColor', [0.1294 0.1451 0.1608]);
        end
        % =================================================================
        function hUpdate(Obj, ~, event)
            % -------------------------------------------------------------
            % If the dataset has changed, just remove the cursor 
            if strcmpi(event.EventName, 'eDatasetChanged')
                Obj.Line.XData = [NaN, NaN];
                Obj.Text.String = '';
                return
            end
            % -------------------------------------------------------------
            % Check if this panel is hovered
            try
                DPanel = Obj.Line.Parent.Parent.Parent.Parent;
            catch
                return
            end
            if ~DPanel.IsHovered
                Obj.Line.XData = [NaN, NaN];
                Obj.Text.String = '';
                return
            end
            % -------------------------------------------------------------
            % Set the cursor line
            cp = round(Obj.Line.Parent.CurrentPoint(1, 1)*24*60)/(24*60);
            Obj.Line.XData = [cp, cp];
            Obj.Line.YData = Obj.Line.Parent.YLim;
            Obj.Text.Position([1 2]) = [cp, 0];
            Obj.Text.String = datestr(cp, 'HH:MM'); %#ok<DATST>
        end
    end
end