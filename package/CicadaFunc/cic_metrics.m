% CIC_METRICS
% Calculates all types of derived metrics from raw data
%
% Usage:
%   >> ACT = cic_metrics(ACT, cfg);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'cfg' - [struct] configuration settings with the fields:
%           - 'Epoch' [double] epoch length in seconds
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

function ACT = cic_metrics(ACT, varargin)
try
    % ---------------------------------------------------------------------
    % Parse configuration settings
    cfg = struct();
    cfg.Epoch = 5;
    cfg.DoHistory = true;
    if nargin > 1
        cfg = parseconfig(cfg, varargin{1});
    end
    % ---------------------------------------------------------------------
    % Set epoch length
    ACT.epoch = cfg.Epoch;
    % ---------------------------------------------------------------------
    % Calculate metrics
    for i = 1:length(ACT.data)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Extract times and calculate window length
        Times = gettimes(ACT.data(i));
        WinLen = ceil(ACT.epoch * ACT.data(i).srate);
        switch ACT.data(i).modality
            case 'accel'
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Euclidean norm minus one
                [Y, T] = winfunc('mean', euclideannorm(ACT.data(i).y), WinLen, ...
                    'Times', Times, ...
                    'Stride', WinLen, ...
                    'NanFlag', 'omitnan', ...
                    'Endpoints', 'discard');
                [metric, idx] = defaultmetric(Y, T, 'euclidean norm', WinLen, ACT.data(i), ACT.metric);
                if idx == -1
                    ACT.metric(end+1) = metric;
                else
                    ACT.metric(idx) = metric;
                end
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Angle in the Z-axis
                tmp = nan(size(ACT.data(i).y), 'single');
                for ax = 1:3
                    tmp(:, ax) = winfunc('median', ACT.data(i).y(:, ax), WinLen, ...
                        'Times', Times, ...
                        'Stride', 1, ...
                        'NanFlag', 'omitnan', ...
                        'Endpoints', 'shrink');
                end
                tmp = atan(tmp(:, 3) ./ sqrt(tmp(:, 1).^2 + tmp(:, 2).^2)) ./ (pi/180);
                [Y, T] = winfunc('mean', tmp, WinLen, ...
                    'Times', Times, ...
                    'Stride', WinLen, ...
                    'NanFlag', 'omitnan', ...
                    'Endpoints', 'discard');
                [metric, idx] = defaultmetric(Y, T, 'angle_z', WinLen, ACT.data(i), ACT.metric);
                if idx == -1
                    ACT.metric(end+1) = metric;
                else
                    ACT.metric(idx) = metric;
                end
            case {'light', 'thermo'}
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Simple windowed-mean
                [Y, T] = winfunc('mean', ACT.data(i).y, WinLen, ...
                    'Times', Times, ...
                    'Stride', WinLen, ...
                    'NanFlag', 'omitnan', ...
                    'Endpoints', 'discard');
                [metric, idx] = defaultmetric(Y, T, ACT.data(i).label, WinLen, ACT.data(i), ACT.metric);
                if idx == -1
                    ACT.metric(end+1) = metric;
                else
                    ACT.metric(idx) = metric;
                end
        end
    end
    % ---------------------------------------------------------------------
    % Order metrics
    [~, idx] = sort(arrayfun(@(s) find(strcmpi(s.modality, ACT.info.modalities)), ACT.metric));
    ACT.metric = ACT.metric(idx);
    % Apply colormap
    ACT.metric = defaultcolormap(ACT.metric);
    % ---------------------------------------------------------------------
    % If the currenst status is saved, then change it to unsaved
    if strcmpi(ACT.status, 'saved')
        ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    end
    % ---------------------------------------------------------------------
    % Command window output
    fprintf('>> CIC: Calculated derived metrics using an epoch length of %i seconds.\n', cfg.Epoch);
    % ---------------------------------------------------------------------
    % Set history
    if cfg.DoHistory
        ACT = cic_history(ACT, 'cic_metrics', cfg);
    end
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end


end