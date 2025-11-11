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
try
    % Load settings from file
    settings = jsondecode(fileread('app_settings.json'));
    % Make sure the App ID is set
    if ~isfield(settings, 'App')
        settings = initappsettings(settings);
    end
    if ~isfield(settings, 'Reports')
        settings = initreportsettings(settings);
    end
catch ME
    % There was an unexpected error when reading the settings file
    fprintf('>> CIC: Could not load app settings, using default values.\n');
    % Return new initialized settings
    settings = initappsettings();
    settings = initreportsettings(settings);
end
% Add session id
settings.App.SessionId = char(java.util.UUID.randomUUID);
settings.App.CicadaVersion = cic_version();
[settings.App.SystemOS, settings.App.SystemVersion] = detectoperatingsystem();
settings.App.MatlabVersion = version();

% Check that all required fields exist
settings = requiredappsettings(settings);

% -------------------------------------------------------------------------
% Local support function to initialize new settings structure
    function s = initappsettings(varargin)
        % Check if we can append the existing structure or initialize a new one.
        if nargin == 1
            % Extract existing settings structure
            s = varargin{1};
        else
            % Init empty structure
            s = struct();
        end
        % Create random unique identifier
        s.App.Id = getuuid('full');
        % Save to settings file
        app_savesettings(s);
    end
% -------------------------------------------------------------------------
    function s = initreportsettings(s)
        s.Report = defaultreportstate();
        % Get logo source
        resourcesPath = fileparts(which('app_settings.json'));
        resourcesLogo = dir(fullfile(resourcesPath, 'resources', 'report_logo_*'));
        if ~isempty(resourcesLogo)
            s.Report.LogoSource = fullfile(resourcesLogo(1).folder, resourcesLogo(1).name);
        else
            s.Report.LogoSource = '';
        end
        % Save to settings file
        app_savesettings(s);
    end
end
