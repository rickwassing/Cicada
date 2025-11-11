% MERGEPDFS
% Merge multiple PDF documents into a single output file using Apache PDFBox.
%
% Syntax:
%   mergepdfs(fileNames, outputFile)
%
% Description:
%   This function merges the PDF documents listed in the input cell array
%   fileNames into one single PDF document with the specified outputFile name.
%   It relies on the Apache PDFBox Java library, which must be available on
%   the MATLAB Java class path (e.g., pdfbox-app-2.x.y.jar).
%
% Example:
%   mergepdfs({'report_part1.pdf', 'report_part2.pdf'}, 'report_full.pdf')
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-11, Rick Wassing
%
% Cicada (C) 2025 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function mergepdfs(fileNames, outputFile)
if nargin < 2
    error('Usage: mergepdfs(fileNames, outputFile)')
end

if isempty(fileNames)
    warning('No input files specified. Nothing to merge.')
    return
end

% Check for PDFBox availability
if ~exist('org.apache.pdfbox.multipdf.PDFMergerUtility', 'class')
    error(['Apache PDFBox not found. Please ensure pdfbox-app-3.x.y.jar ' ...
           'is added to the Java class path using javaaddpath.']);
end

% Initialise the merger
merger = javaObject('org.apache.pdfbox.multipdf.PDFMergerUtility');

% Add all input files
for i = 1:numel(fileNames)
    if ~isfile(fileNames{i})
        error('File not found: %s', fileNames{i});
    end
    merger.addSource(fileNames{i});
end

% Set destination file
merger.setDestinationFileName(outputFile);

% Merge using main memory only
memSet = javaMethod('setupMainMemoryOnly', 'org.apache.pdfbox.io.MemoryUsageSetting');
merger.mergeDocuments(memSet);

end