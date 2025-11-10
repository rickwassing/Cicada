% A4WIDTHPIXELS
% Return A4 width in pixels for the monitor containing the given figure.
%
% px = a4width_pixels(fig)
%
% Input:
%   fig — handle to a figure or uifigure (optional, defaults to gcf)
% Output:
%   px — number of pixels corresponding to 210 mm (A4 width)
%
% Notes:
% - Uses MATLAB’s ScreenPixelsPerInch by default (same for all screens).
% - If you have per-monitor calibration, edit the dpi_values array below.

function px = a4widthpixels(fig)

if nargin < 1, fig = gcf; end

% Get monitor positions in pixels
set(0, 'Units', 'pixels');
screens = get(0, 'MonitorPositions');

% Determine figure center position
figPos = get(fig, 'Position');
figCenter = [figPos(1) + figPos(3)/2, figPos(2) + figPos(4)/2];

% Identify which screen the figure lies on
onScreen = find( ...
    figCenter(1) >= screens(:,1) & figCenter(1) <= screens(:,1)+screens(:,3) & ...
    figCenter(2) >= screens(:,2) & figCenter(2) <= screens(:,2)+screens(:,4), ...
    1);

if isempty(onScreen)
    warning('Figure not located on any detected screen. Using primary screen.');
    onScreen = 1;
end

% --- Define or detect per-monitor DPI values ---
% Default: all screens use MATLAB's global DPI
defaultDPI = get(0,'ScreenPixelsPerInch');

% Example: if you've calibrated each monitor, list them here:
% dpi_values = [96, 110, 220]; % one per monitor (adjust as needed)
% For now, fallback to same DPI for all
dpi_values = repmat(defaultDPI, size(screens,1), 1);

% Use the correct one for the current screen
dpi = dpi_values(onScreen);

% Compute pixel width for 210 mm (A4 width)
A4_width_mm = 210;
px = round((A4_width_mm / 25.4) * dpi);

end