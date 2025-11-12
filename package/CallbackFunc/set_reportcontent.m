% SET_REPORTCONTENT
% Update the report template content i.e., header info etc.
%
% Usage:
%   >> set_reportcontent(state, event);
%
% Inputs:
%   'state' - [struct] app state
%   'event' - [Object] event data.
%
% Outputs:
%   'state' - [struct] app state

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

function state = set_reportcontent(state, event)
try
    % =========================================================================
    src = event{2};
    fnames = strsplit(src.Keys, '-');
    val = src.Text;
    state = setnestedfield(state, fnames, val);
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    printerrormessage(ME);
end
end