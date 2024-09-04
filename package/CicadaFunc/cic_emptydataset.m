% CIC_EMPTYDATASET
% Creates an empty standardized data structure 'ACT' with the fields:
% 'filename' [char] self-explanatory
% 'filepath' [char] self-explanatory
% 'version'  [char] the version of Cicada used to generate the dataset
% 'history'  [char] logs executed functions and configuration settings
% 'info'     [struct] meta data i.e., study and participant characteristics
% 'epoch'    [double] epoch length in seconds
% 'xmin'     [char] ISO date and time of recording start
% 'xmax'     [char] ISO date and time of recording end
% 'data'     [struct] raw data
% 'metric'   [struct] epoched data
% 'analysis' [struct] derived data
% 'stats'    [struct] statistics across entire recording, for each day,
%            each sleep window, and each custom event
% 'display'  [struct] visualization settings
% 'status'   [char] {'saved', 'unsaved'} status of the dataset
% 'etc'      [struct] errors, warnings, and any other meta data
%
% Usage:
%   >> ACT = cic_emptydataset(FullFilePath);
%
% Inputs:
%   'FullFilePath' - [char] full path to the MAT file
%
% Outputs:
%   'ACT' - [struct] empty standardized ACT structure
%
% See also STRUCT.

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

function ACT = cic_emptydataset(FullFilePath)
% -------------------------------------------------------------------------
ACT = struct();
% -------------------------------------------------------------------------
[~, ACT.filename] = fileparts(FullFilePath);
ACT.filepath = ''; % No initial filepath, so the user must indicate where to save the dataset
% -------------------------------------------------------------------------
ACT.version = cic_version();
ACT.history = '';
% -------------------------------------------------------------------------
ACT.info = struct();
ACT.info.institute = '';
ACT.info.study = '';
ACT.info.researcher = '';
ACT.info.participant_id = '';
ACT.info.group = '';
ACT.info.session = '';
ACT.info.condition = '';
ACT.info.dob = '';
ACT.info.sex = '';
ACT.info.height = NaN;
ACT.info.weight = NaN;
ACT.info.handedness = '';
ACT.info.time_zone = '';
ACT.info.modalities = {};
ACT.info.devices = {};
ACT.info.actogram.start = '15:00';
ACT.info.actogram.end = '15:00';
ACT.info.actogram.width = 'single';
ACT.info.actogram.length = 5; % days
% -------------------------------------------------------------------------
ACT.epoch = 5;
ACT.xmin = '';
ACT.xmax = '';
% -------------------------------------------------------------------------
ACT.data = struct(...
    'modality', '', ...
    'device', '', ...
    'label', '', ...
    'loc', '', ...
    'unit', '', ...
    'y', [], ...
    'srate', [], ...
    'pnts', [], ...
    'xmin', '', ...
    'xmax', '', ...
    'resolution', [], ...
    'ymin', [], ...
    'ymax', []);
ACT.data(1) = [];
% -------------------------------------------------------------------------
ACT.metric = struct(...
    'modality', '', ...
    'device', '', ...
    'label', '', ...
    'loc', '', ...
    'unit', '', ...
    'y', [], ...
    'srate', [], ...
    'pnts', [], ...
    'xmin', '', ...
    'xmax', '', ...
    'ymin', [], ...
    'ymax', [], ...
    'height', [], ...
    'show', [], ...
    'log', [], ...
    'color', [], ...
    'zindex', []);
ACT.metric(1) = [];
% -------------------------------------------------------------------------
ACT.analysis = struct();
ACT.analysis.settings = struct();
ACT.analysis.annotate = struct();
ACT.analysis.events = table('Size', [0, 7], ...
    'VariableTypes', {'uint16', 'double', 'double', 'cellstr', 'cellstr', 'cell', 'logical'}, ...
    'VariableNames', {'id', 'onset', 'duration', 'label', 'type', 'color', 'show'});
% -------------------------------------------------------------------------
ACT.stats = struct();
% -------------------------------------------------------------------------
ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
% -------------------------------------------------------------------------
ACT.etc = struct();
ACT.etc.errors = [];
ACT.etc.warnings = struct([]);
% ---------------------------------------------------------------------
% Command window output
fprintf('>> CIC: Created empty dataset with the filename ''%s''.\n', ACT.filename);
% ---------------------------------------------------------
end