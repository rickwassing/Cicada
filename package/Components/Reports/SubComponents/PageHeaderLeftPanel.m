% PAGEHEADERLEFTPANEL
% Left panel for the header on each page

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-09-25, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef PageHeaderLeftPanel < CicadaComponentContainer
    
    properties (Access = public)
        TitleLabel = '';
        TitleStyle
        AddressLabel = '';
        AddressStyle
        LogoSource = '';
        LogoWidth = 72*3
        Components
        DoCopy = true;
    end
    
    properties (Access = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
    end
    
    methods (Access = protected)
        function setup(Obj)

            Obj.GridLayout = uigridlayout(Obj, [2 2]);
            Obj.GridLayout.ColumnWidth = {72, '1x'}; % 72 pixels per inch
            Obj.GridLayout.RowHeight = {24, '1x'};
            Obj.GridLayout.ColumnSpacing = 6;
            Obj.GridLayout.RowSpacing = 0;
            Obj.GridLayout.Padding = [0 0 0 0];
            Obj.GridLayout.BackgroundColor = [1 1 1];

            Obj.Components.LogoImage = uiimage(Obj.GridLayout);
            Obj.Components.LogoImage.HorizontalAlignment = 'left';
            Obj.Components.LogoImage.Layout.Row = [1 2];
            Obj.Components.LogoImage.Layout.Column = 1;

            Obj.Components.InstituteNameLabel = InlineEditField(Obj.GridLayout, ...
                'Keys', 'content-header-InstituteName', ...
                'Event', 'eContentChanged');
            Obj.Components.InstituteNameLabel.Layout.Row = 1;
            Obj.Components.InstituteNameLabel.Layout.Column = 2;
            app_addlisteners([], Obj.Components.InstituteNameLabel, {'eMouseMotion'});

            Obj.Components.InstituteAddressLabel = InlineEditField(Obj.GridLayout, ...
                'Keys', 'content-header-InstituteAddress', ...
                'Event', 'eContentChanged');
            Obj.Components.InstituteAddressLabel.Layout.Row = 2;
            Obj.Components.InstituteAddressLabel.Layout.Column = 2;
            app_addlisteners([], Obj.Components.InstituteAddressLabel, {'eMouseMotion'});
        end
        
        function update(Obj)
            % ---------------------------------------------------------
            if isempty(Obj.TitleLabel) || isempty(Obj.TitleStyle) || isempty(Obj.AddressStyle)
                return
            end
            % ---------------------------------------------------------
            Obj.GridLayout.ColumnWidth = {Obj.LogoWidth, '1x'};
            Obj.Components.InstituteNameLabel.Text = Obj.TitleLabel;
            Obj.Components.InstituteNameLabel.Style = Obj.TitleStyle;
            Obj.Components.InstituteAddressLabel.Text = Obj.AddressLabel;
            Obj.Components.InstituteAddressLabel.Style = Obj.AddressStyle;
            Obj.Components.LogoImage.ImageSource = Obj.LogoSource;
        end

    end

    methods (Access = public)
        % =================================================================
        function hInit(Obj, app)
            % Set the UILabels
            Obj.TitleStyle = app.Props.Settings.Report.style.title;
            Obj.AddressStyle = app.Props.Settings.Report.style.small;
            Obj.TitleLabel = app.Props.Settings.Report.content.header.InstituteName;
            Obj.AddressLabel = app.Props.Settings.Report.content.header.InstituteAddress;
            % Set the logo source file
            resourcesPath = fileparts(which('app_settings.json'));
            resourcesLogo = dir(fullfile(resourcesPath, 'resources', sprintf('report_logo_%s*', app.Props.Settings.App.Id)));
            if ~isempty(resourcesLogo)
                Obj.LogoSource = fullfile(resourcesLogo(1).folder, resourcesLogo(1).name);
            end
            Obj.LogoWidth = app.Props.Settings.Report.style.logo.width * 72;
        end
        % =================================================================
        function hUpdate(Obj, app, event)
            % ---------------------------------------------------------
            % Check if app is valid
            % ---------------------------------------------------------
            if ~isvalid(Obj)
                return
            end
            if isempty(app)
                return
            end
            if ~isfield(app.Props, 'Settings')
                return
            end
            if ~isfield(app.Props.Settings, 'Report')
                return
            end
            % ---------------------------------------------------------
            % Handle events
            % ---------------------------------------------------------
            switch event.EventName
                case {'eDatasetChanged'}
                    Obj.TitleStyle = app.Props.Settings.Report.style.title;
                    Obj.AddressStyle = app.Props.Settings.Report.style.small;
                    Obj.TitleLabel = app.Props.Settings.Report.content.header.InstituteName;
                    Obj.AddressLabel = app.Props.Settings.Report.content.header.InstituteAddress;
                    % Set the logo source file
                    resourcesPath = fileparts(which('app_settings.json'));
                    resourcesLogo = dir(fullfile(resourcesPath, 'resources', sprintf('report_logo_%s*', app.Props.Settings.App.Id)));
                    if ~isempty(resourcesLogo)
                        Obj.LogoSource = fullfile(resourcesLogo(1).folder, resourcesLogo(1).name);
                    end
                    Obj.LogoWidth = app.Props.Settings.Report.style.logo.width * 72;

                case {'eStyleChanged'}
                    % Update styles from app state
                    Obj.GridLayout.RowHeight{1} = getpanelheight(app.Props.Settings.Report.style.title.fontFamily, app.Props.Settings.Report.style.title.fontSize, -3, 0, 0, 0);
                    Obj.TitleStyle = app.Props.Settings.Report.style.title;
                    Obj.AddressStyle = app.Props.Settings.Report.style.small;

                case {'eLogoChanged'}
                    % Set the logo source file
                    resourcesPath = fileparts(which('app_settings.json'));
                    resourcesLogo = dir(fullfile(resourcesPath, 'resources', sprintf('report_logo_%s*', app.Props.Settings.App.Id)));
                    if ~isempty(resourcesLogo)
                        Obj.LogoSource = fullfile(resourcesLogo(1).folder, resourcesLogo(1).name);
                    end
                    Obj.LogoWidth = app.Props.Settings.Report.style.logo.width * 72;

                case {'eContentChanged'}
                    % Update content from app state
                    Obj.TitleLabel = app.Props.Settings.Report.content.header.InstituteName;
                    Obj.AddressLabel = app.Props.Settings.Report.content.header.InstituteAddress;
            end
        end
    end
end
