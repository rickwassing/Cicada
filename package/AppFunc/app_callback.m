% APP_CALLBACK
% Wrapper function for any callback
%
% Usage:
%   >> app_callback(src, event, fcn);
%
% Inputs:
%   'event' - [Object] event data.
%   'fcn' - [char] name of the function to call.
%   'EventName' - [cell] name of events, specified as case-sensitive,
%      quoted text that is defined in the app.
%
% Outputs:
%   none

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

function app_callback(event, fcn, EventName)
try
    % -------------------------------------------------------------------------
    % Get the app handle
    app = app_gethandle();
    if isempty(app)
        return;
    end
    % -------------------------------------------------------------------------
    % Check the dataset status
    currentStatus = app.ACT.status;
    if strcmpi(app.ACT.status, 'error')
        return; % Do not do anything to the dataset if it is in an error status
    end
    % -------------------------------------------------------------------------
    % Set the app's status
    app.hStatus(event, 'Loading');
    % -------------------------------------------------------------------------
    % Check that the function exists
    if exist(fcn) == 0 %#ok<EXIST>
        error('Function ''%s'' does not exist.', fcn);
    end
    % -------------------------------------------------------------------------
    % Run the function
    app.ACT = eval(sprintf('%s(app.ACT, event);', fcn));
    % -------------------------------------------------------------------------
    % Notify
    app_notify(app, EventName);
    % Broadcast 'eDatasetStatusChanged' in case the status did change
    if ~strcmpi(app.ACT.status, currentStatus)
        app_notify(app, {'eDatasetStatusChanged'});
    end
    % -------------------------------------------------------------------------
    % Set the app's status
    app.hStatus(event, 'Idle');
catch ME % Something went wrong
    cfg.DoShow = true;
    cfg.Message = ME;
    app.hStatus(event, 'Error', cfg);
end

end