% CIC_CROPDATASET
% Crops the dataset to specified start and end dates
%
% Usage:
%   >> ACT = cic_cropdataset(ACT, cfg);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'cfg' - [struct] configuration settings with the fields:
%           - 'Start' [char] ISO formatted start date
%           - 'End' [char] ISO formatted end date
%           - 'DoHistory' [boolean] whether to write history or not
%
% Outputs: 
%   'ACT' - [struct] standardized ACT structure

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

function ACT = cic_cropdataset(ACT, varargin)
try
    % ---------------------------------------------------------------------
    % Parse configuration settings
    cfg = struct();
    cfg.Start = ACT.xmin;
    cfg.End = ACT.xmax;
    cfg.DoHistory = true;
    if nargin > 1
        cfg = parseconfig(cfg, varargin{1});
    end
    % ---------------------------------------------------------------------
    % Crop raw data
    for i = 1:length(ACT.data)
        ACT.data(i) = cropmetrics(ACT.data(i), cfg);
    end
    ACT.xmin = cfg.Start;
    ACT.xmax = cfg.End;
    % ---------------------------------------------------------------------
    % If the currenst status is saved, then change it to unsaved
    if strcmpi(ACT.status, 'saved')
        ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    end
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Cropped dataset to ''%s'' - ''%s''.\n', iso2human(cfg.Start), iso2human(cfg.End));
    % ---------------------------------------------------------------------
    % Set history
    if cfg.DoHistory
        ACT = cic_history(ACT, 'cic_cropdataset', cfg);
    end
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end

    
end