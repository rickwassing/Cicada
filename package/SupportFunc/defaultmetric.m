% DEFAULTMETRIC
% Construct the default metric from raw data, or overwrite existing metric

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

function [metric, idx] = defaultmetric(Y, T, label, winlen, data, current)
% -------------------------------------------------------------------------
% Check if metric already exists
idx = ...
    strcmpi({current.modality}, data.modality) & ...
    strcmpi({current.device}, data.device) & ...
    strcmpi({current.label}, label) & ...
    strcmpi({current.loc}, data.loc);
% -------------------------------------------------------------------------
% Metric already exists, just overwrite the data and time info
if any(idx) && false
    metric = current(idx);
    metric.y = Y;
    metric.srate = data.srate/winlen;
    metric.pnts = length(Y);
    metric.xmin = datetime2iso(T(1));
    metric.xmax = datetime2iso(T(end));
else
    % ---------------------------------------------------------------------
    % Metric does not exist already, construct new
    idx = -1;
    metric = struct();
    metric.modality = data.modality;
    metric.device = data.device;
    metric.label = label;
    metric.loc = data.loc;
    metric.unit = ifelse(strcmpi(label, 'angle_z'), '°', data.unit);
    metric.y = Y;
    metric.srate = data.srate/winlen;
    metric.pnts = length(Y);
    metric.xmin = datetime2iso(T(1));
    metric.xmax = datetime2iso(T(end));
    metric.height = ifelse(strcmpi(data.modality, 'accel'), 2, 1);
    metric.show = ifelse(strcmpi(label, 'angle_z'), false, true);
    metric.log = ifelse(strcmpi(data.modality, 'light'), true, false);
    metric.color = -1;
    metric.zindex = 1000 + sum(strcmpi({current.modality}, data.modality));
    switch metric.label
        case 'euclidean norm'
            metric.ymin = 0;
            metric.ymax = 1;
        case 'angle_z'
            metric.ymin = -180;
            metric.ymax = 180;
        otherwise
            metric.ymin = data.ymin;
            metric.ymax = data.ymax;
    end
end

end