% PARSEKEYVALS
% Parces a cell-array where the odd elements are keys, and the even ones
% are values

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2025-09-18, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function cfg = parsekeyvals(cellarray)
for i = 1:2:length(cellarray)
    cfg.(cellarray{i}) = cellarray{i+1};
end
end