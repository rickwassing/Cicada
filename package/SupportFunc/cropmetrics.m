% CROPMETRICS
% Crop a data structure

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

function data = cropmetrics(data, cfg)
if isfield(cfg, 'ForEvent')
    t = gettimes(data);
    idx = (t >= iso2datetime(cfg.Start) & t < iso2datetime(cfg.Start) + 30/(24*60));
    y_start = data.y(idx, :);
    idx = (t >= iso2datetime(cfg.End) - 30/(24*60) & t < iso2datetime(cfg.End));
    y_end = data.y(idx, :);
    y_mid = nan(10*60*data.srate-1, 1);
    data.y = [y_start; y_mid; y_end];
    data.pnts = size(data.y, 1);
    data.xmin = datetime2iso(datetime(1, 'ConvertFrom', 'datenum'));
    data.xmax = datetime2iso(datetime(1+70/(24*60)-(1/data.srate)/(24*60*60), 'ConvertFrom', 'datenum'));
else
    t = gettimes(data);
    idx = find(isbetween(t, iso2datetime(cfg.Start), iso2datetime(cfg.End)));
    data.y = data.y(idx, :);
    data.pnts = size(data.y, 1);
    data.xmin = datetime2iso(t(idx(1)));
    data.xmax = datetime2iso(t(idx(end)));
end
end