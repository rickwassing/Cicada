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
        CellHeight = 20;               % Height of each cell in pixels
    end

    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        TablePanel matlab.ui.container.Panel
        TableGrid matlab.ui.container.GridLayout
        Cells % Array of cell components
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
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [0, 0, 0, 0], ...
                'BackgroundColor', [1, 1, 1]);
            % -------------------------------------------------------------
            % Create table panel
            Obj.TablePanel = uipanel(Obj.GridLayout, ...
                'BorderType', 'none', ...
                'BackgroundColor', [1, 1, 1]);
            Obj.TablePanel.Layout.Row = 1;
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
                Obj.TablePanel.Title = Obj.Title;
                % ---------------------------------------------------------
                % Check if we have valid config
                if isempty(Obj.TableConfig)
                    return
                end
                % ---------------------------------------------------------
                % Create table grid structure only (not cells)
                Obj.hSetTableGrid();
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: ReportTable ''%s'' updated in %.1g s.\n', Obj.Title, (now-Time)*24*60*60); %#ok<TNOW1>
                end

            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ReportTable.m')
            end
        end

        % =================================================================
        function hSetTableGrid(Obj)
            % Create table grid structure (without cells)
            % -------------------------------------------------------------
            % Get number of rows and columns from config
            numCols = Obj.TableConfig.columns;
            numCells = length(Obj.TableConfig.cells);
            numRows = ceil(numCells / numCols);
            % -------------------------------------------------------------
            % Create or update table grid
            if isempty(Obj.TableGrid) || ~isvalid(Obj.TableGrid)
                Obj.TableGrid = uigridlayout(Obj.TablePanel, ...
                    'ColumnSpacing', 0, ...
                    'RowSpacing', 0, ...
                    'Padding', [0, 0, 0, 0], ...
                    'BackgroundColor', [1, 1, 1]);
            end
            % -------------------------------------------------------------
            % Set column widths (each cell is full width in its column)
            colWidths = repmat({'1x'}, 1, numCols);
            Obj.TableGrid.ColumnWidth = colWidths;
            % Set row heights
            rowHeights = repmat({Obj.CellHeight}, 1, numRows);
            Obj.TableGrid.RowHeight = rowHeights;
        end

        % =================================================================
        function hCreateCells(Obj)
            % Create cell components (called once during initialization)
            % ---------------------------------------------------------
            % Only create cells if they don't exist
            if ~isempty(Obj.Cells)
                return
            end
            % ---------------------------------------------------------
            % Get number of cells from config
            numCells = length(Obj.TableConfig.cells);
            % ---------------------------------------------------------
            % Create cells (each cell is now a label-value pair)
            Obj.Cells = [];
            for i = 1:numCells
                cellConfig = Obj.TableConfig.cells{i};
                % Create cell component (label-value pair)
                cellObj = ReportTableCell(Obj.TableGrid, 'Verbose', Obj.Verbose);
                cellObj.CellHeight = Obj.CellHeight;
                cellObj.KeyLabel = cellConfig.keyLabel;
                cellObj.ValueText = cellConfig.text;
                cellObj.Field = cellConfig.field;
                cellObj.Editable = cellConfig.editable;
                cellObj.Format = cellConfig.format;
                cellObj.Layout.Row = cellConfig.row;
                cellObj.Layout.Column = cellConfig.col;
                cellObj.hInit();
                % Add event listeners to cell
                app_addlisteners([], cellObj, {'eStyleChanged'});
                % Store cell reference
                Obj.Cells(i).Obj = cellObj;
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
            % Set the table grid
            Obj.hSetTableGrid();
            % -------------------------------------------------------------
            % Create cells (only once)
            Obj.hCreateCells();
            % -------------------------------------------------------------
            % Apply styling
            Obj.hApplyStyle(app);
        end

        % =================================================================
        function hUpdate(Obj, app, event)
            try
                % ---------------------------------------------------------
                % Handle events from app
                if ~isvalid(Obj)
                    return
                end
                % ---------------------------------------------------------
                % Handle style changes
                if strcmpi(event.EventName, 'eStyleChanged')
                    Obj.hApplyStyle(app);
                end
                % ---------------------------------------------------------
                % Handle dataset changes - populate from ACT
                if strcmpi(event.EventName, 'eDatasetChanged')
                    Obj.hPopulateFromData(app.ACT);
                end

            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportTable.m')
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

                style = app.Props.Settings.Report.style.title;
                % Set font family
                if isfield(style, 'fontFamily')
                    Obj.TablePanel.FontName = style.fontFamily;
                end
                % Set font size
                if isfield(style, 'fontSize')
                    Obj.TablePanel.FontSize = style.fontSize;
                end
                % Set font weight
                if isfield(style, 'fontWeight')
                    Obj.TablePanel.FontWeight = style.fontWeight;
                end
                % Set font angle (style)
                if isfield(style, 'fontStyle')
                    if strcmpi(style.fontStyle, 'italic')
                        Obj.TablePanel.FontAngle = 'italic';
                    else
                        Obj.TablePanel.FontAngle = 'normal';
                    end
                end
                % Set foreground color (font color)
                if isfield(style, 'fontColor')
                    Obj.TablePanel.ForegroundColor = hex2rgb(style.fontColor);
                end
            end
        end

        % =================================================================
        % Populate table cells from ACT data structure
        function hPopulateFromData(Obj, ACT)
            if isempty(ACT)
                return
            end
            % -------------------------------------------------------------
            for i = 1:length(Obj.Cells)
                cellObj = Obj.Cells(i).Obj;
                % Skip if no field mapping
                if isempty(cellObj.Field)
                    continue
                end
                % Get value from ACT structure
                try
                    value = Obj.hGetFieldValue(ACT, cellObj.Field);
                    % Format value based on cellObj format
                    if ~isempty(value)
                        cellObj.ValueText = Obj.hFormatValue(value, cellObj.Format);
                    end
                catch
                    % Field doesn't exist in ACT, keep existing text
                    continue
                end
            end
        end

        % =================================================================
        % Get nested field value from ACT structure
        % e.g., 'info.dob' -> ACT.info.dob
        function value = hGetFieldValue(Obj, ACT, fieldPath)
            if contains(fieldPath, '<')
                value = Obj.hCalculateFieldValue(ACT, fieldPath);
                return
            end
            parts = strsplit(fieldPath, '.');
            value = ACT;
            for i = 1:numel(parts)
                token = parts{i};
                % Check if this element uses indexing, e.g. "a(2)"
                idxStart = strfind(token, '(');
                if isempty(idxStart)
                    % No indexing: just a field
                    fieldName = token;
                    if ~isfield(value, fieldName)
                        value = '';
                        return;
                    end
                    value = value.(fieldName);
                else
                    % Field AND indexing
                    fieldName = token(1:idxStart-1);
                    idxStr = token(idxStart+1:end-1); % extract "2" from "(2)"
                    idx = str2double(idxStr);
                    if ~isfield(value, fieldName)
                        value = '';
                        return;
                    end
                    fieldValue = value.(fieldName);
                    % Bounds check
                    if idx < 1 || idx > numel(fieldValue)
                        value = '';
                        return;
                    end
                    value = fieldValue(idx);
                end
            end
        end

        % =================================================================
        % Calculate a field value
        function value = hCalculateFieldValue(~, ACT, fieldPath)
            switch lower(fieldPath)
                case '<duration>'
                    value = duration2str(...
                        datenum(ACT.xmax, 'yyyy-mm-ddTHH:MM:SS.FFF') - ...
                        datenum(ACT.xmin, 'yyyy-mm-ddTHH:MM:SS.FFF')); %#ok<DATNM>
            end
        end

        % =================================================================
        % Format value based on specified format
        function formatted = hFormatValue(~, value, format)

            if isempty(value)
                formatted = '';
                return
            end

            if strcmpi(format(1), '%')
                formatted = sprintf(format, value);
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
                    formatted = iso2human(value, 'Format', 'dd MMM uuuu');

                case 'datetime'
                    % Assume ISO date format, convert to readable format
                    formatted = iso2human(value, 'OmitSeconds', true);

                otherwise
                    formatted = char(value);
            end
        end
    end
end
