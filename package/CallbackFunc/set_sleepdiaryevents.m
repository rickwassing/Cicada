% SET_SLEEPDIARYEVENTS
% Creates sleep diary events
%
% Usage:
%   >> set_sleepdiaryevents(ACT, src, event);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'event' - [Object] event data with payload.
%
% Outputs:
%   'ACT' - [struct] standardized ACT structure

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-11-21, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function ACT = set_sleepdiaryevents(ACT, event)

try
    % =====================================================================
    % Extract the settings and filepath
    Settings = [];
    Filepath = [];
    for i = 1:2:length(event.UserData.Payload)
        switch lower(event.UserData.Payload{i})
            case 'settings'
                Settings = event.UserData.Payload{i+1};
            case 'filepath'
                Filepath = event.UserData.Payload{i+1};
        end
    end
    % ---------------------------------------------------------------------
    if isempty(Settings) || isempty(Filepath)
        return
    end
    % =====================================================================
    % Import data using cicada function
    cfg = struct();
    cfg.Filepath = Filepath;
    cfg.Settings = Settings;
    ACT = cic_importsleepdiary(ACT, cfg);
    
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end

end