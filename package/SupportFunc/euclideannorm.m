% EUCLIDEANNORM
% Calculates the Euclidean Norm i.e., the distance from the origin in an
% n-dimensional space. For actigraphy, this is the vector from the measured
% acceleration in units 'g' in 3D space (x, y, z) to the origin [0, 0, -1],
% where -1 is to correct for gravity.

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

function Y = euclideannorm(X)
% ---------------------------------------------------------------------
% Check input
if ~isnumeric(X)
    error('X must be numeric')
end
if ~any(size(X)) == 3 || length(size(X)) > 2
    error('X must be a maxtix of size <N-by-3>');
end
if size(X, 1) == 3
    X = X'; % force X, Y, and Z to be the columns
end
% ---------------------------------------------------------------------
% Calculate ENMO
Y = sqrt(...
    X(:, 1) .^2 + ...
    X(:, 2) .^2 + ...
    X(:, 3) .^2) - 1;
Y(Y < 0) = 0;
end