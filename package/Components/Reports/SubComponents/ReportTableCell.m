% REPORTTABLECELL
% A single cell component for report tables with optional editability

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
        CellType char = 'value';     % 'label' or 'value'
        Text char = '';              % Display text
        Field char = '';             % ACT field path (e.g., 'info.dob')
        Editable logical = false;    % Can user edit?
        Format char = 'string';      % 'string', 'number', 'date', etc.
        Style struct                 % Cell styling
        IsHeader logical = false;    % Is this a header cell?
        IsHovered logical = false;   % Hover state
        Id char                      % Unique identifier
    end
    
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        Label matlab.ui.control.Label
        Input matlab.ui.control.EditField
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
            % Create panel for cell
            Obj.Panel = uipanel(Obj, ...
                'BorderType', 'line', ...
                'BorderWidth', 1, ...
                'BackgroundColor', [1, 1, 1]);
            
            % -------------------------------------------------------------
            % Create label for display
            Obj.Label = uilabel(Obj.Panel, ...
                'Text', '', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'Position', [8, 0, 100, 30]);
            
            % -------------------------------------------------------------
            % Create edit field (initially hidden)
            Obj.Input = uieditfield(Obj.Panel, ...
                'Value', '', ...
                'Visible', 'off', ...
                'Position', [8, 0, 100, 30]);
        end
        
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Update label text
                Obj.Label.Text = Obj.Text;
                
                % ---------------------------------------------------------
                % Apply styling based on cell type
                if Obj.IsHeader
                    % Header cell styling (matches mockup th elements)
                    Obj.Panel.BackgroundColor = [0.973, 0.976, 0.980]; % #f8f9fa
                    Obj.Panel.BorderColor = [0.871, 0.886, 0.902]; % #dee2e6
                    Obj.Label.FontWeight = 'bold';
                    Obj.Label.FontColor = [0.173, 0.353, 0.627]; % Primary color #2c5aa0
                    Obj.Label.FontSize = 12;
                elseif strcmpi(Obj.CellType, 'label')
                    % Label cell styling (matches mockup th elements)
                    Obj.Panel.BackgroundColor = [0.973, 0.976, 0.980]; % #f8f9fa
                    Obj.Panel.BorderColor = [0.871, 0.886, 0.902]; % #dee2e6
                    Obj.Label.FontWeight = 'bold';
                    Obj.Label.FontColor = [0.173, 0.353, 0.627]; % Primary color #2c5aa0
                    Obj.Label.FontSize = 12;
                else
                    % Value cell styling (matches mockup td elements)
                    if Obj.IsHovered && Obj.Editable
                        Obj.Panel.BackgroundColor = [0.910, 0.957, 0.992]; % #e8f4fd (hover color)
                    else
                        Obj.Panel.BackgroundColor = [1, 1, 1];
                    end
                    Obj.Panel.BorderColor = [0.871, 0.886, 0.902]; % #dee2e6
                    Obj.Label.FontWeight = 'normal';
                    Obj.Label.FontColor = [0.2, 0.2, 0.2]; % #333333
                    Obj.Label.FontSize = 12;
                end
                
                % ---------------------------------------------------------
                % Update label and input field positions to fill panel
                if ~isempty(Obj.Panel.Position)
                    panelWidth = Obj.Panel.Position(3);
                    panelHeight = Obj.Panel.Position(4);
                    Obj.Label.Position = [8, 0, panelWidth-16, panelHeight];
                    Obj.Input.Position = [8, (panelHeight-30)/2, panelWidth-16, 30];
                end
                
                % ---------------------------------------------------------
                % Set cursor style for editable cells
                if Obj.Editable && strcmpi(Obj.CellType, 'value')
                    Obj.Label.Tag = 'clickable';
                else
                    Obj.Label.Tag = '';
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
                Obj.Input.Value = Obj.Text;
                Obj.Input.Visible = 'on';
                Obj.Label.Visible = 'off';
                focus(Obj.Input);
            else
                % Switch to display mode
                Obj.Text = Obj.Input.Value;
                Obj.Input.Visible = 'off';
                Obj.Label.Visible = 'on';
                % TODO: Trigger event to save data back to ACT structure
            end
        end
    end
end
