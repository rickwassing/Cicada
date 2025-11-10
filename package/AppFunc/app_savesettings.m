% APP_SAVESETTINGS
% Saves the app settings
%
% Usage:
%   >> app_savesettings(settings);
%
% Inputs:
%   's' - [struct] cicada app settings, or any other structure
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

% TODO: rename this function to reflect its generalizad
function app_savesettings(s, varargin)
% -------------------------------------------------------------------------
% Assume we want to save the main app settings
fullfilepath = [fileparts(which('cicada')), filesep, 'package', filesep, 'app_settings.json'];
% -------------------------------------------------------------------------
% Check the varargin 
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'fullfilepath'
            fullfilepath = varargin{i+1};
    end
end
% -------------------------------------------------------------------------
jsonchar = jsonencode(s, PrettyPrint=true); % convert to JSON
% -------------------------------------------------------------------------
% Save to file
fid = fopen(fullfilepath, 'w'); 
fprintf(fid, '%s', jsonchar);
fclose(fid);

end