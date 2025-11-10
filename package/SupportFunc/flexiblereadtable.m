% FLEXIBLEREADTABLE
% Try to read the file with minimal assumptions about structure. Handles
% missing values as NaNs and ignores invalid rows only if necessary.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-11-01, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, ME] = flexiblereadtable(FilePath)
% -------------------------------------------------------------------------
% Detect import options to identify the header and data structure
opts = detectImportOptions(FilePath, ...
    'FileType', 'text', ...
    'TextType', 'char', ...
    'DatetimeType', 'text');
% -------------------------------------------------------------------------
% Set DataLines to start reading right after the detected header row
opts.DataLines = [opts.VariableNamesLine + 1, Inf];
% -------------------------------------------------------------------------
% Adjust import options to handle missing values
opts.MissingRule = 'fill'; % Missing values are retained as NaNs
opts.ImportErrorRule = 'omitrow'; % Only omit rows if they cause errors
% -------------------------------------------------------------------------
% Try reading the data table
ME = [];
try
    data = readtable(FilePath, opts);
catch ME
    data = [];
end
end