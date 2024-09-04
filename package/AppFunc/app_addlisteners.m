% APP_ADDLISTENERS
% Add an event listener to a component using a specific event label and
% with the app as it's source.
%
% Usage:
%   >> app_addlisteners(app, component, eventlabel);
%
% Inputs:
%   'app'         - [cicada object] handle to the Cicada app object.
%   'component'   - [object] any sub-component of the Cicada app (must
%                   contain a method called 'hUpdate'). 
%   'eventlabels' - [cell] the labels of the events to listen for.
%
% Outputs: 
%   none
%
% See also ADDLISTENER.

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-03-17, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function app_addlisteners(app, component, eventlabels)
% -------------------------------------------------------------------------
% Get the app-handle
if isempty(app)
    app = app_gethandle();
end
if isempty(app)
    return;
end
% -------------------------------------------------------------------------
% Go on and add the listeners
for i = 1:length(eventlabels)
    addlistener(app, eventlabels{i}, @(app, event) component.hUpdate(app, event));
end
% -------------------------------------------------------------------------
end