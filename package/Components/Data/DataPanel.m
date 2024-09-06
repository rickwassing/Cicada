% DATAPANEL
% A panel that displays the epoched metrics of one actogram day

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

classdef DataPanel < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Title;
        PanelNum;
        Start = [];
        End = [];
        ActogramWidth;
        PanelHeight;
        Metric = struct('y', [], 'modality', '', 'device', '', 'labels', {}, 'srate', [], 'pnts', [], 'xmin', '', 'xmax', '', 'showSingleMetric', [], 'show', [], 'height', [], 'log', [], 'ylim', [], 'color', [], 'zindex', []);
        Events;
        IsHovered = false;
        UpdateHoverOnly = false;
        Status;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        Axes matlab.ui.control.UIAxes
        Cursor Cursor
        Selection Selection
        Legend DataLegend
        MetricGraphics
        EventGraphics
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
            Obj.Tag = 'DataPanel';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'DataPanel_Panel', ...
                'BorderType', 'none', ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'DataPanel_GridLayout', ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', 3, ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_secondary);
            Obj.Axes = uiaxes(Obj.GridLayout, ...
                'Tag', 'DataPanel_Axes', ...
                'Box', 'off', ...
                'XTick', [], ...
                'YTick', [], ...
                'NextPlot', 'add', ...
                'Box', 'off', ...
                'Color', Colors.bg_primary, ...
                'XColor', [0.5, 0.5, 0.5], ...
                'YColor', [1, 1, 1], ...
                'XGrid', 'on', ...
                'YGrid', 'on', ...
                'GridAlpha', 0.25, ...
                'LineWidth', 1, ...
                'TickLength', [0, 0], ...
                'FontSize', 8, ...
                'Layer', 'bottom', ...
                'Toolbar', [], ...
                'Interactions', []);
            Obj.Axes.Title.FontSize = 9;
            Obj.Axes.Title.FontWeight = 'normal';
            % -------------------------------------------------------------
            % Triggers callback functions when the mouse moves in and out of the axis
            ButtonMotion.enterFcn = @(~, ~) Obj.hToggleIsHovered(true);
            ButtonMotion.exitFcn = @(~, ~) Obj.hToggleIsHovered(false);
            ButtonMotion.traverseFcn = [];
            iptSetPointerBehavior(Obj.Axes, ButtonMotion)
            % -------------------------------------------------------------
            % Add cursor to the axes and listen to mouse-move events
            Obj.Selection = Selection(Obj.Axes); %#ok<PROP>
            Obj.Cursor = Cursor(Obj.Axes); %#ok<PROP>
            app_addlisteners([], Obj.Cursor, {'eDataChanged', 'eMouseMotion'});
            app_addlisteners([], Obj.Selection, {'eDatasetChanged', 'eDataChanged', 'eMouseDown', 'eMouseUp', 'eMouseMotion', 'eKeyPress'});
        end
        % =================================================================
        function update(Obj, varargin)
            try
                % ---------------------------------------------------------
                % Don't have to update all other stuff if only the hover
                % status changed
                if Obj.UpdateHoverOnly
                    Obj.UpdateHoverOnly = false;
                    return
                end
                Obj.UpdateHoverOnly = false;
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                % If this component is returned to the pool, its status is 'idle'
                if strcmpi(Obj.Status, 'idle') || isempty(Obj.Metric) || isempty(Obj.Start) || isempty(Obj.End)
                    Obj.hReset();
                    return
                end
                % ---------------------------------------------------------
                % Set tag, title and x-limits
                Obj.Axes.Tag = Obj.Start;
                Obj.Axes.Title.String = iso2title(Obj.Start, Obj.End);
                Obj.Axes.XLim = [iso2datenum(Obj.Start), iso2datenum(Obj.End)];
                % ---------------------------------------------------------
                % Create the x-tick marks and labels
                XTick = Obj.Axes.XLim(1):1/(24*60):Obj.Axes.XLim(2);
                Obj.Axes.XTick = XTick(mod(XTick, ifelse(strcmpi(Obj.ActogramWidth, 'single'), 1, 2)/24) == 0);
                Obj.Axes.XTickLabel = datestr(Obj.Axes.XTick, 'HH:MM'); %#ok<DATST>
                Obj.Axes.XTickLabelRotation = 0;
                % ---------------------------------------------------------
                % Sort the events
                if ~isempty(Obj.Events)
                    [~, idx] = sort(cellfun(@(dstr) iso2datenum(dstr), Obj.Events.onset));
                    Obj.Events = Obj.Events(idx, :);
                end
                % ---------------------------------------------------------
                % Plot the events
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % First determine the track for each event
                track = ones(1, size(Obj.Events, 1));
                for i = 2:size(Obj.Events, 1)
                    if ~Obj.Events.show(i)
                        continue
                    end
                    if strcmpi(Obj.Events.label{i}, 'reject')
                        continue
                    end
                    trackoptions = [];
                    trackexclusions = [];
                    thisonset = iso2datenum(Obj.Events.onset{i});
                    for j = 1:(i-1)
                        % Check if it overlaps
                        thatoffset = iso2datenum(Obj.Events.onset{j}) + iso2duration(Obj.Events.duration{j});
                        if thisonset > thatoffset
                            % It does not overlap, this track is an option
                            trackoptions = [trackoptions, track(j)]; %#ok<AGROW>
                        else
                            % It does overlap, this track is not an option
                            trackexclusions = [trackexclusions, track(j)]; %#ok<AGROW>
                        end
                    end
                    trackoptions = setdiff(trackoptions, trackexclusions);
                    if isempty(trackoptions)
                        % There were no valid options, create new track
                        track(i) = max(track) + 1;
                    else
                        % Take the lowest track from the options
                        track(i) = min(trackoptions);
                    end
                end
                % ---------------------------------------------------------
                % How many normalized height units is the offset?
                [~, idx] = unique({Obj.Metric.modality});
                TotUnits = sum([Obj.Metric(idx).height]);
                MaxTrack = max(track);
                EventHeight = 6 + MaxTrack * 6 + max([0, MaxTrack - 1]) * 3;
                if isempty(EventHeight)
                    EventHeight = 0;
                end
                TotPixels = Obj.PanelHeight - EventHeight;
                UnitsPerPixel = TotUnits/TotPixels;
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Then plot the events
                for i = 1:size(Obj.Events, 1)
                    % Check if the event trace is rendered already or not
                    DoRender = false;
                    if i > length(Obj.EventGraphics)
                        DoRender = true;
                    elseif ~isvalid(Obj.EventGraphics(i).Obj)
                        DoRender = true;
                    end
                    if DoRender
                        Obj.EventGraphics(i).Obj = EventTrace(Obj.Axes, 'Verbose', Obj.Verbose);
                    end
                    Obj.EventGraphics(i).Obj.Event = Obj.Events(i, :);
                    Obj.EventGraphics(i).Obj.Track = track(i);
                    Obj.EventGraphics(i).Obj.MaxTrack = MaxTrack;
                    Obj.EventGraphics(i).Obj.UnitsPerPixel = UnitsPerPixel;
                    Obj.EventGraphics(i).Obj.update(); % This component does not have an auto-update when properties change
                end
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Delete events that are not needed
                for i = length(Obj.EventGraphics):-1:size(Obj.Events, 1)+1
                    Obj.EventGraphics(i).Obj.Event = [];
                    Obj.EventGraphics(i).Obj.update();
                    delete(Obj.EventGraphics(i).Obj);
                    Obj.EventGraphics(i) = [];
                end
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                Offset = UnitsPerPixel * EventHeight;
                YTick = UnitsPerPixel * EventHeight;
                % ---------------------------------------------------------
                % Dynamically render the legend
                DoRender = false;
                if isempty(Obj.Legend)
                    DoRender = true;
                elseif ~isvalid(Obj.Legend)
                    DoRender = true;
                end
                if DoRender
                    Obj.Legend = DataLegend(Obj.Axes, 'Verbose', Obj.Verbose);
                end
                Obj.Legend.Metric = Obj.Metric;
                Obj.Legend.Offset = Offset;
                Obj.Legend.update();
                % ---------------------------------------------------------
                % Dynamically update the DataTrace components and the Y-axis
                Modality = Obj.Metric(1).modality;
                Height = Obj.Metric(1).height;
                for i = 1:length(Obj.Metric)
                    % Calculate offset
                    if ~strcmpi(Obj.Metric(i).modality, Modality)
                        Offset = Offset + Height;
                        YTick = [YTick, Offset]; %#ok<AGROW>
                        Modality = Obj.Metric(i).modality;
                        Height = Obj.Metric(i).height;
                    end
                    % Check if the data trace is rendered already or not
                    DoRender = false;
                    if i > length(Obj.MetricGraphics)
                        DoRender = true;
                    elseif ~isvalid(Obj.MetricGraphics(i).Obj)
                        DoRender = true;
                    end
                    if DoRender
                        Obj.MetricGraphics(i).Obj = DataTrace(Obj.Axes, 'Verbose', Obj.Verbose);
                    end
                    Obj.MetricGraphics(i).Obj.Metric = Obj.Metric(i);
                    Obj.MetricGraphics(i).Obj.Offset = Offset;
                    Obj.MetricGraphics(i).Obj.Height = Height;
                    Obj.MetricGraphics(i).Obj.update(); % This component does not have an auto-update when properties change
                end
                % ---------------------------------------------------------
                % Hide data trace components that are not needed
                for i = length(Obj.MetricGraphics):-1:length(Obj.Metric)+1
                    Obj.MetricGraphics(i).Obj.Metric = [];
                    Obj.MetricGraphics(i).Obj.update();
                    delete(Obj.MetricGraphics(i).Obj);
                    Obj.MetricGraphics(i) = [];
                end
                % ---------------------------------------------------------
                % Set the Y-axis properties
                Obj.Axes.YLim = [0, max([0.01, max(YTick) + Height])];
                Obj.Axes.YTick = unique(YTick);
                Obj.Axes.YTickLabel = {};
                % ---------------------------------------------------------
                Obj.Axes.Children = [...
                    findobj(Obj.Axes.Children, 'type', 'patch'); ...
                    findobj(Obj.Axes.Children, '-not', 'type', 'patch')];
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DataPanel ''%s'' updated in %.1g s.\n', Obj.Axes.Title.String, (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DataPanel.m')
            end
        end
        % =================================================================
        function hToggleIsHovered(Obj, bool)
            Obj.IsHovered = bool;
            Obj.UpdateHoverOnly = true;
        end
        % =================================================================
        function hReset(Obj)
            % -------------------------------------------------------------
            % Reset axes and child plot objects
            Obj.Axes.Title.String = '';
            Obj.Axes.XLim = [0, 1];
            Obj.Axes.XTick = [];
            idx_rm = [];
            for i = 1:length(Obj.Axes.Children)
                if isprop(Obj.Axes.Children(i), 'Tag')
                    if contains(Obj.Axes.Children(i).Tag, 'Cursor')
                        continue
                    end
                    if contains(Obj.Axes.Children(i).Tag, 'Selection')
                        continue
                    end
                end
                idx_rm = [idx_rm, i]; %#ok<AGROW>
            end
            delete(Obj.Axes.Children(idx_rm));
            Obj.MetricGraphics = [];
            Obj.EventGraphics = [];
        end
        % =================================================================
        function cfg = config(Obj, ACT)
            % -------------------------------------------------------------
            cfg = struct();
            % -------------------------------------------------------------
            % Create date-time objects of the actogram start and end dates
            cfg.Width = ACT.info.actogram.width;
            cfg.Start = iso2datetime([ACT.xmin(1:10), 'T', ACT.info.actogram.start, ':00.000']);
            cfg.End = iso2datetime([ACT.xmin(1:10), 'T', ACT.info.actogram.end, ':00.000']);
            % -------------------------------------------------------------
            % The actogram start must be before the start of the recording
            while cfg.Start > iso2datetime(ACT.xmin)
                cfg.Start = cfg.Start - days(1);
                cfg.End = cfg.End - days(1);
            end
            % Add # days given by the panel number
            cfg.Start = cfg.Start + days(Obj.PanelNum - 1);
            % Make sure the end date is after the start date
            while cfg.End < cfg.Start
                cfg.End = cfg.End + days(1);
            end
            % For the end date, add 0 or 1 days (single or double)
            cfg.End = cfg.End + days(ifelse(strcmpi(ACT.info.actogram.width, 'single'), 1, 2));
            % -------------------------------------------------------------
            % Convert to char
            cfg.Start = datetime2iso(cfg.Start);
            cfg.End = datetime2iso(cfg.End);
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, ~)
            try
                % ---------------------------------------------------------
                % If the dataset is empty, return
                if isempty(app.ACT)
                    return
                end
                % ---------------------------------------------------------
                if strcmpi(Obj.Status, 'idle')
                    return
                end
                % ---------------------------------------------------------
                % Crop config
                cfg = Obj.config(app.ACT);
                Obj.Start = cfg.Start;
                Obj.End = cfg.End;
                Obj.ActogramWidth = cfg.Width;
                % ---------------------------------------------------------
                % Get metrics and events
                Obj.Metric = app.ACT.metric([app.ACT.metric.show]);
                Obj.Events = cropevents(app.ACT.analysis.events, cfg);
                % ---------------------------------------------------------
                % Crop metrics
                for i = 1:length(Obj.Metric)
                    Obj.Metric(i) = cropmetrics(Obj.Metric(i), cfg);
                end
                % ---------------------------------------------------------
                % Sort Z-index
                [~, idx] = sort([Obj.Metric.zindex], 'ascend');
                Obj.Metric = Obj.Metric(idx);
                [~, idx] = sort(cellfun(@(m) find(strcmpi(app.ACT.info.modalities, m)), {Obj.Metric.modality}));
                Obj.Metric = Obj.Metric(idx);
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in DataPanel.m')
            end
        end
    end
end