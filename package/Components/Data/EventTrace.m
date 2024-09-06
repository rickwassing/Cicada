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
        MaxTrack;
        UnitsPerPixel;
        Tag;
        IsHovered;
        PointerBehaviorIsSet = false;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Line (1,1) matlab.graphics.chart.primitive.Line
        Patch
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
            % -------------------------------------------------------------
            Obj.Patch = patch(Parent, 'XData', NaN, 'YData', NaN, ...
                'Tag', 'EventTrace_Patch', ...
                'LineStyle', 'none', ...
                'FaceColor', [0.25, 0.25, 0.25], ...
                'FaceAlpha', 0.67);
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
                    delete(Obj.Line);
                    delete(Obj.Patch);
                    return
                end
                % ---------------------------------------------------------
                Obj.Id = Obj.Event.id;
                % ---------------------------------------------------------
                % Set the tag
                switch Obj.Event.type{1}
                    case {'manual', 'custom'}
                        is_editable = true;
                        Obj.Tag = ['EditableEventTrace_id-', num2str(Obj.Event.id)];
                        Obj.Line.Tag = ['EditableEventTrace_Line_id-', num2str(Obj.Event.id)];
                        Obj.Patch.Tag = ['EditableEventTrace_Patch_id-', num2str(Obj.Event.id)];
                    otherwise
                        is_editable = false;
                        Obj.Tag = ['EventTrace_id-', num2str(Obj.Event.id)];
                        Obj.Line.Tag = ['EventTrace_Line_id-', num2str(Obj.Event.id)];
                        Obj.Patch.Tag = ['EventTrace_Patch_id-', num2str(Obj.Event.id)];
                end
                % -------------------------------------------------------------
                % Triggers callback functions when the mouse moves in and out of the axis
                if ~Obj.PointerBehaviorIsSet
                    ButtonMotion.enterFcn = @(~, ~) Obj.handleIsHovered(true);
                    ButtonMotion.traverseFcn = [];
                    ButtonMotion.exitFcn = @(~, ~) Obj.handleIsHovered(false);
                    iptSetPointerBehavior(Obj.Line, ButtonMotion);
                    iptSetPointerBehavior(Obj.Patch, ButtonMotion);
                    Obj.PointerBehaviorIsSet = true;
                end
                % ---------------------------------------------------------
                if ~Obj.Event.show
                    Obj.Line.XData = NaN;
                    Obj.Line.YData = NaN;
                    Obj.Patch.XData = NaN;
                    Obj.Patch.YData = NaN;
                    return
                end
                % ---------------------------------------------------------
                % Apply XData YData and color
                switch Obj.Event.label{1}
                    case 'reject' % do patch
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        Obj.Line.Visible = 'off';
                        Obj.Patch.Visible = 'on';
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        XData = [...
                            iso2datenum(Obj.Event.onset{1}), ...
                            iso2datenum(Obj.Event.onset{1}) + iso2duration(Obj.Event.duration{1}), ...
                            iso2datenum(Obj.Event.onset{1}) + iso2duration(Obj.Event.duration{1}), ...
                            iso2datenum(Obj.Event.onset{1})];
                        YData = [3 + Obj.Patch.Parent.YLim(1), 3 + Obj.Patch.Parent.YLim(1), ...
                            (Obj.MaxTrack) * 9, (Obj.MaxTrack) * 9] .* Obj.UnitsPerPixel;
                        Obj.Patch.XData = XData;
                        Obj.Patch.YData = YData;
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        if Obj.IsHovered
                            Obj.Patch.FaceAlpha = ifelse(is_editable, 0.33, 0.67);
                        else
                            Obj.Patch.FaceAlpha = 0.67;
                        end
                    otherwise % do plot
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        Obj.Line.Visible = 'on';
                        Obj.Patch.Visible = 'off';
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        XData = [iso2datenum(Obj.Event.onset{1}), iso2datenum(Obj.Event.onset{1}) + iso2duration(Obj.Event.duration{1})];
                        YData = [6 + (Obj.Track-1) * 9, 6 + (Obj.Track-1) * 9] .* Obj.UnitsPerPixel;
                        Obj.Line.XData = XData;
                        Obj.Line.YData = YData;
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        if Obj.IsHovered
                            Obj.Line.Color = ifelse(is_editable, Obj.Event.color{1}.^0.5, Obj.Event.color{1});
                        else
                            Obj.Line.Color = Obj.Event.color{1};
                        end
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
            % -------------------------------------------------------------
            % Check if object is valid
            if ~isvalid(Obj)
                return
            end
            % -------------------------------------------------------------
            app = app_gethandle();
            % Check that the user is not currently making a selection
            if app.Props.IsMouseDown
                return
            end
            % -------------------------------------------------------------
            % Set the object's properties and update
            Obj.IsHovered = bool;
            Obj.update();
            switch Obj.Event.type{1}
                case {'manual', 'custom'}
                    Editable = 'on';
                otherwise
                    Editable = 'off';
            end
            % -------------------------------------------------------------
            % Set the tooltip
            if Obj.IsHovered
                app.Cmps.Tooltip.Label = sprintf('%s (%s)', Obj.Event.label{1}, Obj.Event.type{1});
            else
                app.Cmps.Tooltip.Label = '';
            end
            if Obj.IsHovered && strcmpi(Editable, 'on')
                app.UIFigure.Pointer = 'hand';
            else
                app.UIFigure.Pointer = 'arrow';
            end
            app.Cmps.Tooltip.hUpdate(app, ...
                'BackgroundColor', Obj.Event.color{1}, ...
                'Editable', Editable);
        end
    end
end