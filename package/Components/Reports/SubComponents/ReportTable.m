% REPORTTABLE
% A table component for displaying structured data in reports

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

classdef ReportTable < CicadaComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties (Access = public)
        Title char = '';               % Section title
        TableConfig struct             % Table configuration
        Data struct                    % Data from ACT
        Style struct                   % Table styling
        CellHeight = 30;               % Height of each cell in pixels
    end
    
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        TitlePanel matlab.ui.container.Panel
        TitleLabel matlab.ui.control.Label
        TablePanel matlab.ui.container.Panel
        TableGrid matlab.ui.container.GridLayout
        Cells                          % Array of cell components
    end
    
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            Obj.Tag = 'ReportTable';
            % -------------------------------------------------------------
            % Create grid layout (2 rows: title + table)
            Obj.GridLayout = uigridlayout(Obj, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {32, '1x'}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Create title panel
            Obj.TitlePanel = uipanel(Obj.GridLayout, ...
                'BorderType', 'none', ...
                'BackgroundColor', [0.173, 0.353, 0.627]); % Primary color #2c5aa0
            Obj.TitlePanel.Layout.Row = 1;
            Obj.TitlePanel.Layout.Column = 1;
            % -------------------------------------------------------------
            % Create title label
            Obj.TitleLabel = uilabel(Obj.TitlePanel, ...
                'Text', '', ...
                'FontSize', 14, ...
                'FontWeight', 'bold', ...
                'FontColor', [1, 1, 1], ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'Position', [12, 0, 500, 32]);
            % -------------------------------------------------------------
            % Create table panel
            Obj.TablePanel = uipanel(Obj.GridLayout, ...
                'BorderType', 'none', ...
                'BackgroundColor', [1, 1, 1]);
            Obj.TablePanel.Layout.Row = 2;
            Obj.TablePanel.Layout.Column = 1;
        end
        
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                % Update title
                Obj.TitleLabel.Text = Obj.Title;
                % ---------------------------------------------------------
                % Check if we have valid config
                if isempty(Obj.TableConfig)
                    return
                end
                % ---------------------------------------------------------
                % Create table grid based on config
                Obj.hCreateKeyValueTable();
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: ReportTable ''%s'' updated in %.1g s.\n', Obj.Title, (now-Time)*24*60*60); %#ok<TNOW1>
                end
                
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ReportTable.m')
            end
        end
        
        % =================================================================
        function hCreateKeyValueTable(Obj)
            % Create a key-value layout table (label-value pairs)
            % ---------------------------------------------------------
            % Get number of rows and columns from config
            numCols = Obj.TableConfig.columns;
            numCells = length(Obj.TableConfig.cells);
            numRows = ceil(numCells / numCols);
            
            % ---------------------------------------------------------
            % Create or update table grid
            if isempty(Obj.TableGrid) || ~isvalid(Obj.TableGrid)
                Obj.TableGrid = uigridlayout(Obj.TablePanel, ...
                    'ColumnSpacing', 0, ...
                    'RowSpacing', 0, ...
                    'Padding', [0, 0, 0, 0], ...
                    'BackgroundColor', [1, 1, 1]);
            end
            
            % Set column widths (each cell is full width in its column)
            colWidths = repmat({'1x'}, 1, numCols);
            Obj.TableGrid.ColumnWidth = colWidths;
            
            % Set row heights
            rowHeights = repmat({Obj.CellHeight}, 1, numRows);
            Obj.TableGrid.RowHeight = rowHeights;
            
            % ---------------------------------------------------------
            % Create cells (each cell is now a label-value pair)
            Obj.Cells = [];
            
            for i = 1:numCells
                cellConfig = Obj.TableConfig.cells{i};
                
                % Create cell component (label-value pair)
                cell = ReportTableCell(Obj.TableGrid, 'Verbose', Obj.Verbose);
                cell.KeyLabel = cellConfig.keyLabel;
                cell.ValueText = cellConfig.text;
                cell.Field = cellConfig.field;
                cell.Editable = cellConfig.editable;
                cell.Format = cellConfig.format;
                cell.Layout.Row = cellConfig.row;
                cell.Layout.Column = cellConfig.col;
                
                % Store cell reference
                Obj.Cells(i).Obj = cell;
            end
        end
    end
    
    % *********************************************************************
    % PUBLIC METHODS
    methods (Access = public)
        % =================================================================
        function hInit(Obj)
            % Initialize table - called by parent component
        end
        
        % =================================================================
        function hUpdate(Obj, app, event)
            try
                % ---------------------------------------------------------
                % Handle events from app
                if ~isvalid(Obj)
                    return
                end
                % Update all cells
                for i = 1:length(Obj.Cells)
                    if isvalid(Obj.Cells(i).Obj)
                        Obj.Cells(i).Obj.hUpdate(app, event);
                    end
                end
                
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportTable.m')
            end
        end
        
        % =================================================================
        function hPopulateFromData(Obj, ACT)
            % Populate table cells from ACT data structure
            
            if isempty(ACT)
                return
            end
            
            for i = 1:length(Obj.Cells)
                cell = Obj.Cells(i).Obj;
                
                % Skip if no field mapping
                if isempty(cell.Field)
                    continue
                end
                
                % Get value from ACT structure
                try
                    value = Obj.hGetFieldValue(ACT, cell.Field);
                    
                    % Format value based on cell format
                    if ~isempty(value)
                        cell.Text = Obj.hFormatValue(value, cell.Format);
                    end
                catch
                    % Field doesn't exist in ACT, keep existing text
                    continue
                end
            end
        end
        
        % =================================================================
        function value = hGetFieldValue(~, ACT, fieldPath)
            % Get nested field value from ACT structure
            % e.g., 'info.dob' -> ACT.info.dob
            fields = strsplit(fieldPath, '.');
            value = ACT;
            for i = 1:length(fields)
                if isfield(value, fields{i})
                    value = value.(fields{i});
                else
                    value = '';
                    return
                end
            end
        end
        
        % =================================================================
        function formatted = hFormatValue(~, value, format)
            % Format value based on specified format
            
            if isempty(value)
                formatted = '';
                return
            end
            
            switch lower(format)
                case 'string'
                    formatted = char(value);
                    
                case 'number'
                    if isnumeric(value)
                        formatted = num2str(value);
                    else
                        formatted = char(value);
                    end
                    
                case 'date'
                    % Assume ISO date format, convert to readable format
                    try
                        if ischar(value) || isstring(value)
                            dt = datetime(value, 'InputFormat', 'yyyy-MM-dd');
                            formatted = datestr(dt, 'dd/mm/yyyy'); %#ok<DATST>
                        else
                            formatted = datestr(value, 'dd/mm/yyyy'); %#ok<DATST>
                        end
                    catch
                        formatted = char(value);
                    end
                    
                otherwise
                    formatted = char(value);
            end
        end
    end
end
