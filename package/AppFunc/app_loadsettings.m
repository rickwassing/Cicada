% APP_LOADSETTINGS
% Saves the app settings
%
% Usage:
%   >> settings = app_loadsettings();
%
% Inputs:
%   none
%
% Outputs:
%   'settings' - [struct] cicada app settings

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-08-10, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function settings = app_loadsettings()

settings = jsondecode(fileread('app_settings.json'));

end