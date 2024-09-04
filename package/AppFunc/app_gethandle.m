% APP_GETHANDLE
% Returns a handle to the currently running app
%
% Usage:
%   >> app_gethandle();
%
% Inputs:
%   none
%
% Outputs: 
%   'app' - [cicada object] handle to the Cicada app object.

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

function app = app_gethandle()
% -------------------------------------------------------------------------
% Get the app-handle
app = findall(groot, 'Tag', 'Cicada');
if isvalid(app)
    app = app.RunningAppInstance;
else
    app = [];
end
% -------------------------------------------------------------------------
end