% REQUIREDAPPSETTINGS
% Checks required app settings

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-07, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function s = requiredappsettings(s)
% -------------------------------------------------------------------------
haschanged = false;
% -------------------------------------------------------------------------
% App meta-data
if ~isfield(s, 'App')
    s.App.Id = char(java.util.UUID.randomUUID);
    haschanged = true;
end
if isfield(s, 'Auth')
    if ~isfield(s.Auth, 'name')
        s.Auth.name = 'anonymous';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'institute')
        s.Auth.institute = 'n/a';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'email')
        s.Auth.email = 'john@doe.com';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'subscribe')
        s.Auth.subscribe = 'no';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'accept')
        s.Auth.accept = 'no';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'is_registered')
        s.Auth.is_registered = 'no';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'shareusagedata')
        s.Auth.shareusagedata = 'no';
        haschanged = true;
    end
    if ~isfield(s.Auth, 'datetime')
        dt = datetime('now', 'TimeZone', 'local');
        dt = sprintf('%s (%s)', char(dt, 'uuuu-MM-dd''T''HH:mm:ss'), dt.TimeZone);
        s.Auth.datetime = dt;
        haschanged = true;
    end
end
% -------------------------------------------------------------------------
% Check that all files exist on this computer
if isfield(s, 'Recent')
    idx_rm = [];
    for i = 1:length(s.Recent)
        if exist(s.Recent{i}, 'file') ~= 2
            idx_rm = [idx_rm, i]; %#ok<AGROW>
        end
    end
    if ~isempty(idx_rm)
        s.Recent(idx_rm) = [];
        haschanged = true;
    end
end
% -------------------------------------------------------------------------
% Save settings file if anything has changed
if haschanged
    app_savesettings(s);
end

end