classdef reports_e < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        DropDown                        matlab.ui.control.DropDown
        GridLayout                      matlab.ui.container.GridLayout
        SettingsPanel                   matlab.ui.container.Panel
        SettingsGridLayout              matlab.ui.container.GridLayout
        LogoSettingsPanel               matlab.ui.container.Panel
        LogoSettingsGridLayout          matlab.ui.container.GridLayout
        LogoWidthSpinner                matlab.ui.control.Spinner
        LogowidthcmSpinnerLabel         matlab.ui.control.Label
        LogoImage                       matlab.ui.control.Image
        ChooseFileButton                matlab.ui.control.Button
        SmallSettingsPanel              matlab.ui.container.Panel
        SmallSettingsGridLayout         matlab.ui.container.GridLayout
        SmallFontSizeInput              matlab.ui.control.DropDown
        SmallFontFamilyInput            matlab.ui.control.DropDown
        ParSettingsPanel                matlab.ui.container.Panel
        ParSettingsGridLayout           matlab.ui.container.GridLayout
        ParFontSizeInput                matlab.ui.control.DropDown
        ParFontFamilyInput              matlab.ui.control.DropDown
        H1SettingsPanel                 matlab.ui.container.Panel
        H1SettingsGridLayout            matlab.ui.container.GridLayout
        H1FontSizeInput                 matlab.ui.control.DropDown
        H1FontFamilyInput               matlab.ui.control.DropDown
        TitleSettingsPanel              matlab.ui.container.Panel
        TitleSettingsGridLayout         matlab.ui.container.GridLayout
        TitleFontSizeInput              matlab.ui.control.DropDown
        TitleFontFamilyInput            matlab.ui.control.DropDown
        ReportPanel                     matlab.ui.container.Panel
        ReportGridLayout                matlab.ui.container.GridLayout
        Panel_Page1                     matlab.ui.container.Panel
        GridLayout_Page1                matlab.ui.container.GridLayout
        HeaderPanel_Page1               matlab.ui.container.Panel
        HeaderContentGridLayout_Page1   matlab.ui.container.GridLayout
        FooterPanel_Page1               matlab.ui.container.Panel
        BodyContentGridLayout_Page1_2   matlab.ui.container.GridLayout
        BodyContentPlaceholder_Page1_2  matlab.ui.control.Label
        BodyPanel_Page1                 matlab.ui.container.Panel
        BodyContentGridLayout_Page1     matlab.ui.container.GridLayout
    end


    % *********************************************************************
    % EVENTS
    events
        eStyleChanged;
        eLogoChanged;
        eContentChanged;
    end

    properties
        State;
        Props;
        Components;
        CurrentObject;
    end

    % *********************************************************************
    % METHODS
    methods
        % -----------------------------------------------------------------
        % Executes when the 'eContentChanged' event is broadcasted
        function hUpdate(app, ~, event)
            Keys = event.UserData.Payload{1}.Keys;
            Keys = strsplit(Keys, '-');
            Val = event.UserData.Payload{1}.Text;

            app.State = setnestedfield(app.State, Keys, Val);

            % Save to the setting file
            path = which('report_templates.json');
            s = rmfield(app.State, 'main');
            app_savesettings(s, 'fullfilepath', path)
        end


        % -----------------------------------------------------------------
        % Opens interface to select a file
        function [Filename, Path] = getfile(app, filter)
            dummy = figure(...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'DockControls', 'off', ...
                'WindowState', 'minimized'); % Create dummy figure
            [Filename, Path] = uigetfile(filter);
            delete(dummy);
            figure(app.UIFigure);
        end

        % -----------------------------------------------------------------
        % Opens interface to save a file
        function [Filename, Path] = putfile(app, filter)
            dummy = figure(...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'DockControls', 'off', ...
                'WindowState', 'minimized'); % Create dummy figure
            [Filename, Path] = uiputfile(filter);
            delete(dummy);
            figure(app.UIFigure);
        end

    end

    methods (Access = private)
        % -----------------------------------------------------------------
        % Initialize the font-familily dropdown menus
        function InitFontFamilyInput(~, Obj, val)
            if ~ischar(val)
                val = 'Helvetica';
            end
            switch lower(val)
                case {'georgia', 'times new roman', 'calibri', 'helvetica', 'arial'}
                    val = lower(val);
                    val(1) = upper(val(1));
                otherwise
                    val = 'Helvetica';
            end
            Obj.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            Obj.Value = val;
        end

        % -----------------------------------------------------------------
        % Initialize the font-size dropdown menus
        function InitFontSizeInput(~, Obj, val)
            val = ifelse(isnumeric(val), val, 11);
            Obj.Items = arrayfun(@(i) sprintf('%i', i), unique([8:24, val]), 'UniformOutput', false);
            Obj.Value = sprintf('%i', val);
        end

        % -----------------------------------------------------------------
        % Creates all the color picker components
        function RenderColorPicker(app, parent, color, tag)
            objname = lower(strrep(tag, '-', ''));
            app.Components.(objname) = uicolorpicker(parent, ...
                'Value', color, ...
                'Tag', tag, ...
                'BackgroundColor', [0.98, 0.98, 0.98]);
            app.Components.(objname).Layout.Row = 1;
            app.Components.(objname).Layout.Column = 3;
            app.Components.(objname).ValueChangedFcn = @(src,event) app.SettingsChanged(event);
        end

        % -----------------------------------------------------------------
        % Initializes all components of this app (calls functions above)
        function CreateCustomComponents(app)
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Create export button
            app.Components.ExportButton = ExportButton(app.SettingsGridLayout, 'ParentApp', app, 'Verbose', app.Props.Verbose);
            app.Components.ExportButton.Graphics.Layout.Row = 1;
            app.Components.ExportButton.Graphics.Layout.Column = 1;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Create the color picker components
            RenderColorPicker(app, app.TitleSettingsGridLayout, app.State.style.title.fontColor, 'title-fontColor');
            RenderColorPicker(app, app.H1SettingsGridLayout, app.State.style.h1.fontColor, 'h1-fontColor');
            RenderColorPicker(app, app.ParSettingsGridLayout, app.State.style.paragraph.fontColor, 'paragraph-fontColor');
            RenderColorPicker(app, app.SmallSettingsGridLayout, app.State.style.small.fontColor, 'small-fontColor');
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Create the components on page 1
            % Left side of the header
            app.Components.HeaderLeftPanel_Page1 = PageHeaderLeftPanel(app.HeaderContentGridLayout_Page1, ...
                'LogoSource', app.LogoImage.ImageSource, ...
                'TitleLabel', app.State.content.header.InstituteName, ...
                'TitleStyle', app.State.style.title, ...
                'AddressLabel', app.State.content.header.InstituteAddress, ...
                'AddressStyle', app.State.style.small);
            app.Components.HeaderLeftPanel_Page1.Layout.Row = 1;
            app.Components.HeaderLeftPanel_Page1.Layout.Column = 1;
            % Right side of the header
            app.Components.HeaderRightPanel_Page1 = PageHeaderRightPanel(app.HeaderContentGridLayout_Page1, ...
                'TitleLabel', app.State.content.header.ReportTitle, ...
                'TitleStyle', app.State.style.title, ...
                'SmallStyle', app.State.style.small);
            app.Components.HeaderRightPanel_Page1.Layout.Row = 1;
            app.Components.HeaderRightPanel_Page1.Layout.Column = 2;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Add event listeners for changes to the style, logo or content
            app_addlisteners(app, app.Components.HeaderLeftPanel_Page1, {'eStyleChanged', 'eLogoChanged', 'eContentChanged'});
            app_addlisteners(app, app.Components.HeaderRightPanel_Page1, {'eStyleChanged', 'eContentChanged'});
        end

        % -----------------------------------------------------------------
        % Hover functionality: get the absolute position of an element relative to the UIFigure
        function pos = GetAbsolutePosition(~, obj)
            % Get the position of the current UI element relative to its parent
            pos = obj.Position(1:2); % Take x, y (ignore width, height)
            parent = obj.Parent;
            % Recursively add the positions of parent elements until we reach the UIFigure
            while ~isa(parent, 'matlab.ui.Figure') % Stop if parent is UIFigure
                pos = pos + parent.Position(1:2); % Add parent position
                % Check if the parent is a scrollable container (like uipanel or uigridlayout)
                if isprop(parent, 'Scrollable') && strcmpi(parent.Scrollable, 'on')
                    pos = pos - parent.ScrollableViewportLocation(1:2); % Subtract the scroll offset
                end
                parent = parent.Parent; % Move up one level
            end
        end

        % -----------------------------------------------------------------
        % Function to show/hide borders of layouts and elements on the page
        function OnHover(app, ~, ~) % (app, src, event)
            objs = findHoverableComponents(app);
            for i = 1:numel(objs)
                if app.IsHovered(app.UIFigure.CurrentPoint, objs(i))
                    objs(i).IsHovered = true;
                    % objs(i).BorderColor = [0.64, 0.81, 0.73];
                else
                    objs(i).IsHovered = false;
                    % objs(i).BorderColor = [1, 1, 1];
                end
            end
        end

        % -----------------------------------------------------------------
        % Helper function to check if a point is inside an object
        function inside = IsHovered(app, point, obj)
            pos = app.GetAbsolutePosition(obj);
            inside = (point(1) > pos(1)) && (point(1) < (pos(1) + obj.Position(3))) && (point(2) > pos(2)) && (point(2) < (pos(2) + obj.Position(4)));
        end

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, ACT, cfg)
            % Set position
            app = app_setposition(app);
            % Load the templates
            try
                app.State = jsondecode(fileread('report_templates.json'));
            catch ME
                app.State = defaultreportstate();
                path = which('cmap_batlow_cat.mat');
                path = strrep(path, 'cmap_batlow_cat.mat', 'report_templates.json');
                app_savesettings(app.State, 'fullfilepath', path)
            end
            app.State.main = app_loadsettings();
            % Set verbose
            app.Props.Verbose = true;

            % Set the window mouse motion function
            app.UIFigure.WindowButtonMotionFcn = @(src, event) app.OnHover(src, event);

            % Initialize the settings panels
            app.InitFontSizeInput(app.TitleFontSizeInput, app.State.style.title.fontSize);
            app.InitFontSizeInput(app.H1FontSizeInput, app.State.style.h1.fontSize);
            app.InitFontSizeInput(app.ParFontSizeInput, app.State.style.paragraph.fontSize);
            app.InitFontSizeInput(app.SmallFontSizeInput, app.State.style.small.fontSize);

            app.InitFontFamilyInput(app.TitleFontFamilyInput, app.State.style.title.fontFamily);
            app.InitFontFamilyInput(app.H1FontFamilyInput, app.State.style.h1.fontFamily);
            app.InitFontFamilyInput(app.ParFontFamilyInput, app.State.style.paragraph.fontFamily);
            app.InitFontFamilyInput(app.SmallFontFamilyInput, app.State.style.small.fontFamily);

            % Initialize the logo
            resourcesPath = fileparts(which('report_templates.json'));
            resourcesLogo = dir(fullfile(resourcesPath, sprintf('report_logo_%s*', app.State.main.App.Id)));
            if ~isempty(resourcesLogo)
                app.LogoImage.ImageSource = fullfile(resourcesLogo(1).folder, resourcesLogo(1).name);
            end
            app.LogoWidthSpinner.Value = app.State.style.logo.width;

            % Create components
            app.CreateCustomComponents();

            % Set the size of the GridLayout
            app.ReportGridLayout.ColumnWidth = {'1x', a4widthpixels(app.UIFigure), '1x'};

            % Add event listener to the main app
            app_addlisteners(app, app, {'eContentChanged'}, 'Tag', 'Cicada_Report');

        end

        % Button pushed function: ChooseFileButton
        function ChooseFileButtonPushed(app, event)
            [Filename, Path] = app.getfile({...
                '*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff;*.gif', ...
                'Image Files (*.jpg, *.jpeg, *.png, *.bmp, *.tif, *.tiff, *.gif)'});
            % If user pressed cancel, return
            if Filename == 0; return; end

            % Delete the current logo file
            destPath = fileparts(which('report_templates.json'));
            rmFile = dir(fullfile(destPath, sprintf('report_logo_%s*', app.State.main.App.Id)));
            if ~isempty(rmFile)
                for i = 1:length(rmFile)
                    delete(fullfile(rmFile(i).folder, rmFile(i).name))
                end
            end

            % Copy the file to the resources folder in the cicada app
            sourceFile = fullfile(Path, Filename);
            [~, ~, ext] = fileparts(sourceFile);
            destFile = fullfile(destPath, sprintf('report_logo_%s%s%s', app.State.main.App.Id, datenum2iso(now, 'yyyymmddTHHMMSSFFF'), ext)); %#ok<TNOW1>
            copyfile(sourceFile, destFile);

            % Set the image
            app.LogoImage.ImageSource = destFile;

            % Broadcast the event so components will update
            app_notify(app, {'eLogoChanged'}, event)

        end

        % Value changed function: H1FontFamilyInput, H1FontSizeInput, 
        % ...and 6 other components
        function SettingsChanged(app, event)
            % Extact the keys of this setting
            key = strsplit(event.Source.Tag, '-');
            val = event.Source.Value;
            % Parse the value
            switch lower(key{2})
                case 'fontsize'
                    val = str2double(val);
                case 'fontcolor'
                    val = rgb2hex(val);
            end
            % Set the value to the correct keys
            app.State.style.(key{1}).(key{2}) = val;

            % Save to the setting file
            path = which('report_templates.json');
            s = rmfield(app.State, 'main');
            app_savesettings(s, 'fullfilepath', path)

            % Broadcast the event so components will update
            app_notify(app, {'eStyleChanged'}, event)
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            if isempty(app.UIFigure.CurrentObject)
                return
            end
            if ~isvalid(app.UIFigure.CurrentObject)
                return
            end
            if ~isempty(app.CurrentObject)
                doblur = true;
                if isprop(app.UIFigure.CurrentObject.Parent.Parent, 'Id')
                    if isprop(app.CurrentObject, 'Id')
                        if strcmpi(app.UIFigure.CurrentObject.Parent.Parent.Id, app.CurrentObject.Id)
                            doblur = false;
                        end
                    end
                end
                if doblur
                    app.CurrentObject.OnBlur(event)
                    app.CurrentObject = [];
                end
            end

            if strcmpi(app.UIFigure.CurrentObject.Tag, 'clickable')
                app.UIFigure.CurrentObject.Parent.Parent.OnClick(event);
                app.CurrentObject = app.UIFigure.CurrentObject.Parent.Parent;
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1024 768];
            app.UIFigure.Name = 'Export report';
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UIFigure.Tag = 'Cicada_Report';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {200, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];

            % Create ReportPanel
            app.ReportPanel = uipanel(app.GridLayout);
            app.ReportPanel.AutoResizeChildren = 'off';
            app.ReportPanel.BorderColor = [0.8 0.8 0.8];
            app.ReportPanel.HighlightColor = [0.8 0.8 0.8];
            app.ReportPanel.Layout.Row = 1;
            app.ReportPanel.Layout.Column = 2;

            % Create ReportGridLayout
            app.ReportGridLayout = uigridlayout(app.ReportPanel);
            app.ReportGridLayout.ColumnWidth = {'1x', 595, '1x'};
            app.ReportGridLayout.RowHeight = {842, 842, 24};
            app.ReportGridLayout.Scrollable = 'on';

            % Create Panel_Page1
            app.Panel_Page1 = uipanel(app.ReportGridLayout);
            app.Panel_Page1.BorderColor = [0.651 0.651 0.651];
            app.Panel_Page1.HighlightColor = [0.651 0.651 0.651];
            app.Panel_Page1.BorderType = 'none';
            app.Panel_Page1.BackgroundColor = [1 1 1];
            app.Panel_Page1.Layout.Row = 1;
            app.Panel_Page1.Layout.Column = 2;

            % Create GridLayout_Page1
            app.GridLayout_Page1 = uigridlayout(app.Panel_Page1);
            app.GridLayout_Page1.ColumnWidth = {'1x'};
            app.GridLayout_Page1.RowHeight = {72, '1x', 72};
            app.GridLayout_Page1.ColumnSpacing = 0;
            app.GridLayout_Page1.RowSpacing = 0;
            app.GridLayout_Page1.Padding = [36 36 36 36];
            app.GridLayout_Page1.BackgroundColor = [1 1 1];

            % Create BodyPanel_Page1
            app.BodyPanel_Page1 = uipanel(app.GridLayout_Page1);
            app.BodyPanel_Page1.BorderColor = [1 1 1];
            app.BodyPanel_Page1.Tooltip = {''};
            app.BodyPanel_Page1.HighlightColor = [1 1 1];
            app.BodyPanel_Page1.BackgroundColor = [1 1 1];
            app.BodyPanel_Page1.Layout.Row = 2;
            app.BodyPanel_Page1.Layout.Column = 1;

            % Create BodyContentGridLayout_Page1
            app.BodyContentGridLayout_Page1 = uigridlayout(app.BodyPanel_Page1);
            app.BodyContentGridLayout_Page1.ColumnWidth = {'1x'};
            app.BodyContentGridLayout_Page1.RowHeight = {'1x'};
            app.BodyContentGridLayout_Page1.Padding = [0 0 0 0];
            app.BodyContentGridLayout_Page1.BackgroundColor = [1 1 1];

            % Create FooterPanel_Page1
            app.FooterPanel_Page1 = uipanel(app.GridLayout_Page1);
            app.FooterPanel_Page1.BorderColor = [1 1 1];
            app.FooterPanel_Page1.Tooltip = {''};
            app.FooterPanel_Page1.HighlightColor = [1 1 1];
            app.FooterPanel_Page1.BackgroundColor = [1 1 1];
            app.FooterPanel_Page1.Layout.Row = 3;
            app.FooterPanel_Page1.Layout.Column = 1;

            % Create BodyContentGridLayout_Page1_2
            app.BodyContentGridLayout_Page1_2 = uigridlayout(app.FooterPanel_Page1);
            app.BodyContentGridLayout_Page1_2.ColumnWidth = {'1x'};
            app.BodyContentGridLayout_Page1_2.RowHeight = {50};
            app.BodyContentGridLayout_Page1_2.Padding = [72 36 72 4];
            app.BodyContentGridLayout_Page1_2.BackgroundColor = [1 1 1];

            % Create BodyContentPlaceholder_Page1_2
            app.BodyContentPlaceholder_Page1_2 = uilabel(app.BodyContentGridLayout_Page1_2);
            app.BodyContentPlaceholder_Page1_2.BackgroundColor = [0.9412 0.9412 0.9412];
            app.BodyContentPlaceholder_Page1_2.HorizontalAlignment = 'center';
            app.BodyContentPlaceholder_Page1_2.Layout.Row = 1;
            app.BodyContentPlaceholder_Page1_2.Layout.Column = 1;
            app.BodyContentPlaceholder_Page1_2.Text = 'Drop content here';

            % Create HeaderPanel_Page1
            app.HeaderPanel_Page1 = uipanel(app.GridLayout_Page1);
            app.HeaderPanel_Page1.BorderColor = [1 1 1];
            app.HeaderPanel_Page1.Tooltip = {''};
            app.HeaderPanel_Page1.HighlightColor = [1 1 1];
            app.HeaderPanel_Page1.BackgroundColor = [1 1 1];
            app.HeaderPanel_Page1.Layout.Row = 1;
            app.HeaderPanel_Page1.Layout.Column = 1;

            % Create HeaderContentGridLayout_Page1
            app.HeaderContentGridLayout_Page1 = uigridlayout(app.HeaderPanel_Page1);
            app.HeaderContentGridLayout_Page1.ColumnWidth = {'2x', '1x'};
            app.HeaderContentGridLayout_Page1.RowHeight = {'1x'};
            app.HeaderContentGridLayout_Page1.Padding = [0 0 0 0];
            app.HeaderContentGridLayout_Page1.BackgroundColor = [1 1 1];

            % Create SettingsPanel
            app.SettingsPanel = uipanel(app.GridLayout);
            app.SettingsPanel.BorderType = 'none';
            app.SettingsPanel.BackgroundColor = [0.6392 0.8118 0.7294];
            app.SettingsPanel.Layout.Row = 1;
            app.SettingsPanel.Layout.Column = 1;

            % Create SettingsGridLayout
            app.SettingsGridLayout = uigridlayout(app.SettingsPanel);
            app.SettingsGridLayout.ColumnWidth = {'1x'};
            app.SettingsGridLayout.RowHeight = {24, 47, 47, 47, 47, 119, '1x'};
            app.SettingsGridLayout.ColumnSpacing = 6;
            app.SettingsGridLayout.RowSpacing = 6;
            app.SettingsGridLayout.Padding = [6 6 6 6];
            app.SettingsGridLayout.BackgroundColor = [0.6392 0.8118 0.7294];

            % Create TitleSettingsPanel
            app.TitleSettingsPanel = uipanel(app.SettingsGridLayout);
            app.TitleSettingsPanel.BorderColor = [0.8 0.8 0.8];
            app.TitleSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            app.TitleSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            app.TitleSettingsPanel.Title = 'TITLES';
            app.TitleSettingsPanel.BackgroundColor = [1 1 1];
            app.TitleSettingsPanel.Layout.Row = 2;
            app.TitleSettingsPanel.Layout.Column = 1;
            app.TitleSettingsPanel.FontWeight = 'bold';
            app.TitleSettingsPanel.FontSize = 11;

            % Create TitleSettingsGridLayout
            app.TitleSettingsGridLayout = uigridlayout(app.TitleSettingsPanel);
            app.TitleSettingsGridLayout.ColumnWidth = {'1x', 50, 34};
            app.TitleSettingsGridLayout.RowHeight = {20};
            app.TitleSettingsGridLayout.ColumnSpacing = 3;
            app.TitleSettingsGridLayout.RowSpacing = 3;
            app.TitleSettingsGridLayout.Padding = [3 3 3 3];
            app.TitleSettingsGridLayout.BackgroundColor = [1 1 1];

            % Create TitleFontFamilyInput
            app.TitleFontFamilyInput = uidropdown(app.TitleSettingsGridLayout);
            app.TitleFontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            app.TitleFontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.TitleFontFamilyInput.Tag = 'title-fontFamily';
            app.TitleFontFamilyInput.FontSize = 11;
            app.TitleFontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.TitleFontFamilyInput.Layout.Row = 1;
            app.TitleFontFamilyInput.Layout.Column = 1;
            app.TitleFontFamilyInput.Value = 'Georgia';

            % Create TitleFontSizeInput
            app.TitleFontSizeInput = uidropdown(app.TitleSettingsGridLayout);
            app.TitleFontSizeInput.Items = {};
            app.TitleFontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.TitleFontSizeInput.Tag = 'title-fontSize';
            app.TitleFontSizeInput.FontSize = 11;
            app.TitleFontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.TitleFontSizeInput.Layout.Row = 1;
            app.TitleFontSizeInput.Layout.Column = 2;
            app.TitleFontSizeInput.Value = {};

            % Create H1SettingsPanel
            app.H1SettingsPanel = uipanel(app.SettingsGridLayout);
            app.H1SettingsPanel.BorderColor = [0.8 0.8 0.8];
            app.H1SettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            app.H1SettingsPanel.HighlightColor = [0.8 0.8 0.8];
            app.H1SettingsPanel.Title = 'HEADERS';
            app.H1SettingsPanel.BackgroundColor = [1 1 1];
            app.H1SettingsPanel.Layout.Row = 3;
            app.H1SettingsPanel.Layout.Column = 1;
            app.H1SettingsPanel.FontWeight = 'bold';
            app.H1SettingsPanel.FontSize = 11;

            % Create H1SettingsGridLayout
            app.H1SettingsGridLayout = uigridlayout(app.H1SettingsPanel);
            app.H1SettingsGridLayout.ColumnWidth = {'1x', 50, 34};
            app.H1SettingsGridLayout.RowHeight = {20};
            app.H1SettingsGridLayout.ColumnSpacing = 3;
            app.H1SettingsGridLayout.RowSpacing = 3;
            app.H1SettingsGridLayout.Padding = [3 3 3 3];
            app.H1SettingsGridLayout.BackgroundColor = [1 1 1];

            % Create H1FontFamilyInput
            app.H1FontFamilyInput = uidropdown(app.H1SettingsGridLayout);
            app.H1FontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            app.H1FontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.H1FontFamilyInput.Tag = 'h1-fontFamily';
            app.H1FontFamilyInput.FontSize = 11;
            app.H1FontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.H1FontFamilyInput.Layout.Row = 1;
            app.H1FontFamilyInput.Layout.Column = 1;
            app.H1FontFamilyInput.Value = 'Georgia';

            % Create H1FontSizeInput
            app.H1FontSizeInput = uidropdown(app.H1SettingsGridLayout);
            app.H1FontSizeInput.Items = {};
            app.H1FontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.H1FontSizeInput.Tag = 'h1-fontSize';
            app.H1FontSizeInput.FontSize = 11;
            app.H1FontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.H1FontSizeInput.Layout.Row = 1;
            app.H1FontSizeInput.Layout.Column = 2;
            app.H1FontSizeInput.Value = {};

            % Create ParSettingsPanel
            app.ParSettingsPanel = uipanel(app.SettingsGridLayout);
            app.ParSettingsPanel.BorderColor = [0.8 0.8 0.8];
            app.ParSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            app.ParSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            app.ParSettingsPanel.Title = 'PARAGRAPH';
            app.ParSettingsPanel.BackgroundColor = [1 1 1];
            app.ParSettingsPanel.Layout.Row = 4;
            app.ParSettingsPanel.Layout.Column = 1;
            app.ParSettingsPanel.FontWeight = 'bold';
            app.ParSettingsPanel.FontSize = 11;

            % Create ParSettingsGridLayout
            app.ParSettingsGridLayout = uigridlayout(app.ParSettingsPanel);
            app.ParSettingsGridLayout.ColumnWidth = {'1x', 50, 34};
            app.ParSettingsGridLayout.RowHeight = {20};
            app.ParSettingsGridLayout.ColumnSpacing = 3;
            app.ParSettingsGridLayout.RowSpacing = 3;
            app.ParSettingsGridLayout.Padding = [3 3 3 3];
            app.ParSettingsGridLayout.BackgroundColor = [1 1 1];

            % Create ParFontFamilyInput
            app.ParFontFamilyInput = uidropdown(app.ParSettingsGridLayout);
            app.ParFontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            app.ParFontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.ParFontFamilyInput.Tag = 'paragraph-fontFamily';
            app.ParFontFamilyInput.FontSize = 11;
            app.ParFontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.ParFontFamilyInput.Layout.Row = 1;
            app.ParFontFamilyInput.Layout.Column = 1;
            app.ParFontFamilyInput.Value = 'Helvetica';

            % Create ParFontSizeInput
            app.ParFontSizeInput = uidropdown(app.ParSettingsGridLayout);
            app.ParFontSizeInput.Items = {};
            app.ParFontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.ParFontSizeInput.Tag = 'paragraph-fontSize';
            app.ParFontSizeInput.FontSize = 11;
            app.ParFontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.ParFontSizeInput.Layout.Row = 1;
            app.ParFontSizeInput.Layout.Column = 2;
            app.ParFontSizeInput.Value = {};

            % Create SmallSettingsPanel
            app.SmallSettingsPanel = uipanel(app.SettingsGridLayout);
            app.SmallSettingsPanel.BorderColor = [0.8 0.8 0.8];
            app.SmallSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            app.SmallSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            app.SmallSettingsPanel.Title = 'SMALL';
            app.SmallSettingsPanel.BackgroundColor = [1 1 1];
            app.SmallSettingsPanel.Layout.Row = 5;
            app.SmallSettingsPanel.Layout.Column = 1;
            app.SmallSettingsPanel.FontWeight = 'bold';
            app.SmallSettingsPanel.FontSize = 11;

            % Create SmallSettingsGridLayout
            app.SmallSettingsGridLayout = uigridlayout(app.SmallSettingsPanel);
            app.SmallSettingsGridLayout.ColumnWidth = {'1x', 50, 34};
            app.SmallSettingsGridLayout.RowHeight = {20};
            app.SmallSettingsGridLayout.ColumnSpacing = 3;
            app.SmallSettingsGridLayout.RowSpacing = 3;
            app.SmallSettingsGridLayout.Padding = [3 3 3 3];
            app.SmallSettingsGridLayout.BackgroundColor = [1 1 1];

            % Create SmallFontFamilyInput
            app.SmallFontFamilyInput = uidropdown(app.SmallSettingsGridLayout);
            app.SmallFontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            app.SmallFontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.SmallFontFamilyInput.Tag = 'small-fontFamily';
            app.SmallFontFamilyInput.FontSize = 11;
            app.SmallFontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SmallFontFamilyInput.Layout.Row = 1;
            app.SmallFontFamilyInput.Layout.Column = 1;
            app.SmallFontFamilyInput.Value = 'Helvetica';

            % Create SmallFontSizeInput
            app.SmallFontSizeInput = uidropdown(app.SmallSettingsGridLayout);
            app.SmallFontSizeInput.Items = {};
            app.SmallFontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            app.SmallFontSizeInput.Tag = 'small-fontSize';
            app.SmallFontSizeInput.FontSize = 11;
            app.SmallFontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SmallFontSizeInput.Layout.Row = 1;
            app.SmallFontSizeInput.Layout.Column = 2;
            app.SmallFontSizeInput.Value = {};

            % Create LogoSettingsPanel
            app.LogoSettingsPanel = uipanel(app.SettingsGridLayout);
            app.LogoSettingsPanel.BorderColor = [0.8 0.8 0.8];
            app.LogoSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            app.LogoSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            app.LogoSettingsPanel.Title = 'LOGO';
            app.LogoSettingsPanel.BackgroundColor = [1 1 1];
            app.LogoSettingsPanel.Layout.Row = 6;
            app.LogoSettingsPanel.Layout.Column = 1;
            app.LogoSettingsPanel.FontWeight = 'bold';
            app.LogoSettingsPanel.FontSize = 11;

            % Create LogoSettingsGridLayout
            app.LogoSettingsGridLayout = uigridlayout(app.LogoSettingsPanel);
            app.LogoSettingsGridLayout.ColumnWidth = {'1x', 75};
            app.LogoSettingsGridLayout.RowHeight = {20, 20, 20, 20};
            app.LogoSettingsGridLayout.ColumnSpacing = 3;
            app.LogoSettingsGridLayout.RowSpacing = 3;
            app.LogoSettingsGridLayout.Padding = [3 3 3 3];
            app.LogoSettingsGridLayout.BackgroundColor = [1 1 1];

            % Create ChooseFileButton
            app.ChooseFileButton = uibutton(app.LogoSettingsGridLayout, 'push');
            app.ChooseFileButton.ButtonPushedFcn = createCallbackFcn(app, @ChooseFileButtonPushed, true);
            app.ChooseFileButton.BackgroundColor = [0.4196 0.4588 0.4902];
            app.ChooseFileButton.FontSize = 11;
            app.ChooseFileButton.FontWeight = 'bold';
            app.ChooseFileButton.FontColor = [1 1 1];
            app.ChooseFileButton.Layout.Row = 2;
            app.ChooseFileButton.Layout.Column = 2;
            app.ChooseFileButton.Text = 'Choose File';

            % Create LogoImage
            app.LogoImage = uiimage(app.LogoSettingsGridLayout);
            app.LogoImage.Layout.Row = [1 3];
            app.LogoImage.Layout.Column = 1;

            % Create LogowidthcmSpinnerLabel
            app.LogowidthcmSpinnerLabel = uilabel(app.LogoSettingsGridLayout);
            app.LogowidthcmSpinnerLabel.HorizontalAlignment = 'right';
            app.LogowidthcmSpinnerLabel.Layout.Row = 4;
            app.LogowidthcmSpinnerLabel.Layout.Column = 1;
            app.LogowidthcmSpinnerLabel.Text = 'Logo width (cm)';

            % Create LogoWidthSpinner
            app.LogoWidthSpinner = uispinner(app.LogoSettingsGridLayout);
            app.LogoWidthSpinner.Limits = [1 10];
            app.LogoWidthSpinner.Layout.Row = 4;
            app.LogoWidthSpinner.Layout.Column = 2;
            app.LogoWidthSpinner.Value = 3;

            % Create DropDown
            app.DropDown = uidropdown(app.UIFigure);
            app.DropDown.Items = {'200%', '150%', '125%', '100%', '75%', 'Page width', 'Whole page'};
            app.DropDown.ItemsData = {'200', '150', '125', '100', '75', '888', '999'};
            app.DropDown.FontSize = 10;
            app.DropDown.BackgroundColor = [1 1 1];
            app.DropDown.Position = [212 12 60 24];
            app.DropDown.Value = '100';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = reports_e(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end