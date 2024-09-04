% APP_CONFIRMDLG
% Renders a confirmation dialog.
%
% Usage:
%   (1) Create confirmation dialog using default configuration settings
%   >> app = app_confirmdlg(app); 
%   (2) Create confirmation dialog overwriting the message and options
%   >> app = app_confirmdlg(app, 'Message', 'hello world', 'Options', 'Go!');
%
% Inputs:
%   'app'      - [cicada object] handle to the Cicada app object.
%   'varargin' - name and value pair inputs
%                - 'Message' [char] message to display
%                - 'Title' [char] title to display
%                - 'Options' [cell] label(s) for the action button(s)
%                - 'DefaultOption' [char] default highlighted action button
%                - 'CancelOption' [char] button for cancel action
%                - 'Icon' [char] {'error' (default), 'info', 'success', 
%                  'warning', 'question'} icon to display
%
% Outputs: 
%   'app' - [cicada object] handle to the Cicada app object.
%
% See also UICONFIRM.

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

function app = app_confirmdlg(app, varargin)
% -------------------------------------------------------------------------
% Parse variable arguments in
Message = '';
Title = 'Oh no! An error. How embarrassing.';
Options = {'OK', 'Cancel'};
DefaultOption = 'OK';
CancelOption = 'Cancel';
Icon = 'error';
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'title'
            Title = varargin{i+1};
        case 'message'
            Message = varargin{i+1};
        case 'options'
            Options = varargin{i+1};
        case 'defaultoption'
            DefaultOption = varargin{i+1};
        case 'canceloption'
            CancelOption = varargin{i+1};
        case 'icon'
            Icon = varargin{i+1};
    end
end
% -------------------------------------------------------------------------
% DefaultOption and CancelOption must be within Options
if isempty(Options)
    Options = {'OK', 'Cancel'};
end
if ~any(matches(Options, DefaultOption))
    DefaultOption = Options{1};
end
if ~any(matches(Options, CancelOption))
    CancelOption = Options{end};
end
% -------------------------------------------------------------------------
% Render
app.Cmps.ConfirmDialog = uiconfirm(app.UIFigure, Message, Title, ...
    'Options', Options, ...
    'DefaultOption', DefaultOption, ...
    'CancelOption', CancelOption, ...
    'Icon', Icon, ...
    'Interpreter', 'html');

end