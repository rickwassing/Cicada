% CIC_HISTORY
% Logs executed functions and configuration settings.
%
% Usage:
%   >> ACT = cic_history(ACT, FuncName, cfg);
%
% Inputs:
%   'ACT'      - [struct] standardized ACT structure
%   'FuncName' - [char] name of the function to log
%   'cfg'      - [struct] configuration settings
%
% Outputs: 
%   'ACT' - [struct] with updated field 'history'

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

function ACT = cic_history(ACT, FuncName, cfg)
% ---------------------------------------------------------------------
if nargin < 3
    cfg = [];
end
% ---------------------------------------------------------------------
% Extract all the settings from the structure
if strcmpi(FuncName, 'cic_newdataset') || strcmpi(FuncName, 'cic_loaddataset')
    Config = 'cfg';
    Config = getFields(cfg, Config);
    Command = sprintf('ACT = %s([], cfg);', FuncName);
elseif ~isempty(cfg)
    Config = 'cfg';
    Config = getFields(cfg, Config);
    Command = sprintf('ACT = %s(ACT, cfg);', FuncName);
else
    Config = '';
    Command = sprintf('ACT = %s(ACT);', FuncName);
end
% ---------------------------------------------------------------------
% Create the code to reproduce this step
History = char(...
    '% =========================================================================', ...
    ['% ', sprintf('Call to ''%s'' (%s)', FuncName, datestr(now, 'dd-mmm-yyyy HH:MM:SS'))]);
if ~isempty(cfg)
    History = char(...
        History, ...
        '% -------------------------------------------------------------------------', ...
        '% Configure input arguments', ...
        'cfg = struct();', ...
        Config);
end
History = char(...
    History, ...
    '% -------------------------------------------------------------------------', ...
    '% Call function', ...
    Command);
% ---------------------------------------------------------------------
% Append to the file's history
if ~isfield(ACT, 'history')
    ACT.history = '';
end
ACT.history = char(ACT.history, History);

% ---------------------------------------------------------------------
% SUB FUNCTION
    function L = getFields(S, l)
        if isstruct(S)
            f = fieldnames(S);
            L = '';
            for i = 1:length(f)
                if length(S) == 1
                    tmp = [l, '.', f{i}];
                    tmp = getFields(S.(f{i}), tmp);
                    if isempty(L)
                        L = tmp;
                    else
                        L = char(L, tmp);
                    end
                else
                    for j = 1:length(S)
                        tmp = [l, '(', num2str(j),')', '.', f{i}];
                        tmp = getFields(S(j).(f{i}), tmp);
                        if isempty(L)
                            L = tmp;
                        else
                            L = char(L, tmp);
                        end
                    end
                end
            end
        else
            L = [l, ' = ', getValues(S, true)];
        end
    end
% ---------------------------------------------------------------------
% SUB FUNCTION
    function v = getValues(S, doSuppress)
        v = '';
        if iscell(S) && length(S) > 1
            v = '{';
            for i = 1:length(S)
                if size(S, 1) == 1
                    v = [v, getValues(S{i}, false), ', ']; %#ok<AGROW>
                else
                    v = [v, getValues(S{i}, false), '; ']; %#ok<AGROW>
                end
            end
            v(end-1:end) = [];
            v = [v, '}'];
        elseif isnumeric(S) && length(S) > 1
            v = '[';
            for i = 1:length(S)
                if size(S, 1) == 1
                    v = [v, getValues(S(i), false), ', ']; %#ok<AGROW>
                else
                    v = [v, getValues(S(i), false), '; ']; %#ok<AGROW>
                end
            end
            v(end-1:end) = [];
            v = [v, ']'];
        elseif isempty(S) && iscell(S)
            v = '{}';
        elseif isempty(S) && isnumeric(S)
            v = '[]';
        elseif isempty(S) && islogical(S)
            v = '[]';
        elseif isempty(S) && ischar(S)
            v = '''''';
        elseif isempty(S) && isstring(S)
            v = '''''';
        elseif ischar(S)
            v = sprintf('''%s''', S);
        elseif isnumeric(S)
            if mod(S, 1) < 10e-6
                v = sprintf('%i', S); % is integer
            else
                v = sprintf('%.8f', S); % Float
            end
        elseif islogical(S)
            if S
                v = 'true';
            else
                v = 'false';
            end
        end
        if doSuppress
            v = [v, ';'];
        end
    end
% ---------------------------------------------------------
end