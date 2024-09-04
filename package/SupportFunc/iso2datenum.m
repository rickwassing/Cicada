% ISO2DATENUM
% Converts a string in the ISO format 'yyyy-mm-ddTHH:MM:SS.FFF' to a 
% datenum.

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

function dtime = iso2datenum(dstr)
if length(dstr) == 5
    dtime = datenum(dstr, 'HH:MM'); %#ok<*DATNM>
elseif length(dstr) == 8
    dtime = datenum(dstr, 'HH:MM:SS');
elseif length(dstr) == 10
    dtime = datenum(dstr, 'yyyy-mm-dd');
elseif length(dstr) == 19
    dtime = datenum(dstr, 'yyyy-mm-ddTHH:MM:SS');
else
    dtime = datenum(dstr, 'yyyy-mm-ddTHH:MM:SS.FFF');
end
end