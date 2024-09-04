% DATETIME2ISO
% Converts a datetime object to char in the ISO format
% 'yyyy-mm-ddTHH:MM:SS.FFF'.

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-03-17, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function dstr = datetime2iso(dtime, varargin)
% -------------------------------------------------------------------------
% Default format
format = 'uuuu-MM-dd''T''HH:mm:ss.SSS';
% -------------------------------------------------------------------------
if nargin > 1
    switch lower(varargin{1})
        case 'dateonly'
            format = 'uuuu-MM-dd';
        case 'omitmilliseconds'
            format = 'uuuu-MM-dd''T''HH:mm:ss';
        case 'omitseconds'
            format = 'uuuu-MM-dd''T''HH:mm';
    end
end
% -------------------------------------------------------------------------
dstr = char(dtime, format);
end