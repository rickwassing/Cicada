% CROPEVENTS
% Crop the events

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-11-07, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function events = cropevents(events, cfg)
if isempty(events)
    return
end
eventonsets = iso2datetime(events.onset);
eventoffsets = iso2datetime(events.onset) + days(cellfun(@(dstr) iso2duration(dstr), events.duration));
idx = ...
    (eventonsets <= iso2datetime(cfg.Start) & eventoffsets > iso2datetime(cfg.Start)) | ...
    (eventonsets <= iso2datetime(cfg.End) & eventoffsets > iso2datetime(cfg.Start));
events = events(idx, :);
end