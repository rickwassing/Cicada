% EVENTSGROUPPANEL
% The container to list all event groups

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

classdef EventGroupPanel < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        EventGroupList;
        NumEventList;
        DoShowList;
        ColorList;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        EventGroup EventGroup
        Placeholder Placeholder
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
            Obj.Tag = 'EventGroupPanel';
            % -------------------------------------------------------------
            Obj.Panel = uipanel(Obj, ...
                'BorderType', 'none', ...
                'Tag', 'EventGroupPanel_Panel', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_primary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'EventsGroupPanel_GridLayout', ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 0, ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_primary);
            % -------------------------------------------------------------
            Obj.Placeholder = Placeholder(Obj.GridLayout, ...
                'ImageSrc', 'no-events.png', ...
                'Header', 'No events.', ...
                'SubHeader', '', ...
                'Size', 95, ...
                'BackgroundColor', Colors.bg_primary); %#ok<PROP>
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                Obj.GridLayout.RowHeight = repmat({26}, 1, size(Obj.EventGroupList, 1));
                for i = 1:size(Obj.EventGroupList, 1)
                    DoRender = false;
                    if i > length(Obj.EventGroup)
                        DoRender = true;
                    elseif ~isvalid(Obj.EventGroup(i))
                        DoRender = true;
                    end
                    if DoRender
                        Obj.EventGroup(i) = EventGroup(Obj.GridLayout); %#ok<PROP>
                    end
                    Obj.EventGroup(i).LabelText = Obj.EventGroupList.label{i};
                    Obj.EventGroup(i).TypeText = Obj.EventGroupList.type{i};
                    Obj.EventGroup(i).NumEvents = Obj.NumEventList(i);
                    Obj.EventGroup(i).DoShow = Obj.DoShowList(i);
                    Obj.EventGroup(i).Color = Obj.ColorList{i};
                    Obj.EventGroup(i).Verbose = Obj.Verbose;
                    Obj.EventGroup(i).Layout.Column = 1;
                    Obj.EventGroup(i).Layout.Row = i;
                end
                for i = length(Obj.EventGroup):-1:size(Obj.EventGroupList, 1)+1
                    delete(Obj.EventGroup(i))
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: EventGroupPanel updated in %.1g s.\n', (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in EventGroupPanel.m')
            end
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, ~)
            try
                % ---------------------------------------------------------
                if isempty(app.ACT)
                    Obj.EventGroupList = {};
                    return
                end
                if isempty(app.ACT.analysis.events)
                    Obj.EventGroupList = {};
                    Obj.GridLayout.RowHeight = {'1x'};
                    Obj.Placeholder.Visible = 'on';
                    return
                end
                Obj.Placeholder.Visible = 'off';
                % ---------------------------------------------------------
                % Get the unique combinations of the event labels and type
                idx = ismember(app.ACT.analysis.events.Properties.VariableNames, {'label', 'type'});
                Obj.EventGroupList = unique(app.ACT.analysis.events(:, idx));
                Obj.NumEventList = nan(size(Obj.EventGroupList, 1), 1);
                Obj.DoShowList = nan(size(Obj.EventGroupList, 1), 1);
                Obj.ColorList = cell(size(Obj.EventGroupList, 1), 1);
                for i = 1:size(Obj.EventGroupList, 1)
                    idx = strcmpi(app.ACT.analysis.events.label, Obj.EventGroupList.label{i}) & ...
                        strcmpi(app.ACT.analysis.events.type, Obj.EventGroupList.type{i});
                    Obj.NumEventList(i) = sum(idx);
                    Obj.DoShowList(i) = all(app.ACT.analysis.events.show(idx));
                    Obj.ColorList{i} = app.ACT.analysis.events.color{find(idx, 1, 'first')};
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in EventGroupPanel.m')
            end
        end
    end
end