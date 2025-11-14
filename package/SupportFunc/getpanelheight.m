% GETPANELHEIGHT
% Dynamically calculate uipanel height based on title font and content.
%
% Usage:
%   panelHeight = getpanelheight(fontName, fontSize, padding, numRows, rowHeight, rowSpacing)
%
% Inputs:
%   fontName - Font name for title 
%                   ('georgia', 'times new roman', 'calibri', 'helvetica', 'arial')
%   fontSize - Font size in points (8-18)
%   padding - padding of the gridlayout
%   numRows - Number of rows in gridlayout
%   rowHeight - Height of each row in pixels
%   rowSpacing - Spacing between each row in pixels
%
% Output:
%   panelHeight   - Required panel height in pixels

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-14, Rick Wassing

% Cicada (C) 2025 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function panelHeight = getpanelheight(fontName, fontSize, padding, numRows, rowHeight, rowSpacing)
% Validate inputs
validFonts = {'georgia', 'times new roman', 'calibri', 'helvetica', 'arial'};
if ~ismember(lower(fontName), validFonts)
    error('Invalid font name. Must be one of: %s', strjoin(validFonts, ', '));
end
if fontSize < 8 || fontSize > 18
    error('Font size must be between 8 and 18 points');
end
% Calculate title height based on font size
% Title height in pixels is approximately: fontSize * 1.3 + padding
% The 1.3 factor accounts for line height
% Additional padding accounts for title margins
heightBase = fontSize * 1.3;
% Font-specific adjustments (some fonts render slightly taller)
switch lower(fontName)
    case 'georgia'
        fontFactor = 1.05;
    case 'times new roman'
        fontFactor = 1.0;
    case 'calibri'
        fontFactor = 1.02;
    case 'helvetica'
        fontFactor = 1.0;
    case 'arial'
        fontFactor = 1.0;
    otherwise
        fontFactor = 1.0;
end
titleHeight = heightBase * fontFactor;
% Add padding for title (top and bottom)
titlePadding = 8;
% Calculate content height
contentHeight = numRows * rowHeight;
% Calculate total panel height
panelHeight = titleHeight + titlePadding + contentHeight + 2*padding; + (numRows-1)*rowSpacing;
% Round to nearest pixel
panelHeight = round(panelHeight);
end