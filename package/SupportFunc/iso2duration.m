% ISO2DURATION
% Converts a string in the ISO format 'PT[n]H[n]M[n]S' to a 
% duration in days. Note that this function is not capable of parsing the
% years, months and days, since years and months are arbitrary and days can
% easily be expressed in hours, and 'n' must be a positive integer.

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-11-03, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function dur = iso2duration(dstr)
dur = nan;
if ~ischar(dstr)
    error('Input ''dstr'' must be a character array.')
end
if ~strcmpi(dstr(1:2), 'PT')
    error('Input ''dstr'' must be start with ''PT''.')
end
% -------------------------------------------------------------------------
% Make upper-case
dstr = upper(dstr);
% -------------------------------------------------------------------------
% Extract hours
[i, j] = regexp(dstr, '[0-9]*H');
if ~isempty(i)
    H = str2double(dstr(i:j-1));
else
    H = 0;
end
% -------------------------------------------------------------------------
% Extract minutes
[i, j] = regexp(dstr, '[0-9]*M');
if ~isempty(i)
    M = str2double(dstr(i:j-1));
else
    M = 0;
end
% -------------------------------------------------------------------------
% Extract seconds
[i, j] = regexp(dstr, '[0-9]*S');
if ~isempty(i)
    S = str2double(dstr(i:j-1));
else
    S = 0;
end
% -------------------------------------------------------------------------
% Combine
dur = H/(24) + M/(24*60) + S/(24*60*60);

end