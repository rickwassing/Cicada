% UPSAMPLETIMESERIES
% Upsamples a timeseries field (e.g., from ACT.metric, or ACT.data) to a
% higher sampling rate.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-12-11, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function metric = upsampletimeseries(metric, newsrate, pnts, xmin)

% -------------------------------------------------------------------------
% Construct existing timeseries interval vector
X = ascolumn(gettimes(metric));
% -------------------------------------------------------------------------
% Construct new timeseries interval vector
cfg.xmin = xmin;
cfg.srate = newsrate;
cfg.pnts = pnts;
Xq = gettimes(cfg);
% -------------------------------------------------------------------------
% Interpolate Y-values sampled at X to samples of Xq
Yq = interp1(X, metric.y, Xq);
% -------------------------------------------------------------------------
% Overwrite some of the fields in the metric and return
metric.y = Yq;
metric.srate = newsrate;
metric.pnts = pnts;
metric.xmin = datetime2iso(Xq(1));
metric.xmax = datetime2iso(Xq(end));

end