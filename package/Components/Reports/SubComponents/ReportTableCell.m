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
    end
    
    properties (Access = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
        KeyLabelUI matlab.ui.control.Label
        ValueLabelUI matlab.ui.control.Label
        ValueInputUI matlab.ui.control.EditField
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
            % Create grid layout (2 columns: key label | value area)
            Obj.GridLayout = uigridlayout(Obj, ...
                'ColumnWidth', {120, '1x'}, ...
                'RowHeight', {30}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            
            % -------------------------------------------------------------
            % Create key label (left side - always visible)
            Obj.KeyLabelUI = uilabel(Obj.GridLayout, ...
                'Text', '', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'FontSize', 12, ...
                'FontWeight', 'bold', ...
                'FontColor', [0.173, 0.353, 0.627], ...
                'BackgroundColor', [0.973, 0.976, 0.980]);
            Obj.KeyLabelUI.Layout.Row = 1;
            Obj.KeyLabelUI.Layout.Column = 1;
            
            % -------------------------------------------------------------
            % Create value label (right side - display mode)
            Obj.ValueLabelUI = uilabel(Obj.GridLayout, ...
                'Text', '', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'FontSize', 12, ...
                'FontWeight', 'normal', ...
                'FontColor', [0.2, 0.2, 0.2], ...
                'BackgroundColor', [1, 1, 1]);
            Obj.ValueLabelUI.Layout.Row = 1;
            Obj.ValueLabelUI.Layout.Column = 2;
            
            % -------------------------------------------------------------
            % Create value input (right side - edit mode, initially hidden)
            Obj.ValueInputUI = uieditfield(Obj.GridLayout, ...
                'Value', '', ...
                'Visible', 'off', ...
                'FontSize', 12);
            Obj.ValueInputUI.Layout.Row = 1;
            Obj.ValueInputUI.Layout.Column = 2;
        end
        
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Update key label text
                Obj.KeyLabelUI.Text = ['  ' Obj.KeyLabel];
                
                % ---------------------------------------------------------
                % Update value label text
                Obj.ValueLabelUI.Text = ['  ' Obj.ValueText];
                
                % ---------------------------------------------------------
                % Apply hover styling to value area if editable
                if Obj.Editable && Obj.IsHovered
                    Obj.ValueLabelUI.BackgroundColor = [0.910, 0.957, 0.992]; % #e8f4fd
                else
                    Obj.ValueLabelUI.BackgroundColor = [1, 1, 1];
                end
                
                % ---------------------------------------------------------
                % Set cursor style for editable cells
                if Obj.Editable
                    Obj.ValueLabelUI.Tag = 'clickable';
                else
                    Obj.ValueLabelUI.Tag = '';
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
        function hInit(Obj)
            % Initialize cell - called by parent component
        end
        
        % =================================================================
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % ---------------------------------------------------------
                % Handle events from parent or app
                if ~isvalid(Obj)
                    return
                end
                
                % ---------------------------------------------------------
                % Update hover state
                if isfield(app, 'IsHovered')
                    Obj.IsHovered = app.IsHovered(Obj);
                end
                
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportTableCell.m')
            end
        end
        
        % =================================================================
        function hToggleEdit(Obj, bool)
            % Toggle between display and edit mode
            if ~Obj.Editable
                return
            end
            
            if bool
                % Switch to edit mode
                Obj.ValueInputUI.Value = Obj.ValueText;
                Obj.ValueInputUI.Visible = 'on';
                Obj.ValueLabelUI.Visible = 'off';
                focus(Obj.ValueInputUI);
            else
                % Switch to display mode
                Obj.ValueText = Obj.ValueInputUI.Value;
                Obj.ValueInputUI.Visible = 'off';
                Obj.ValueLabelUI.Visible = 'on';
                % TODO: Trigger event to save data back to ACT structure
            end
        end
    end
end
