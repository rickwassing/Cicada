% CIC_LOADDATASET
% Loads an existing 'ACT' dataset from a MAT file.
%
% Usage:
%   >> ACT = cic_loaddataset([], cfg);
%
% Inputs:
%   'cfg' - [struct] configuration settings with the fields:
%           - 'FullFilePath' [char] full path to MAT file
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

function ACT = cic_loaddataset(~, cfg)
try
    % ---------------------------------------------------------------------
    % Replace backslashes in the filepath
    cfg.FullFilePath = strrep(cfg.FullFilePath, filesep, '/');
    % -------------------------------------------------------------------------
    load(cfg.FullFilePath, 'ACT')
    % -------------------------------------------------------------------------
    % Extract filename and path from config and set status
    [ACT.filepath, ACT.filename] = fileparts(cfg.FullFilePath);
    % ---------------------------------------------------------------------
    % Set status
    ACT.status = 'saved'; % 'saved', 'unsaved', 'neversaved', 'error'
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Loaded dataset from file ''%s.mat''.\n', ACT.filename);
    % ---------------------------------------------------------------------
    % Set history
    ACT = cic_history(ACT, 'cic_loaddataset', cfg);
catch ME
    % -------------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT = cic_emptydataset(cfg.FullFilePath);
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end
end