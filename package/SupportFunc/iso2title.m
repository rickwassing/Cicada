% ISO2TITLE
% Converts two dates to a human readable string

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

function dstr = iso2title(isostart, isoend)
% ---------------------------------------------------------------------
% Get day, date, month, and year
Start.day = char(datetime(isostart, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'eeee');
Start.date = char(datetime(isostart, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'dd');
Start.month = char(datetime(isostart, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'MMMM');
Start.year = char(datetime(isostart, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'uuuu');
End.day = char(datetime(isoend, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'eeee');
End.date = char(datetime(isoend, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'dd');
End.month = char(datetime(isoend, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'MMMM');
End.year = char(datetime(isoend, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), 'uuuu');
% ---------------------------------------------------------------------
% Run
if ~strcmpi(Start.year, End.year)
    dstr = [...
        Start.day, ' ', Start.date, ' ', Start.month, ' ', Start.year, ' -- ', ...
        End.day, ' ', End.date, ' ', End.month, ' ', End.year];
elseif ~strcmpi(Start.month, End.month)
    dstr = [...
        Start.day, ' ', Start.date, ' ', Start.month, ' -- ', ...
        End.day, ' ', End.date, ' ', End.month, ' ', End.year];
else
    dstr = [...
        Start.day, ' ', Start.date, ' -- ', ...
        End.day, ' ', End.date, ' ', End.month, ' ', End.year];
end
end