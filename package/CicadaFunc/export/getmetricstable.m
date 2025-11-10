% GETMETRICSTABLE
% Generates a 'table' with all the metrics, annotation, and events.
%
% Usage:
%   >> metricstable = getmetricstable(ACT);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure 
%
% Outputs:
%   'metricstable' - [table] contains the timeseries, and a column for each
%   metric type, annotation and events.
%
% See also CIC_NEWDATASET, CIC_EMPTYDATASET.

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

function [TBL, DICT] = getmetricstable(metric)
% -------------------------------------------------------------------------
% The output table must have all the timeseries sampled at the same
% sampling rate. In Cicada, this is not necessary. Check which variables 
% need to be upsampled to the highest sampling rate.
[maxsrate, idx] = max([metric.srate]);
pnts = metric(idx).pnts;
xmin = metric(idx).xmin;
% -------------------------------------------------------------------------
% Initialize the output table and data dictionary
DICT = table();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TBL = table();
TBL.datetime = cellstr(datetime2iso(gettimes(metric(idx))));
TBL.elapsed_time = gettimes(metric(idx));
TBL.elapsed_time = seconds(TBL.elapsed_time - TBL.elapsed_time(1));
% -------------------------------------------------------------------------
% Initialize counters
modality = metric(1).modality;
cnt = 0;
for i = 1:length(metric)
    this_modality = metric(i).modality;
    if ~strcmpi(modality, this_modality)
        cnt = 1;
        modality = this_modality;
    else
        cnt = cnt + 1;
    end
    if metric(i).srate ~= maxsrate
        % Upsample this metric
        isupsampled = 'yes';
        origsrate = metric(i).srate;
        metric(i) = upsampletimeseries(metric(i), maxsrate, pnts, xmin); %#ok<SAGROW>
    else
        isupsampled = 'no';
        origsrate = metric(i).srate;
    end
    % Place data in table
    fname = sprintf('%s_%i', metric(i).modality, cnt);
    TBL.(fname) = metric(i).y;
    % Write to data dictionary
    d = table();
    d.colheader = {fname};
    d.modality = {metric(i).modality};
    d.device = {metric(i).device};
    d.label = {metric(i).label};
    d.location = {metric(i).loc};
    d.unit = {metric(i).unit};
    d.isupsampled = {isupsampled};
    d.origsrate = origsrate;
    DICT = [DICT; d]; %#ok<AGROW>
end

end