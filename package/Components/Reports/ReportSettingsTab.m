% REPORTSETTINGSTAB
% Shows report export settings and styling options.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-11, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ReportSettingsTab < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        State;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
        ExportButton ExportButton
        TitleSettings FontStyleSettingsPanel
        H1Settings FontStyleSettingsPanel
        ParSettings FontStyleSettingsPanel
        SmallSettings FontStyleSettingsPanel
        LogoPanel matlab.ui.container.Panel
        LogoGridLayout matlab.ui.container.GridLayout
        LogoImage matlab.ui.control.Image
        ChooseFileButton matlab.ui.control.Button
        LogoWidthLabel matlab.ui.control.Label
        LogoWidthSpinner matlab.ui.control.Spinner
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            Colors = app_colors();
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.Tag = 'ReportSettingsTab';
            Obj.BackgroundColor = Colors.bg_primary;
            Obj.GridLayout = uigridlayout(Obj, ...
                'Tag', 'ReportSettingsTab_GridLayout', ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {24, 44, 44, 44, 44, 116, '1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_primary);

            % -------------------------------------------------------------
            % Button to export the report
            Obj.ExportButton = ExportButton(Obj.GridLayout, ...
                'Text', 'EXPORT PDF', ...
                'TargetTag', 'ReportTab'); %#ok<PROP>

            % -------------------------------------------------------------
            % Title settings panel
            Obj.TitleSettings = FontStyleSettingsPanel(Obj.GridLayout);
            Obj.TitleSettings.Title = 'TITLES';
            Obj.TitleSettings.TagPrefix = 'title';
            Obj.TitleSettings.Layout.Row = 2;
            Obj.TitleSettings.Layout.Column = 1;

            % -------------------------------------------------------------
            % H1 settings panel
            Obj.H1Settings = FontStyleSettingsPanel(Obj.GridLayout);
            Obj.H1Settings.Title = 'HEADERS';
            Obj.H1Settings.TagPrefix = 'h1';
            Obj.H1Settings.Layout.Row = 3;
            Obj.H1Settings.Layout.Column = 1;

            % -------------------------------------------------------------
            % Paragraph settings panel
            Obj.ParSettings = FontStyleSettingsPanel(Obj.GridLayout);
            Obj.ParSettings.Title = 'PARAGRAPH';
            Obj.ParSettings.TagPrefix = 'paragraph';
            Obj.ParSettings.Layout.Row = 4;
            Obj.ParSettings.Layout.Column = 1;

            % -------------------------------------------------------------
            % Small settings panel
            Obj.SmallSettings = FontStyleSettingsPanel(Obj.GridLayout);
            Obj.SmallSettings.Title = 'SMALL';
            Obj.SmallSettings.TagPrefix = 'small';
            Obj.SmallSettings.Layout.Row = 5;
            Obj.SmallSettings.Layout.Column = 1;

            % -------------------------------------------------------------
            % Logo settings panel
            Obj.LogoPanel = uipanel(Obj.GridLayout, ...
                'Tag', 'ReportSettings_LogoPanel', ...
                'Title', 'LOGO', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_secondary, ...
                'HighLightColor', [0.8, 0.8, 0.8]);
            Obj.LogoPanel.Layout.Row = 6;
            Obj.LogoPanel.Layout.Column = 1;

            Obj.LogoGridLayout = uigridlayout(Obj.LogoPanel, ...
                'Tag', 'ReportSettings_LogoGridLayout', ...
                'ColumnWidth', {'1x', 75}, ...
                'RowHeight', {20, 20, 20, 20}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', Colors.bg_secondary);

            % Logo image
            Obj.LogoImage = uiimage(Obj.LogoGridLayout);
            Obj.LogoImage.Layout.Row = [1 3];
            Obj.LogoImage.Layout.Column = 1;

            % Choose file button
            Obj.ChooseFileButton = uibutton(Obj.LogoGridLayout, 'push');
            Obj.ChooseFileButton.Text = 'Choose File';
            Obj.ChooseFileButton.FontSize = 10;
            Obj.ChooseFileButton.FontWeight = 'bold';
            Obj.ChooseFileButton.BackgroundColor = Colors.bs_secondary;
            Obj.ChooseFileButton.FontColor = [1 1 1];
            Obj.ChooseFileButton.Layout.Row = 2;
            Obj.ChooseFileButton.Layout.Column = 2;
            Obj.ChooseFileButton.ButtonPushedFcn = @(~, event) Obj.chooseLogoFile(event);

            % Logo width label
            Obj.LogoWidthLabel = uilabel(Obj.LogoGridLayout);
            Obj.LogoWidthLabel.Text = 'Logo width (cm)';
            Obj.LogoWidthLabel.HorizontalAlignment = 'right';
            Obj.LogoWidthLabel.FontSize = 10;
            Obj.LogoWidthLabel.Layout.Row = 4;
            Obj.LogoWidthLabel.Layout.Column = 1;

            % Logo width spinner
            Obj.LogoWidthSpinner = uispinner(Obj.LogoGridLayout);
            Obj.LogoWidthSpinner.Limits = [1 10];
            Obj.LogoWidthSpinner.Value = 3;
            Obj.LogoWidthSpinner.FontSize = 10;
            Obj.LogoWidthSpinner.Layout.Row = 4;
            Obj.LogoWidthSpinner.Layout.Column = 2;
            Obj.LogoWidthSpinner.ValueChangedFcn = @(~, event) app_callback(event, 'set_reportstyle', {'eLogoChanged'});
            Obj.LogoWidthSpinner.Tag = 'logo-width';
        end

        % =================================================================
        function update(Obj)
            try
                % -------------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % -------------------------------------------------------------
                % Update font style panels if state is available
                if ~isempty(Obj.State)
                    % Title settings
                    if isfield(Obj.State, 'style') && isfield(Obj.State.style, 'title')
                        Obj.TitleSettings.FontFamily = Obj.State.style.title.fontFamily;
                        Obj.TitleSettings.FontSize = Obj.State.style.title.fontSize;
                        Obj.TitleSettings.FontColor = hex2rgb(Obj.State.style.title.fontColor);
                    end

                    % H1 settings
                    if isfield(Obj.State, 'style') && isfield(Obj.State.style, 'h1')
                        Obj.H1Settings.FontFamily = Obj.State.style.h1.fontFamily;
                        Obj.H1Settings.FontSize = Obj.State.style.h1.fontSize;
                        Obj.H1Settings.FontColor = hex2rgb(Obj.State.style.h1.fontColor);
                    end

                    % Paragraph settings
                    if isfield(Obj.State, 'style') && isfield(Obj.State.style, 'paragraph')
                        Obj.ParSettings.FontFamily = Obj.State.style.paragraph.fontFamily;
                        Obj.ParSettings.FontSize = Obj.State.style.paragraph.fontSize;
                        Obj.ParSettings.FontColor = hex2rgb(Obj.State.style.paragraph.fontColor);
                    end

                    % Small settings
                    if isfield(Obj.State, 'style') && isfield(Obj.State.style, 'small')
                        Obj.SmallSettings.FontFamily = Obj.State.style.small.fontFamily;
                        Obj.SmallSettings.FontSize = Obj.State.style.small.fontSize;
                        Obj.SmallSettings.FontColor = hex2rgb(Obj.State.style.small.fontColor);
                    end

                    % Logo settings
                    if isfield(Obj.State, 'style') && isfield(Obj.State.style, 'logo')
                        Obj.LogoWidthSpinner.Value = Obj.State.style.logo.width;
                    end

                    % Load logo image
                    if isfield(Obj.State, 'ImageSource')
                        Obj.LogoImage.ImageSource = Obj.State.ImageSource;
                    end
                end
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: ReportSettingsTab updated in %.1g s.\n', (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in ReportSettingsTab.m')
            end
        end
    end
    % *********************************************************************
    methods (Access = private)
        % =================================================================
        function chooseLogoFile(Obj, event)
            try
                app = app_gethandle();
                % Open file dialog
                [filename, pathname] = app.getfile({...
                    '*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff;*.gif', ...
                    'Image Files (*.jpg, *.jpeg, *.png, *.bmp, *.tif, *.tiff, *.gif)'});

                % If user pressed cancel, return
                if filename == 0; return; end

                % Delete the current logo file
                destPath = fileparts(which('app_settings.json'));
                rmFile = dir(fullfile(destPath, 'resources', 'report_logo_*'));
                if ~isempty(rmFile)
                    for i = 1:length(rmFile)
                        delete(fullfile(rmFile(i).folder, rmFile(i).name))
                    end
                end

                % Copy the file to the resources folder
                sourceFile = fullfile(pathname, filename);
                [~, ~, ext] = fileparts(sourceFile);
                destFile = fullfile(destPath, 'resources', sprintf('report_logo_%s%s', app.Props.Settings.App.Id, ext));
                copyfile(sourceFile, destFile);

                % Set the image
                Obj.State.ImageSource = destFile;

                % Broadcast the event
                app_callback(event, 'nan', {'eLogoChanged'});

            catch ME
                printerrormessage(ME, 'The error occurred during ''chooseLogoFile'' in ReportSettingsTab.m')
            end
        end
    end
    % *********************************************************************
    methods (Access = public)
        % =================================================================
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % Init the Object's state
                Obj.State = app.Props.Settings.Report;
                % Initialize the logo
                resourcesPath = fileparts(which('app_settings.json'));
                resourcesLogo = dir(fullfile(resourcesPath, 'resources', sprintf('report_logo_%s*', app.Props.Settings.App.Id)));
                if ~isempty(resourcesLogo)
                    Obj.State.ImageSource = fullfile(resourcesLogo(1).folder, resourcesLogo(1).name);
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in ReportSettingsTab.m')
            end
        end
    end
end
