% APP_SETPOSITION
% Sets the position of the app in the middle of the screen at 1280 by 768 
% pixels.
%
% Usage:
%   >> app = app_setposition(app);
%
% Inputs:
%   'app' - [cicada object] handle to the Cicada app object.
%
% Outputs: 
%   'app' - [cicada object] handle to the Cicada app object.
%
% See also GROOT.

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

function app = app_setposition(app)
% -------------------------------------------------------------
Screen = get(groot);
app.UIFigure.Position = round([...
    (Screen.ScreenSize(3)-1280)*0.5, ...
    (Screen.ScreenSize(4)-768)*0.5, ...
    1280, ...
    768]);
end