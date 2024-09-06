% EVENTEXERPT
% The to show and edit the selected event.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-08-22, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef EventExcerpt < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Size = [400, 300];
        SelectedSegment = [];
        SelectedEventId = [];
        DefaultEventLabels = {'Select'; 'reject'; 'sleepwindow'; 'napwindow'};
        EventLabelValue = [];
        EventLabelIsEditable = true;
        EventLabels;
        Metric = struct('y', [], 'modality', '', 'device', '', 'labels', {}, 'srate', [], 'pnts', [], 'xmin', '', 'xmax', '', 'showSingleMetric', [], 'show', [], 'height', [], 'log', [], 'ylim', [], 'color', [], 'zindex', []);
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        EventPanel matlab.ui.container.Panel
        EventPanelGridLayout matlab.ui.container.GridLayout
        Labels
        Inputs
        Buttons
        Axes matlab.ui.control.UIAxes
        Graphics DataTrace
        Patch (1,1) matlab.graphics.primitive.Patch
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
            ColorGradient = [...
                Colors.cic_indigo; ...
                Colors.cic_indigo; ...
                Colors.cic_pink; ...
                Colors.cic_pink ...
                ];
            % -------------------------------------------------------------
            Obj.Tag = 'EventsExcerpt';
            Obj.Panel = uipanel(Obj, ...
                'Title', 'CREATE NEW EVENT', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'Tag', 'EventsExcerpt_Panel', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'EventsExcerpt_GridLayout', ...
                'ColumnWidth', {'1x', '1x', '1x'}, ...
                'RowHeight', {'1x', 87, 24}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            Obj.Axes = uiaxes(Obj.GridLayout, ...
                'Tag', 'EventsExcerpt_Axes', ...
                'Box', 'off', ...
                'XTick', [], ...
                'YTick', [], ...
                'NextPlot', 'add', ...
                'Box', 'off', ...
                'Color', Colors.bg_secondary, ...
                'XColor', [0.5, 0.5, 0.5], ...
                'YColor', Colors.bg_secondary, ...
                'XGrid', 'on', ...
                'YGrid', 'on', ...
                'GridAlpha', 0.25, ...
                'LineWidth', 1, ...
                'TickLength', [0, 0], ...
                'FontSize', 8, ...
                'Layer', 'bottom', ...
                'Toolbar', [], ...
                'Interactions', []);
            Obj.Axes.Layout.Column = [1, 3];
            Obj.Axes.Title.String = '';
            Obj.Axes.Title.FontSize = 9;
            Obj.Axes.Title.FontWeight = 'normal';
            % -------------------------------------------------------------
            Obj.Patch = patch(Obj.Axes, ...
                'Faces', 1:4, ...
                'Vertices', [15/(60*24), 0; 55/(60*24), 0; 55/(60*24), 1; 15/(60*24), 1], ...
                'FaceVertexCData', ColorGradient,...
                'FaceVertexAlphaData', [0.1; 0.1; 0.25; 0.25], ...
                'AlphaDataMapping', 'none', ...
                'EdgeColor', 'interp', ...
                'FaceColor', 'interp', ...
                'EdgeAlpha', 'interp', ...
                'FaceAlpha', 'interp', ...
                'LineStyle', 'none');
            % -------------------------------------------------------------
            Obj.EventPanel = uipanel(Obj.GridLayout, ...
                'FontSize', 8, ...
                'Tag', 'EventsExcerpt_EventPanel', ...
                'BorderType', 'none', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8]);
            Obj.EventPanel.Layout.Row = 2;
            Obj.EventPanel.Layout.Column = [1, 3];
            % -------------------------------------------------------------
            Obj.EventPanelGridLayout = uigridlayout(Obj.EventPanel, ...
                'Tag', 'EventsExcerpt_EventPanelGridLayout', ...
                'ColumnWidth', {64, '1x', 18, 18}, ...
                'RowHeight', {18, 18, 18, 18}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);
            % -------------------------------------------------------------
            Obj.Labels.GroupLabel = uilabel(Obj.EventPanelGridLayout, ...
                'Text', 'Event group', ...
                'FontWeight', 'bold', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.Labels.GroupLabel.Layout.Row = 1;
            Obj.Labels.GroupLabel.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.GroupValue = uidropdown(Obj.EventPanelGridLayout, ...
                'Value', 'Select', ...
                'Items', {'Select'}, ...
                'Editable','on', ...
                'Tooltip', 'Select label or type new', ...
                'Tag', 'EventExcerpt_Labels_GroupValue', ...
                'ValueChangedFcn', @(~, event) set(Obj, 'EventLabelValue', event.Value), ...
                'FontSize', 10);
            Obj.Labels.GroupValue.Layout.Row = 1;
            Obj.Labels.GroupValue.Layout.Column = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.DurationLabel = uilabel(Obj.EventPanelGridLayout, ...
                'Text', 'Duration', ...
                'FontWeight', 'bold', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.Labels.DurationLabel.Layout.Row = 2;
            Obj.Labels.DurationLabel.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.DurationValue = uilabel(Obj.EventPanelGridLayout, ...
                'Text', '8h 15m', ...
                'FontSize', 10);
            Obj.Labels.DurationValue.Layout.Row = 2;
            Obj.Labels.DurationValue.Layout.Column = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.OnsetLabel = uilabel(Obj.EventPanelGridLayout, ...
                'Text', 'Onset', ...
                'FontWeight', 'bold', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.Labels.OnsetLabel.Layout.Row = 3;
            Obj.Labels.OnsetLabel.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.OnsetValue = uilabel(Obj.EventPanelGridLayout, ...
                'Text', '15 May 23:10', ...
                'FontSize', 10);
            Obj.Labels.OnsetValue.Layout.Row = 3;
            Obj.Labels.OnsetValue.Layout.Column = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.OffsetLabel = uilabel(Obj.EventPanelGridLayout, ...
                'Text', 'Offset', ...
                'FontWeight', 'bold', ...
                'FontColor', Colors.body_primary, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.Labels.OffsetLabel.Layout.Row = 4;
            Obj.Labels.OffsetLabel.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Labels.OffsetValue = uilabel(Obj.EventPanelGridLayout, ...
                'Text', '16 May 7:10', ...
                'FontSize', 10);
            Obj.Labels.OffsetValue.Layout.Row = 4;
            Obj.Labels.OffsetValue.Layout.Column = 2;
            % -------------------------------------------------------------
            Obj.Buttons.DecrDuration = uibutton(Obj.EventPanelGridLayout, ...
                'Text', '▼', ...
                'Tag', 'DecrDuration', ...
                'FontSize', 7, ...
                'FontColor', 'w', ...
                'VerticalAlignment', 'bottom', ...
                'BackgroundColor', Colors.body_secondary, ...
                'Tooltip', 'Shorter (arrow down)');
            Obj.Buttons.DecrDuration.Layout.Row = 2;
            Obj.Buttons.DecrDuration.Layout.Column = 3;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Buttons.IncrDuration = uibutton(Obj.EventPanelGridLayout, ...
                'Text', '▲', ...
                'Tag', 'IncrDuration', ...
                'FontSize', 7, ...
                'FontColor', 'w', ...
                'VerticalAlignment', 'top', ...
                'BackgroundColor', Colors.body_secondary, ...
                'Tooltip', 'Longer (arrow up)');
            Obj.Buttons.IncrDuration.Layout.Row = 2;
            Obj.Buttons.IncrDuration.Layout.Column = 4;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Buttons.DecrOnset = uibutton(Obj.EventPanelGridLayout, ...
                'Text', '◄', ...
                'Tag', 'DecrOnset', ...
                'FontSize', 7, ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.body_secondary, ...
                'Tooltip', 'Earlier (arrow left)');
            Obj.Buttons.DecrOnset.Layout.Row = 3;
            Obj.Buttons.DecrOnset.Layout.Column = 3;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Buttons.IncrOnset = uibutton(Obj.EventPanelGridLayout, ...
                'Text', '►', ...
                'Tag', 'IncrOnset', ...
                'FontSize', 7, ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.body_secondary, ...
                'Tooltip', 'Later (arrow right)');
            Obj.Buttons.IncrOnset.Layout.Row = 3;
            Obj.Buttons.IncrOnset.Layout.Column = 4;
            % -------------------------------------------------------------
            Obj.Buttons.Cancel = uibutton(Obj.GridLayout, ...
                'Text', 'CANCEL', ...
                'Tag', 'Cancel', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_secondary);
            Obj.Buttons.Cancel.Layout.Row = 3;
            Obj.Buttons.Cancel.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Buttons.Submit = uibutton(Obj.GridLayout, ...
                'Text', 'CREATE', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_success);
            Obj.Buttons.Submit.Layout.Row = 3;
            Obj.Buttons.Submit.Layout.Column = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            Obj.Buttons.Delete = uibutton(Obj.GridLayout, ...
                'Text', 'DELETE', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'FontColor', 'w', ...
                'BackgroundColor', Colors.bs_danger);
            Obj.Buttons.Delete.Layout.Row = 3;
            Obj.Buttons.Delete.Layout.Column = 3;
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                % Return if the metric is empty
                if isempty(Obj.Metric) || isempty(Obj.SelectedSegment)
                    Obj.Axes.XLim = [0, 1];
                    Obj.Axes.XTick = [];
                    return
                end
                % ---------------------------------------------------------
                % Set x-limits
                Obj.Axes.XLim = 1+[0, 70/(24*60)];
                % ---------------------------------------------------------
                % Create the x-tick marks and labels
                Obj.Axes.XTick = 1+[0, 15/(24*60), 30/(24*60), 40/(24*60), 55/(24*60), 70/(24*60)];
                Obj.Axes.XTickLabel = cellstr(datestr(sort([Obj.SelectedSegment-(15/(60*24)), Obj.SelectedSegment, Obj.SelectedSegment+(15/(60*24))]), 'HH:MM')); %#ok<DATST>
                Obj.Axes.XTickLabelRotation = 0;
                % ---------------------------------------------------------
                % Dynamically update the DataTrace components and the Y-axis
                Modality = Obj.Metric(1).modality;
                Height = Obj.Metric(1).height;
                Offset = 0;
                YTick = 0;
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
                    if i > length(Obj.Graphics)
                        DoRender = true;
                    elseif ~isvalid(Obj.Graphics(i))
                        DoRender = true;
                    end
                    if DoRender
                        Obj.Graphics(i) = DataTrace(Obj.Axes, 'Verbose', Obj.Verbose);
                    end
                    Obj.Graphics(i).Metric = Obj.Metric(i);
                    Obj.Graphics(i).Offset = Offset;
                    Obj.Graphics(i).Height = Height;
                    Obj.Graphics(i).update(); % This component does not have an auto-update when properties change
                end
                % ---------------------------------------------------------
                % Hide data trace components that are not needed
                for i = length(Obj.Graphics):-1:length(Obj.Metric)+1
                    Obj.Graphics(i).Metric = [];
                    Obj.Graphics(i).update(); % This component does not have an auto-update when properties change
                end
                % ---------------------------------------------------------
                % Set the Y-axis properties
                Obj.Axes.YLim = [0, max([0.01, max(YTick) + Height])];
                Obj.Axes.YTick = unique(YTick);
                Obj.Axes.YTickLabel = {};
                % ---------------------------------------------------------
                % Set the patch
                Obj.Patch.Vertices = [...
                    Obj.Axes.XTick(2), Obj.Axes.YLim(1); ...
                    Obj.Axes.XTick(5), Obj.Axes.YLim(1); ...
                    Obj.Axes.XTick(5), Obj.Axes.YLim(2); ...
                    Obj.Axes.XTick(2), Obj.Axes.YLim(2); ...
                    ];
                % ---------------------------------------------------------
                % Set the eventlabel items
                Obj.Labels.GroupValue.Enable = Obj.EventLabelIsEditable;
                Obj.Labels.GroupValue.Items = unique([Obj.DefaultEventLabels; Obj.EventLabels]);
                Obj.Labels.GroupValue.Value = Obj.EventLabelValue;
                % ---------------------------------------------------------
                % Set the values of the duration, onset, offset
                Obj.Labels.DurationValue.Text = duration2str(Obj.SelectedSegment(2) - Obj.SelectedSegment(1));
                Obj.Labels.OnsetValue.Text = iso2human(datenum2iso(Obj.SelectedSegment(1)), 'OmitSeconds', true);
                Obj.Labels.OffsetValue.Text = iso2human(datenum2iso(Obj.SelectedSegment(2)), 'OmitSeconds', true);
                % ---------------------------------------------------------
                if isempty(Obj.SelectedEventId)
                    Obj.GridLayout.ColumnWidth = {'1x', '1x'};
                    Obj.Axes.Layout.Column = [1, 2];
                    Obj.EventPanel.Layout.Column = [1, 2];
                    delete(Obj.Buttons.Delete);
                    Obj.Panel.Title = 'CREATE NEW EVENT';
                    Obj.Buttons.Submit.Text = 'CREATE';
                else
                    Obj.Panel.Title = 'UPDATE EVENT';
                    Obj.Buttons.Submit.Text = 'UPDATE';
                end
                % ---------------------------------------------------------
                % Enable or disable the Submit button if the group label
                if strcmpi(Obj.EventLabelValue, 'Select') || isempty(Obj.EventLabelValue)
                    Obj.Buttons.Submit.Enable = 'off';
                else
                    Obj.Buttons.Submit.Enable = 'on';
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: EventsExcerpt updated in %.1g s.\n', (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in EventsExcerpt.m')
            end
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
    % *********************************************************************
    methods (Access = public)
        % =================================================================
        % Select data
        function select(Obj, app)
            cfg = struct();
            cfg.Start = datenum2iso(Obj.SelectedSegment(1) - 15/(24*60));
            cfg.End = datenum2iso(Obj.SelectedSegment(2) + 15/(24*60));
            cfg.ForEvent = true;
            Obj.Metric = app.ACT.metric([app.ACT.metric.show]);
            for i = 1:length(Obj.Metric)
                Obj.Metric(i) = cropmetrics(Obj.Metric(i), cfg);
            end
        end
        % =================================================================
        % Adjust selected segment
        function adjust(Obj, app, event)
            switch event.Source.Tag
                case 'DecrDuration'
                    if strcmpi(Obj.Buttons.DecrDuration.Enable, 'off')
                        return % Do not update duration, disabled to prevent negative duration
                    end
                    app.Props.SelectedSegment(2) = app.Props.SelectedSegment(2) - 1/(24*60);
                case 'IncrDuration'
                    app.Props.SelectedSegment(2) = app.Props.SelectedSegment(2) + 1/(24*60);
                case 'DecrOnset'
                    app.Props.SelectedSegment = app.Props.SelectedSegment - 1/(24*60);
                case 'IncrOnset'
                    app.Props.SelectedSegment = app.Props.SelectedSegment + 1/(24*60);
                otherwise
                    return
            end
            Obj.SelectedSegment = app.Props.SelectedSegment;
            Obj.select(app); % Select metrics to display
            % Disable decrease duration to prevent negative duration
            if diff(app.Props.SelectedSegment) < 1/(24*60)
                Obj.Buttons.DecrDuration.Enable = 'off';
            else
                Obj.Buttons.DecrDuration.Enable = 'on';
            end
        end
        % =================================================================
        % Cancel 
        function cancel(Obj, app, event) %#ok<INUSD>
            app.hModal(event, []);
        end
        % =================================================================
        % Create or update event
        function submit(Obj, app, event)
            % Construct payload
            Payload = {...
                'Obj', Obj, ...
                'Method', ifelse(isempty(Obj.SelectedEventId), 'create', 'updateone'), ...
                'EventId', Obj.SelectedEventId, ...
                'EventGroup', Obj.EventLabelValue, ...
                'SelectedSegment', Obj.SelectedSegment, ...
                };
            % Close modal
            app.hModal(event, '');
            % Execute callback function
            event = AppEventData(event, Payload);
            app_callback(event, 'set_event', {'eDataChanged'})
        end
        % =================================================================
        % Delete an event
        function deleteone(Obj, app, event)
            % Construct payload
            Payload = {...
                'Obj', Obj, ...
                'Method', 'deleteone', ...
                'EventId', Obj.SelectedEventId, ...
                };
            % Close modal
            app.hModal(event, '');
            % Execute callback function
            event = AppEventData(event, Payload);
            app_callback(event, 'set_event', {'eDataChanged'})
        end
        % =================================================================
        function hUpdate(Obj, app, ~)
            try
                % TODO: bug, when the modal component is deleted, then
                % Matlab is supposed to also delete all the listeners, but
                % this does not work. So check here if the object is still
                % valid
                if ~isvalid(Obj)
                    return
                end
                % ---------------------------------------------------------
                % If the dataset is empty, return init props
                if isempty(app.ACT)
                    Obj.Visible = 'off';
                    Obj.Metric = [];
                    Obj.SelectedSegment = [];
                    Obj.EventLabels = {};
                    Obj.EventLabelValue = 'Select';
                    return
                end
                % ---------------------------------------------------------
                % Initialize the button pushed function, done here in
                % 'hUpdate' so we have access to the variable 'app'
                if isempty(Obj.Buttons.DecrDuration.ButtonPushedFcn)
                    Obj.Buttons.DecrDuration.ButtonPushedFcn = @(source, event) Obj.adjust(app, event);
                    Obj.Buttons.IncrDuration.ButtonPushedFcn = @(source, event) Obj.adjust(app, event);
                    Obj.Buttons.DecrOnset.ButtonPushedFcn = @(source, event) Obj.adjust(app, event);
                    Obj.Buttons.IncrOnset.ButtonPushedFcn = @(source, event) Obj.adjust(app, event);
                    Obj.Buttons.Cancel.ButtonPushedFcn = @(source, event) Obj.cancel(app, event);
                    Obj.Buttons.Submit.ButtonPushedFcn = @(source, event) Obj.submit(app, event);
                    if ~isempty(app.Props.SelectedEventId)
                        Obj.Buttons.Delete.ButtonPushedFcn = @(source, event) Obj.deleteone(app, event);
                    end
                end
                if length(app.Props.SelectedSegment) == 2
                    Obj.SelectedSegment = app.Props.SelectedSegment;
                    Obj.SelectedEventId = app.Props.SelectedEventId;
                    Obj.EventLabels = unique(app.ACT.analysis.events.label);
                    if isempty(Obj.SelectedEventId)
                        Obj.EventLabelValue = Obj.Labels.GroupValue.Value;
                    elseif isempty(Obj.EventLabelValue)
                        idx = app.ACT.analysis.events.id == Obj.SelectedEventId;
                        Obj.EventLabelValue = app.ACT.analysis.events.label{idx};
                        if ismember(Obj.EventLabelValue, Obj.DefaultEventLabels)
                            Obj.EventLabelIsEditable = false;
                        end
                    end
                    Obj.select(app); % Select metrics to display
                    Obj.Visible = 'on';
                else
                    Obj.Visible = 'off';
                    Obj.Metric = [];
                    Obj.SelectedSegment = [];
                    Obj.SelectedEventId = [];
                    Obj.EventLabels = {};
                    Obj.EventLabelValue = 'Select';
                end
                % Disable decrease duration to prevent negative duration
                if diff(app.Props.SelectedSegment) < 1/(24*60)
                    Obj.Buttons.DecrDuration.Enable = 'off';
                else
                    Obj.Buttons.DecrDuration.Enable = 'on';
                end
                % TODO disable moving the onset of the event past the start or end of recording
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in EventsExcerpt.m')
            end
        end
    end
end