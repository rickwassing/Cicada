% EVENTTRACE
% A single event trace

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-11-07, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef EventTrace < handle
    % *********************************************************************
    % PROPERTIES
    properties
        Id;
        Event;
        Track;
        UnitsPerPixel;
        Tag;
        IsHovered;
        PointerBehaviorIsSet = false;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Line (1,1) matlab.graphics.chart.primitive.Line
        Marker (1,1) matlab.graphics.chart.primitive.Line
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = EventTrace(Parent, varargin)
            % -------------------------------------------------------------
            % Create line
            % Create the original and smooth lines
            Obj.Tag = 'EventTrace';
            Obj.Line = plot(Parent, NaN, NaN, ...
                'Tag', 'EventTrace_Line', ...
                'LineStyle', '-', ...
                'Marker', 'o', ...
                'MarkerSize', 0.95, ...
                'MarkerFaceColor', [1, 1, 1], ...
                'LineWidth', 5);
            % Obj.Marker = plot(Parent, NaN, NaN, ...
            %     'Tag', 'EventTrace_Line', ...
            %     'LineStyle', 'none', ...
            %     'Marker', 'o', ...
            %     'LineWidth', 1, ...
            %     'MarkerSize', 4, ...
            %     'MarkerFaceColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Set other parameters using name-value pairs
            if nargin > 1
                for i = 1:2:length(varargin)
                    switch lower(varargin{i})
                        case 'verbose'
                            Obj.Verbose = varargin{i+1};
                    end
                end
            end
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                if size(Obj.Event, 1) > 1
                    error('The EventTrace property ''event'' must be a single row table.')
                end
                if isempty(Obj.Event)
                    Obj.Id = NaN;
                    Obj.Line.XData = NaN;
                    Obj.Line.YData = NaN;
                    % Obj.Marker.XData = NaN;
                    % Obj.Marker.YData = NaN;
                    return
                end
                % ---------------------------------------------------------
                Obj.Id = Obj.Event.id;
                % ---------------------------------------------------------
                if ~Obj.Event.show
                    Obj.Line.XData = NaN;
                    Obj.Line.YData = NaN;
                    % Obj.Marker.XData = NaN;
                    % Obj.Marker.YData = NaN;
                    return
                end
                % ---------------------------------------------------------
                % Apply XData YData and color
                XData = [iso2datenum(Obj.Event.onset{1}), iso2datenum(Obj.Event.onset{1}) + iso2duration(Obj.Event.duration{1})];
                YData = [6 + (Obj.Track-1) * 9, 6 + (Obj.Track-1) * 9] .* Obj.UnitsPerPixel;
                Obj.Line.XData = XData;
                Obj.Line.YData = YData;
                % Obj.Marker.XData = XData;
                % Obj.Marker.YData = YData;
                if Obj.IsHovered
                    Obj.Line.Color = Obj.Event.color{1}.^0.5;
                    % Obj.Marker.MarkerEdgeColor = Obj.Event.color{1}.^0.5;
                else
                    Obj.Line.Color = Obj.Event.color{1};
                    % Obj.Marker.MarkerEdgeColor = Obj.Event.color{1};
                end
                % Manual and custom events are editable and have white markers
                switch Obj.Event.type{1}
                    case {'manual', 'custom'}
                        % Marker color to indicate it is editable
                        % Obj.Marker.MarkerFaceColor = [1, 1, 1];
                        % Set the tag
                        Obj.Tag = ['EditableEventTrace_id-', num2str(Obj.Event.id)];
                        Obj.Line.Tag = ['EditableEventTrace_Line_id-', num2str(Obj.Event.id)];
                        % Obj.Marker.Tag = ['EditableEventTrace_Marker_id-', num2str(Obj.Event.id)];
                    otherwise
                        % Marker color to indicate it is not editable
                        % Obj.Marker.MarkerFaceColor = Obj.Line.Color;
                        % Set the tag
                        Obj.Tag = ['EventTrace_id-', num2str(Obj.Event.id)];
                        Obj.Line.Tag = ['EventTrace_Line_id-', num2str(Obj.Event.id)];
                        % Obj.Marker.Tag = ['EventTrace_Marker_id-', num2str(Obj.Event.id)];
                end
                % -------------------------------------------------------------
                % Triggers callback functions when the mouse moves in and out of the axis
                if ~Obj.PointerBehaviorIsSet
                    ButtonMotion.enterFcn = @(~, ~) Obj.handleIsHovered(true);
                    ButtonMotion.traverseFcn = [];
                    ButtonMotion.exitFcn = @(~, ~) Obj.handleIsHovered(false);
                    iptSetPointerBehavior(Obj.Line, ButtonMotion);
                    Obj.PointerBehaviorIsSet = true;
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: EventTrace id ''%i'' labelled ''%s (%s)'' updated in %.1g s.\n', Obj.Event.id, Obj.Event.label{1}, Obj.Event.type{1}, (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in EventTrace.m')
            end
        end
        % =================================================================
        function handleIsHovered(Obj, bool)
            app = app_gethandle();
            switch Obj.Event.type{1}
                case {'manual', 'custom'}
                    Obj.IsHovered = bool;
                    Obj.update();
                    if Obj.IsHovered
                        app.Cmps.Tooltip.Text = sprintf('%s (%s)', Obj.Event.label{1}, Obj.Event.type{1});
                        app.Cmps.Tooltip.Visible = 'on';
                        app.Cmps.Tooltip.Position(1:2) = app.UIFigure.CurrentPoint + [0, 6];
                    else
                        app.Cmps.Tooltip.Visible = 'off';
                    end
                otherwise
                    app.Cmps.Tooltip.Position(1:2) = app.UIFigure.CurrentPoint + [0, 6];
                    Obj.IsHovered = bool;
                    Obj.update();
                    if Obj.IsHovered
                        app.Cmps.Tooltip.Visible = 'on';
                        app.Cmps.Tooltip.Position(1:2) = app.UIFigure.CurrentPoint + [0, 6];
                    else
                        app.Cmps.Tooltip.Visible = 'off';
                    end
            end
            
        end
    end
end