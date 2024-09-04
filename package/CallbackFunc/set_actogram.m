% SET_ACTOGRAM
% Update actogram configuration
%
% Usage:
%   >> set_actogram(ACT, src, event);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'event' - [Object] event data.
%
% Outputs: 
%   'ACT' - [struct] standardized ACT structure

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

function ACT = set_actogram(ACT, event)
try
    % -------------------------------------------------------------------------
    % Update the actogram settings
    switch lower(event.Source.Tag)
        case 'length'
            MaxDays = 1 + ceil(iso2datenum(ACT.xmax) - iso2datenum(ACT.xmin));
            if strcmpi(event.Value, 'all')
                ACT.info.actogram.length = MaxDays;
            else
                ACT.info.actogram.length = min([MaxDays, str2double(event.Value)]);
            end
        case 'width'
            ACT.info.actogram.width = event.Value;
        case 'clockstart'
            ACT.info.actogram.start = event.Value;
        case 'clockend'
            ACT.info.actogram.end = event.Value;
    end
    % -------------------------------------------------------------------------
    % If the currenst status is saved, then change it to unsaved
    if strcmpi(ACT.status, 'saved')
        ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    end
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end

end