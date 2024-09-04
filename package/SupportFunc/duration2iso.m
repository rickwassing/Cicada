% DURATION2ISO
% Converts a duration in days to the ISO8601 duration format
% 'PT[n]H[n]M[n]S'. Note that days, months and years are not part of the
% supported formatting and milliseconds are ignored, and 'n' must be a 
% positive integer.

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

function dstr = duration2iso(D)
H = floor(D*24);
RH = D*24 - H;
M = floor(RH*60);
RM = RH*60 - M;
S = floor(RM*60);
RS = RM*60 - S;
if round(RS) > 0
    S = S + 1;
    if S == 60
        S = 0;
        M = M + 1;
    end
    if M == 60
        M = 0;
        H = H + 1;
    end
end
dstr = 'PT';
if H > 0
    dstr = [dstr, num2str(H), 'H'];
end
if M > 0
    dstr = [dstr, num2str(M), 'M'];
end
if S > 0
    dstr = [dstr, num2str(S), 'S'];
end
if length(dstr) == 2
    dstr = 'PT0S';
end
end