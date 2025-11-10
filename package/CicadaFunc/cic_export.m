% CIC_EXPORT
% Exports epoched metrics, statistics, report or matlab code to a file.
%
% Usage:
%   >> ACT = cic_export(ACT, cfg);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'cfg' - [struct] configuration settings with the fields:
%           - 'FullFilePath' [char] full path to exported file
%           - 'Type' [char] what to export, one of the following: 'metrics'
%           'statistics', 'report', or 'code'
%
% Outputs: 
%   none

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

function ACT = cic_export(ACT, cfg)
try
    % ---------------------------------------------------------------------
    % Replace backslashes in the filepath
    cfg.FullFilePath = strrep(cfg.FullFilePath, filesep, '/');
    % ---------------------------------------------------------------------
    % Check what to export
    switch lower(cfg.type)
        case 'metrics'
            % Get metrics and data dictionary
            [metricstable, dictionary] = getmetricstable(ACT.metric);
            % Save metrics
            writetable(metricstable, cfg.FullFilePath);
            % Save data dictionary using the suffix '_dictionary'
            [fpath, fname] = fileparts(cfg.FullFilePath);
            writetable(dictionary, fullfile(fpath, [fname, '_dictionary.csv']));
        case 'statistics'
        case 'report'
        case 'code'
    end
    % ---------------------------------------------------------------------
    % Write history
    ACT = cic_history(ACT, 'cic_export', cfg);
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Exported %s to file ''%s.mat''.\n', lower(cfg.type), cfg.FullFilePath);
catch ME
    % -------------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end
end