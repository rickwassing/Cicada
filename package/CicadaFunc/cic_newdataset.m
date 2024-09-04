% CIC_NEWDATASET
% Imports accelerometry data and creates a new standardized 'ACT' dataset.
%
% Usage:
%   >> ACT = cic_newdataset([], cfg);
%
% Inputs:
%   'cfg' - [struct] configuration settings with the fields:
%           - 'Type' [char] {'geneactiv', 'actigraph'} type of dataset
%           - 'FullFilePath' [char] full path to source file
%
% Outputs:
%   'ACT' - [struct]

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

function ACT = cic_newdataset(~, cfg)
try
    % ---------------------------------------------------------------------
    % Replace backslashes in the filepath
    cfg.FullFilePath = strrep(cfg.FullFilePath, filesep, '/');
    % ---------------------------------------------------------------------
    ACT = cic_emptydataset(cfg.FullFilePath);
    switch lower(cfg.Type)
        % -----------------------------------------------------------------
        case 'geneactiv'
            ACT = importgeneactiv(ACT, cfg);
            % -------------------------------------------------------------
        case 'actigraph'
            ACT = importactigraphgt3x(ACT, cfg);
            % -------------------------------------------------------------
        otherwise
            ACT = struct([]);
            fprintf('>> CIC: No data imported because ''%s'' is not supported.\n', cfg.Type)
    end
    % ---------------------------------------------------------------------
    % Check if dataset is not empty (e.g., cancel button pressed)
    if isempty(ACT)
        fprintf('>> CIC: Importing new dataset was cancelled by the user.\n');
        return
    end
    % ---------------------------------------------------------------------
    % Crop to first and last full even minute
    Times = datevec(gettimes(ACT.data(1)));
    idxStart = find(mod(Times(:, 5), 2) == 0 & abs(diff([NaN; Times(:, 6)])) > 2/ACT.data(1).srate, 1, 'first');
    idxEnd = find(mod(Times(:, 5), 2) == 0 & abs(diff([NaN; Times(:, 6)])) > 2/ACT.data(1).srate, 1, 'last');
    cfg_crop.Start = datevec2iso(Times(idxStart, :));
    cfg_crop.End = datevec2iso(Times(idxEnd, :));
    cfg_crop.DoHistory = false;
    ACT = cic_cropdataset(ACT, cfg_crop);
    % ---------------------------------------------------------------------
    % Calculate epoched metrics
    cfg_metric.Epoch = 5;
    cfg_metric.DoHistory = false;
    ACT = cic_metrics(ACT, cfg_metric);
    % ---------------------------------------------------------------------
    % Set status
    ACT.status = 'neversaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Imported new dataset from file ''%s'' (%s).\n', ACT.filename, cfg.Type);
    % ---------------------------------------------------------------------
    % Set history
    ACT = cic_history(ACT, 'cic_newdataset', cfg);
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end
end