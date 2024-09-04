% APP_SAVESETTINGS
% Saves the app settings
%
% Usage:
%   >> app_savesettings(settings);
%
% Inputs:
%   'settings' - [struct] cicada app settings
%
% Outputs: 
%   none

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

function app_savesettings(settings)

fullfilepath = [fileparts(which('cicada')), filesep, 'package', filesep, 'app_settings.json'];
jsonchar = jsonencode(settings, PrettyPrint=true);
fid = fopen(fullfilepath, 'w');
fprintf(fid, '%s', jsonchar);
fclose(fid);

end