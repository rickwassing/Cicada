% CIC_SAVEDATASET
% Saves an 'ACT' dataset to a MAT file.
%
% Usage:
%   >> ACT = cic_savedataset(ACT, cfg);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'cfg' - [struct] configuration settings with the fields:
%           - 'FullFilePath' [char] full path to MAT file
%
% Outputs: 
%   'ACT' - [struct] where the field 'status' is set to 'saved'

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

function ACT = cic_savedataset(ACT, cfg)
try
    % -------------------------------------------------------------------------
    % Replace backslashes in the filepath
    cfg.FullFilePath = strrep(cfg.FullFilePath, filesep, '/');
    % -------------------------------------------------------------------------
    % Write history
    ACT = cic_history(ACT, 'cic_savedataset', cfg);
    % -------------------------------------------------------------------------
    % Extract filename and path from config and set status
    [ACT.filepath, ACT.filename] = fileparts(cfg.FullFilePath);
    ACT.status = 'saved';
    % -------------------------------------------------------------------------
    % Save
    save([ACT.filepath, '/', ACT.filename, '.mat'], 'ACT', '-v7.3');
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Saved dataset to file ''%s.mat''.\n', ACT.filename);
catch ME
    % -------------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end
end