% CIC_IMPORTSLEEPDIARY
% Imports sleep diary data from a file using the specifications in
% cfg.settings.
%
% Usage:
%   >> ACT = cic_importsleepdiary(ACT, cfg);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'cfg' - [struct] configuration settings with the fields:
%           - 'Filepath' [char] path to tabular file
%           - 'Settings' [char] import settings (column index and formatting)
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

function ACT = cic_importsleepdiary(ACT, varargin)
try
    % ---------------------------------------------------------------------
    % Parse configuration settings
    cfg = struct();
    cfg.Filepath = '';
    cfg.Settings = struct([]);
    if nargin > 1
        cfg = parseconfig(cfg, varargin{1});
    end
    % ---------------------------------------------------------------------
    % Read raw data
    [rawdata, ME] = flexiblereadtable(cfg.Filepath);
    if ~isempty(ME)
        rethrow(ME)
    end
    [parseddata, errormessage] = parserawsleepdiarydata(rawdata, cfg.Settings);
    if ~isempty(errormessage)
        error(errormessage)
    end
    % Create rest window events
    Onset = iso2datenum(parseddata.LightsOut);
    Duration = duration2iso(iso2datenum(parseddata.LightsOn) - iso2datenum(parseddata.LightsOut));
    % ---------------------------------------------------------------------
    % CREATE NEW EVENT
    % ---------------------------------------------------------------------
    % Set the colors
    ncolors = length(unique(cellfun(@(l, t) strcat(l, t), ACT.analysis.events.label, ACT.analysis.events.type, 'UniformOutput', false)));
    color = app_colors('nth', ncolors+1);
    % ---------------------------------------------------------------------
    % Create new table row entry
    tmp = table();
    if isempty(ACT.analysis.events)
        tmp.id = (1:length(Onset))';
    else
        id = max(ACT.analysis.events.id)+1;
        tmp.id = (id:id+length(Onset)-1)';
    end
    tmp.onset = datenum2iso(Onset, 'omitmilliseconds');
    tmp.duration = Duration;
    tmp.label = repmat({'restwindow'}, length(Onset), 1);
    tmp.type = repmat({'imported'}, length(Onset), 1);
    tmp.color = repmat({color}, length(Onset), 1);
    tmp.show = true(length(Onset), 1);
    % -------------------------------------------------------------
    % Append the event
    if isempty(ACT.analysis.events)
        ACT.analysis.events = tmp;
    else
        ACT.analysis.events = [ACT.analysis.events; tmp];
    end
    % sort by onset
    [~, idx] = sort(ACT.analysis.events.onset);
    ACT.analysis.events = ACT.analysis.events(idx, :);
    % -------------------------------------------------------------
    % Store the parsed data in etcetera
    ACT.etc.import.sleepdiary = parseddata;
    % ---------------------------------------------------------------------
    % If the currenst status is saved, then change it to unsaved
    if strcmpi(ACT.status, 'saved')
        ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    end
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Imported sleep diary data from file ''%s''.\n', cfg.Filepath);
    % ---------------------------------------------------------------------
    % Set history
    ACT = cic_history(ACT, 'cic_importsleepdiary', cfg);
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end
    
end