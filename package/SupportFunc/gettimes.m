% GETTIMES
% Calculates a timeseries from the start-date, number of samples and
% sampling rate.

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

function times = gettimes(s, varargin)

times = datetime(s.xmin, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS') + seconds(0:1/s.srate:(s.pnts/s.srate-1/s.srate))';

if nargin > 1
    switch lower(varargin{1})
        case 'datenum'
            times = datenum(times);
    end
end
end
