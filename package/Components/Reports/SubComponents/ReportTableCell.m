% REPORTTABLECELL
% A single cell component representing a label-value pair for report tables

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-13, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ReportTableCell < CicadaComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties (Access = public)
        KeyLabel char = '';          % Label text (e.g., 'Name', 'Date of Birth')
        ValueText char = '';         % Value text to display
        Field char = '';             % ACT field path (e.g., 'info.dob')
        Editable logical = false;    % Can user edit?
        Format char = 'string';      % 'string', 'number', 'date', etc.
        IsHovered logical = false;   % Hover state
        Id char                      % Unique identifier
        CellHeight double = 20;      % Table row height
    end
    
    properties (Access = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
        KeyLabelObj matlab.ui.control.Label
        ValueLabelObj matlab.ui.control.Label
        ValueInputObj matlab.ui.control.EditField
    end
    
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            % Generate unique ID
            Obj.Id = getuuid('full');
            Obj.Tag = sprintf('ReportTableCell_%s', Obj.Id);
            % -------------------------------------------------------------
            % Get colors
            Colors = app_colors();
            % -------------------------------------------------------------
            % Create grid layout (2 columns: key label | value area)
            Obj.GridLayout = uigridlayout(Obj, ...
                'ColumnWidth', {'1x', '1x'}, ...
                'RowHeight', {Obj.CellHeight}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            
            % -------------------------------------------------------------
            % Create key label (left side - always visible)
            Obj.KeyLabelObj = uilabel(Obj.GridLayout, ...
                'Text', '', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'BackgroundColor', Colors.bg_secondary);
            Obj.KeyLabelObj.Layout.Row = 1;
            Obj.KeyLabelObj.Layout.Column = 1;
            
            % -------------------------------------------------------------
            % Create value label (right side - display mode)
            Obj.ValueLabelObj = uilabel(Obj.GridLayout, ...
                'Text', '', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'BackgroundColor', [1, 1, 1]);
            Obj.ValueLabelObj.Layout.Row = 1;
            Obj.ValueLabelObj.Layout.Column = 2;
            
            % -------------------------------------------------------------
            % Create value input (right side - edit mode, initially hidden)
            Obj.ValueInputObj = uieditfield(Obj.GridLayout, ...
                'Value', '', ...
                'Visible', 'off', ...
                'FontSize', 11);
            Obj.ValueInputObj.Layout.Row = 1;
            Obj.ValueInputObj.Layout.Column = 2;
        end
        
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Get colors
                Colors = app_colors();
                % ---------------------------------------------------------
                % Update key label text
                Obj.KeyLabelObj.Text = [' ', Obj.KeyLabel];
                % ---------------------------------------------------------
                % Update value label text
                Obj.ValueLabelObj.Text =[' ', Obj.ValueText];
                % ---------------------------------------------------------
                % Apply hover styling to value area if editable
                if Obj.Editable && Obj.IsHovered
                    Obj.ValueLabelObj.BackgroundColor = Colors.bs_primary_subtle.^0.33;
                else
                    Obj.ValueLabelObj.BackgroundColor = [1, 1, 1];
                end
                % ---------------------------------------------------------
                % Set cursor style for editable cells
                if Obj.Editable
                    Obj.ValueLabelObj.Tag = 'clickable';
                else
                    Obj.ValueLabelObj.Tag = '';
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ReportTableCell.m')
            end
        end
    end
    
    % *********************************************************************
    % PUBLIC METHODS
    methods (Access = public)
        % =================================================================
        function hInit(Obj, app)
            % Initialize table
            if nargin < 2 || isempty(app)
                app = app_gethandle();
            end
            % -------------------------------------------------------------
            % Apply styling
            Obj.hApplyStyle(app);
        end
        
        % =================================================================
        function hUpdate(Obj, app, event)
            try
                % ---------------------------------------------------------
                % Handle events from parent or app
                if ~isvalid(Obj)
                    return
                end
                % ---------------------------------------------------------
                % Handle style changes
                if strcmpi(event.EventName, 'eStyleChanged')
                    Obj.hApplyStyle(app);
                end
                % ---------------------------------------------------------
                % Update hover state
                if strcmpi(event.EventName, 'eMouseMotion')
                    Obj.IsHovered = app.IsHovered(Obj);
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportTableCell.m')
            end
        end
        % =================================================================
        function OnClick(Obj, ~)
            Obj.ValueInputObj.Value = Obj.ValueText;
            Obj.ValueInputObj.Visible = 'on';
            drawnow()
            focus(Obj.ValueLabelObj)
        end
        % =================================================================
        function OnBlur(Obj, event)
            Obj.ValueInputObj.Visible = 'off';
            Obj.ValueText = Obj.Input.Value;
            if ~isempty(Obj.Event)
                app_callback({event, Obj}, 'set_reportcontent')
                app_notify([], {Obj.Event}, {event, Obj})
            end
        end

        % =================================================================
        function hApplyStyle(Obj, app)
            % Apply styling to table title panel
            if nargin < 2 || isempty(app)
                app = app_gethandle();
            end
            
            % Apply title styling from app settings
            if isfield(app.Props, 'Settings') && ...
               isfield(app.Props.Settings, 'Report') && ...
               isfield(app.Props.Settings.Report, 'style') && ...
               isfield(app.Props.Settings.Report.style, 'h1')
                
                style = app.Props.Settings.Report.style.h1;
                % Set font family
                if isfield(style, 'fontFamily')
                    Obj.KeyLabelObj.FontName = style.fontFamily;
                end
                % Set font size
                if isfield(style, 'fontSize')
                    Obj.KeyLabelObj.FontSize = style.fontSize;
                end
                % Set font weight
                if isfield(style, 'fontWeight')
                    Obj.KeyLabelObj.FontWeight = style.fontWeight;
                end
                % Set font angle (style)
                if isfield(style, 'fontStyle')
                    if strcmpi(style.fontStyle, 'italic')
                        Obj.KeyLabelObj.FontAngle = 'italic';
                    else
                        Obj.KeyLabelObj.FontAngle = 'normal';
                    end
                end
                % Set foreground color (font color)
                if isfield(style, 'fontColor')
                    Obj.KeyLabelObj.FontColor = hex2rgb(style.fontColor);
                end
            end
        end
    end
end
