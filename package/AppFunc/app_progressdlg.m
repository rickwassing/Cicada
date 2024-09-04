% APP_PROGRESSDLG
% Renders a progress dialog.
%
% Usage:
%   (1) Create progress dialog using default configuration settings
%   >> app = app_progressdlg(app); 
%   (2) Create progress dialog overwriting the message
%   >> app = app_progressdlg(app, 'Message', 'Buzy doing something, please wait.');
%
% Inputs:
%   'app'      - [cicada object] handle to the Cicada app object.
%   'varargin' - name and value pair inputs
%                - 'Message' [char] message to display
%                - 'Indeterminate' [char] {'on', 'off'} toggle between 'on' to 
%                  provide an animated bar without progress information or 'off'
%                  to display the proportion completed
%                - 'Value' [float] fraction of progress made (0 - 1)
%                - 'Cancelable' [char] {'on', 'off'} 'on' displays a cancel 
%                  button in the dialog box. When 'on', check the value of the 
%                  'CancelRequested' property
%
% Outputs: 
%   'app'    - [cicada object] handle to the Cicada app object.
%   'cancel' - [boolean] indicates whether a cancel request is made
%
% See also UIPROGRESSDLG.

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

function [app, cancel] = app_progressdlg(app, varargin)
% -------------------------------------------------------------------------
cancel = false;
% -------------------------------------------------------------------------
% Get the app-handle
if isempty(app)
    app = app_gethandle();
end
if isempty(app)
    return;
end
% -------------------------------------------------------------------------
% Parse variable arguments in
Title = 'The Cicada is buzzing, please wait...';
Message = '';
Indeterminate = 'on';
Value = 0;
Cancelable = 'off';
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'value'
            Value = varargin{i+1};
        case 'message'
            Message = varargin{i+1};
        case 'indeterminate'
            Indeterminate = varargin{i+1};
        case 'cancelable'
            Cancelable = varargin{i+1};
    end
end
% -------------------------------------------------------------------------
% Render
if isempty(app.Cmps.ProgressDialog)
    app.Cmps.ProgressDialog = uiprogressdlg(app.UIFigure, ...
        'Title', Title, ...
        'Message', Message, ...
        'Indeterminate', Indeterminate, ...
        'Value', Value, ...
        'Cancelable', Cancelable);
else
    app.Cmps.ProgressDialog.Title = Title;
    app.Cmps.ProgressDialog.Message = Message;
    app.Cmps.ProgressDialog.Indeterminate = Indeterminate;
    app.Cmps.ProgressDialog.Value = Value;
    app.Cmps.ProgressDialog.Cancelable = Cancelable;
end
% -------------------------------------------------------------------------
% Check if cancel button is pressed
if app.Cmps.ProgressDialog.CancelRequested
    app.hStatus([], 'Idle');
    cancel = true;
end
% -------------------------------------------------------------------------
end