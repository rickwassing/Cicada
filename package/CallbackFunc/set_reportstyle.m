% SET_REPORTSTYLE
% Update the report settings i.e., font, font-size, color etc.
%
% Usage:
%   >> set_reportstyle(ACT, src, event);
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

function state = set_reportstyle(state, event)
try
    % =========================================================================
    % 
    fnames = strsplit(event.Source.Tag, '-');
    state.style = setnestedfield(state.style, fnames, event.Value);
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    printerrormessage(ME);
end
end