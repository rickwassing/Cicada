% GETPANELHEIGHT
% Calculates the height of a 'Panel' object given the title, number of
% rows, and spacing and padding.

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

function h = getpanelheight(title, nrows, rowheight, rowspacing, padding)

if isempty(title)
    h = 2; % Top and bottom border
else
    h = 19;
end
h = h + rowheight*nrows + rowspacing*(nrows-1) + 2*padding;

end