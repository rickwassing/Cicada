% SET_DISPLAY
% Patches a single event
%
% Usage:
%   >> set_event(ACT, src, event);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'event' - [Object] event data.
%
% Outputs:
%   'ACT' - [struct] standardized ACT structure

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-07-25, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function ACT = set_event(ACT, event)
try
    % =========================================================================
    % Extract the user data from the source component
    Obj = [];
    Method = [];
    EventId = [];
    EventGroup = [];
    EventType = [];
    SelectedSegment = [];
    Color = [];
    Prop = [];
    Value = [];
    for i = 1:2:length(event.UserData.Payload)
        switch lower(event.UserData.Payload{i})
            case 'obj'
                Obj = event.UserData.Payload{i+1};
            case 'method'
                Method = event.UserData.Payload{i+1};
            case 'eventid'
                EventId = event.UserData.Payload{i+1};
            case 'eventgroup'
                EventGroup = event.UserData.Payload{i+1};
            case 'eventtype'
                EventType = event.UserData.Payload{i+1};
            case 'selectedsegment'
                SelectedSegment = event.UserData.Payload{i+1};
            case 'color'
                Color = event.UserData.Payload{i+1};
            case 'prop'
                Prop = event.UserData.Payload{i+1};
            case 'value'
                Value = event.UserData.Payload{i+1};
        end
    end
    % =====================================================================
    switch Method
        case 'create'
            % -------------------------------------------------------------
            % CREATE NEW EVENT
            % -------------------------------------------------------------
            % Check if this event label and type already exists
            doesexist = ...
                strcmpi(ACT.analysis.events.label, EventGroup) & ...
                strcmpi(ACT.analysis.events.type, 'manual');
            % -------------------------------------------------------------
            % If it does exist, extract the color
            if any(doesexist)
                color = ACT.analysis.events.color{find(doesexist, 1, 'first')};
                % check if it overlaps with an existing event of the same
                % label and type
                cfg.Start = datenum2iso(SelectedSegment(1));
                cfg.End = datenum2iso(SelectedSegment(2));
                events = cropevents(ACT.analysis.events, cfg);
                has_overlap = ...
                    strcmpi(events.label, EventGroup) & ...
                    strcmpi(events.type, 'manual');
                events = events(has_overlap, :);
                if ~isempty(events)
                    onsets = cellfun(@(dstr) iso2datenum(dstr), events.onset);
                    durations = cellfun(@(dstr) iso2duration(dstr), events.duration);
                    offsets = onsets + durations;
                    SelectedSegment(1) = min([SelectedSegment(1); onsets]);
                    SelectedSegment(2) = max([SelectedSegment(2); offsets]);
                    idx_rm = find(ismember(ACT.analysis.events.id, events.id));
                else
                    idx_rm = [];
                end
            else
                % Does not exist yet, get color
                ncolors = length(unique(cellfun(@(l, t) strcat(l, t), ACT.analysis.events.label, ACT.analysis.events.type, 'UniformOutput', false)));
                color = app_colors('nth', ncolors+1);
                idx_rm = [];
            end
            % -------------------------------------------------------------
            % Create new table row entry
            tmp = table();
            if isempty(ACT.analysis.events)
                tmp.id = 1;
            else
                tmp.id = max(ACT.analysis.events.id)+1;
            end
            tmp.onset = {datenum2iso(SelectedSegment(1), 'omitmilliseconds')};
            tmp.duration = {duration2iso(SelectedSegment(2) - SelectedSegment(1))};
            tmp.label = {EventGroup};
            tmp.type = {'manual'};
            tmp.color = {color};
            tmp.show = true;
            % -------------------------------------------------------------
            % Append the event
            if isempty(ACT.analysis.events)
                ACT.analysis.events = tmp;
            else
                ACT.analysis.events = [ACT.analysis.events; tmp];
            end
            % remove any overlapping events
            ACT.analysis.events(idx_rm, :) = [];
            % sort by onset
            [~, idx] = sort(ACT.analysis.events.onset);
            ACT.analysis.events = ACT.analysis.events(idx, :);
        case 'updateone'
            % -------------------------------------------------------------
            % UPDATE EXISTING EVENT
            % -------------------------------------------------------------
            % Get the index of the event we're updating
            idx = ACT.analysis.events.id == EventId;
            % -------------------------------------------------------------
            % Update the onset and duration
            ACT.analysis.events.onset{idx} = datenum2iso(SelectedSegment(1), 'omitmilliseconds');
            ACT.analysis.events.duration{idx} = duration2iso(SelectedSegment(2) - SelectedSegment(1));
            % -------------------------------------------------------------
            % If the label changed, then also change the color
            if ~strcmpi(ACT.analysis.events.label{idx}, EventGroup)
                % Set new label
                ACT.analysis.events.label{idx} = EventGroup;
                % Find new color
                doesexist = ...
                    strcmpi(ACT.analysis.events.label, EventGroup) & ...
                    strcmpi(ACT.analysis.events.type, 'manual');
                if any(doesexist)
                    ACT.analysis.events.color{idx} = ACT.analysis.events.color{find(doesexist, 1, 'first')};
                else
                    % Does not exist yet, get color
                    ncolors = length(unique(cellfun(@(l, t) strcat(l, t), ACT.analysis.events.label, ACT.analysis.events.type, 'UniformOutput', false)));
                    ACT.analysis.events.color{idx} = app_colors('nth', ncolors+1);
                end
            end
        case 'updatemany'
            % -------------------------------------------------------------
            % UPDATE EXISTING EVENT GROUP
            % -------------------------------------------------------------
            idx = find(strcmpi(ACT.analysis.events.label, EventGroup) & strcmpi(ACT.analysis.events.type, EventType));
            for i = 1:length(idx)
                if iscell(ACT.analysis.events.(Prop))
                    ACT.analysis.events.(Prop){idx(i)} = Value;
                else
                    ACT.analysis.events.(Prop)(idx(i)) = Value;
                end
            end
        case 'deleteone'
            % -------------------------------------------------------------
            % DELETE EXISTING EVENT
            % -------------------------------------------------------------
            idx = ACT.analysis.events.id == EventId;
            ACT.analysis.events(idx, :) = [];
        case 'deletemany'
            % -------------------------------------------------------------
            % DELETE EXISTING EVENT GROUP
            % -------------------------------------------------------------
            idx = find(strcmpi(ACT.analysis.events.label, EventGroup) & strcmpi(ACT.analysis.events.type, EventType));
            ACT.analysis.events(idx, :) = [];
        case 'setcolor'
            % -------------------------------------------------------------
            % SET THE COLOR OF A EVENT GROUP
            % -------------------------------------------------------------
            idx = find(strcmpi(ACT.analysis.events.label, EventGroup) & strcmpi(ACT.analysis.events.type, EventType));
            for i = 1:length(idx)
                ACT.analysis.events.color{idx(i)} = Color;
            end
        otherwise
            disp(Method)
            keyboard
    end
    % ---------------------------------------------------------------------
    % If the currenst status is saved, then change it to unsaved
    if strcmpi(ACT.status, 'saved')
        ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    end
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end

end