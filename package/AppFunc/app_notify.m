% APP_NOTIFY
% Emits an event,
%
% Usage:
%   >> app_notify(app, eventlabel, event);
%
% Inputs:
%   'app'         - [cicada object] handle to the Cicada app object.
%   'eventlabels' - [cell] the labels of the events to emit.
%   'event' - [Object] event data.
%
% Outputs: 
%   none
%
% See also NOTIFY.

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

function app_notify(app, eventlabels, event, varargin)
% -------------------------------------------------------------------------
Tag = 'Cicada';
if nargin > 3
    for i = 1:2:numel(varargin)
        switch lower(varargin{i})
            case 'tag'
                Tag = varargin{i+1};
        end
    end
end
% -------------------------------------------------------------------------
% Get the app-handle
if isempty(app)
    app = app_gethandle(Tag);
end
if isempty(app) || ~isvalid(app)
    return;
end
% -------------------------------------------------------------------------
% Go on and add the listeners
for i = 1:length(eventlabels)
    if app.Props.Verbose && ~strcmpi(eventlabels{i}, 'eMouseMotion')
        fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n')
        fprintf('>> CIC: Broadcast event ''%s''.\n', eventlabels{i})
        fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n')
    end
    if nargin == 2
        notify(app, eventlabels{i});
    elseif isempty(event)
        notify(app, eventlabels{i});
    elseif iscell(event)
        event = AppEventData(event{1}, event(2:end));
        notify(app, eventlabels{i}, event);
    else
        notify(app, eventlabels{i}, event);
    end
end
% -------------------------------------------------------------------------
% Display performance summary after event broadcast (for verbosity level 1+)
if app.Props.Verbose >= 1 && ~isempty(eventlabels)
    % Don't show summary for mouse motion events
    if ~any(ismember(eventlabels, {'eMouseMotion', 'eReportTabHovered'}))
        tracker = PerformanceTracker.getInstance();
        tracker.displaySummary(eventlabels{1});
    end
end
% -------------------------------------------------------------------------
end
