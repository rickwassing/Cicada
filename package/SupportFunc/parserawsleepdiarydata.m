% PARSERAWSLEEPDIARYDATA
% Converts raw sleep diary data into standardized parsed table.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-11-21, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [parseddata, errormessage] = parserawsleepdiarydata(rawdata, settings)
% -------------------------------------------------------------
% Init empty table
parseddata = table();
errormessage = '';
% -------------------------------------------------------------
% If nothing to parse, return
if isempty(rawdata)
    return
end
% -------------------------------------------------------------
% Try to parse the data, and return empty table if it fails
Vars = {'Date', 'LightsOut', 'SL', 'NumAwake', 'WASO', 'FinAwake', 'LightsOn'};
try
    for i = 1:length(Vars)
        % - - - - - - - - - - - - - - - - - - - - - - - - -
        % Get the column index and the format
        idx = settings.Idx.(Vars{i});
        fmt = settings.Format.(Vars{i});
        switch Vars{i}
            case 'Date'
                if idx == 0 || idx > size(rawdata, 2)
                    parseddata = table();
                else
                    parseddata.(Vars{i}) = cellstr(datestr(datenum(rawdata{:, idx}, fmt), 'yyyy-mm-dd')); %#ok<DATST,DATNM>
                end
            case {'LightsOut', 'FinAwake', 'LightsOn'}
                if idx == 0 || idx > size(rawdata, 2)
                    parseddata.(Vars{i}) = repmat({''}, size(parseddata, 1), 1);
                else
                    % Check if the format includes the day, month and year, otherwise get it from the 'date' variable.
                    if contains(fmt, 'd') && contains(fmt, 'm') && contains(fmt, 'y')
                        parseddata.(Vars{i}) = cellstr(datestr(datenum(rawdata{:, idx}, fmt), 'yyyy-mm-ddTHH:MM')); %#ok<DATST,DATNM>
                    else
                        % Get the date from the date variable.
                        thisDate = datenum(parseddata.Date, 'yyyy-mm-dd'); %#ok<DATNM>
                        Values = mod(datenum(rawdata{:, idx}, fmt), 1); %#ok<DATNM>
                        % Change the date depending on whether is was prior to or after 15:00.
                        thisDate(Values >= 15/24) = thisDate(Values >= 15/24) - 1;
                        parseddata.(Vars{i}) = cellstr(datestr(thisDate+Values, 'yyyy-mm-ddTHH:MM')); %#ok<DATST>
                    end
                end
            case {'SL', 'NumAwake', 'WASO'}
                if idx == 0 || idx > size(rawdata, 2)
                    parseddata.(Vars{i}) = nan(size(parseddata, 1), 1);
                else
                    parseddata.(Vars{i}) = round(rawdata{:, idx});
                end
        end
    end
catch ME %#ok<NASGU>
    errormessage = sprintf('Failed to parse ''%s'' from column ''%s'' and format ''%s''. Raw data shown below.\n', Vars{i}, rawdata.Properties.VariableNames{idx}, fmt);
    parseddata = rawdata(:, idx);
end

end