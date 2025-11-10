% ASCOLUMN
% Forces any vector to be a row vector

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-12-12, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function v = asrow(v)
if isempty(v)
    return
end
if ~(any(size(v) == 1))
    error('Input needs to be a vector')
end
if iscolumn(v)
    v = v';
end
end