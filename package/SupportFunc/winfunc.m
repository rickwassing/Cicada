% WINFUNC
% Applies the function 'fcn' once per window as the window moves over X,
% where 'k' is the size of the window. 
%
% Optional inputs:
%   'Stride'    - [double] Non-negative scalar step size between windows
%   'NanFlag'   - [char] {'includenan', 'omitnan'} 'includenan' is default
%   'EndPoints' - [char] {'shrink', 'discard'} 'shrink' is default
%   'Times'     - [double] Vector of timeseries same size as X

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

function [Y, Times] = winfunc(fcn, X, k, varargin)
% ---------------------------------------------------------------------
% Parse variable arguments in
Stride = 1;
NanFlag = 'includenan';
EndPoints = 'shrink';
Times = 1:length(X);
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'stride'
            Stride = varargin{i+1};
        case 'nanflag'
            NanFlag = varargin{i+1};
        case 'endpoints'
            EndPoints = varargin{i+1};
        case 'times'
            Times = varargin{i+1};
    end
end
% ---------------------------------------------------------------------
% Check input
if ~isnumeric(X)
    error('X must be numeric')
end
if ~any(size(X)) == 1 || length(size(X)) > 2
    error('X must be a vector');
end
if size(X, 1) == 1
    X = X'; % force column vector
end
if ~isscalar(k)
    error('k must be a scalar');
end
if ~isscalar(Stride)
    error('Stride must be a scalar');
end
if k <= 0
    error('k must be positive');
end
if k > length(X)
    error('k cannot be bigger than number of elements in X');
end
if Stride <= 0
    error('Stride must be positive');
end
if mod(k, 1) ~= 0
    error('k must be an integer');
end
if mod(Stride, 1) ~= 0
    error('Stride must be an integer');
end
% ---------------------------------------------------------------------
% Apply the requested function
switch fcn
    case 'mean'
        Y = movmean(X, k, NanFlag, 'EndPoints', EndPoints);
    case 'median'
        Y = movmedian(X, k, NanFlag, 'EndPoints', EndPoints);
    case 'std'
        Y = movstd(X, k, NanFlag, 'EndPoints', EndPoints);
    case 'var'
        Y = movvar(X, k, NanFlag, 'EndPoints', EndPoints);
end
% Select the time-points
switch lower(EndPoints)
    case 'discard'
        Times = Times(floor(k/2+1):end-ceil(k/2)+1);
    case 'shrink'
        % Don't have to select any sub-samples
end
% If Stride is larger than one, then take only the n-th window
if Stride ~= 1
    Y = Y(1:Stride:end);
    Times = Times(1:Stride:end);
end
end