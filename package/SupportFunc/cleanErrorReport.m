% CLEANERRORREPORT
% Cleans and compresses MATLAB error reports by removing unnecessary
% line breaks, whitespace, and up-arrow markers. Produces a compact
% one-line string suitable for logging or API calls.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-12, Rick Wassing
%
% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function cleanStr = cleanErrorReport(raw)
    % Remove leading/trailing whitespace on each line
    lines = splitlines(strtrim(raw));

    % Remove completely empty lines
    lines = lines(~cellfun(@isempty, lines));

    % Remove lines made only of up-arrows or whitespace
    isCaret = cellfun(@(x) all(ismember(strtrim(x), '^')), lines);
    lines(isCaret) = [];

    % Collapse multiple spaces to one
    lines = regexprep(lines, '\s+', ' ');

    % Join all lines into a single sentence
    cleanStr = strjoin(lines, ' ');

    % Final trim
    cleanStr = strtrim(cleanStr);
end