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
        Grid matlab.ui.container.GridLayout
    end
    
    methods (Access = protected)
        function setup(Obj)

            Obj.Grid = uigridlayout(Obj, [2 2]);
            Obj.Grid.ColumnWidth = {72, '1x'}; % 72 pixels per inch
            Obj.Grid.RowHeight = {24, '1x'};
            Obj.Grid.ColumnSpacing = 6;
            Obj.Grid.RowSpacing = 0;
            Obj.Grid.Padding = [0 0 0 0];
            Obj.Grid.BackgroundColor = [1 1 1];

            Obj.Components.LogoImage = uiimage(Obj.Grid);
            Obj.Components.LogoImage.HorizontalAlignment = 'left';
            Obj.Components.LogoImage.Layout.Row = [1 2];
            Obj.Components.LogoImage.Layout.Column = 1;

            Obj.Components.InstituteNameLabel = InlineEditField(Obj.Grid, ...
                'Keys', 'content-header-InstituteName', ...
                'Event', 'eContentChanged');
            Obj.Components.InstituteNameLabel.Layout.Row = 1;
            Obj.Components.InstituteNameLabel.Layout.Column = 2;

            Obj.Components.InstituteAddressLabel = InlineEditField(Obj.Grid, ...
                'Keys', 'content-header-InstituteAddress', ...
                'Event', 'eContentChanged');
            Obj.Components.InstituteAddressLabel.Layout.Row = 2;
            Obj.Components.InstituteAddressLabel.Layout.Column = 2;

        end
        
        function update(Obj)
            % ---------------------------------------------------------
            if isempty(Obj.TitleLabel) || isempty(Obj.TitleStyle) || isempty(Obj.AddressStyle)
                return
            end
            % ---------------------------------------------------------
            Obj.Components.InstituteNameLabel.Text = Obj.TitleLabel;
            Obj.Components.InstituteNameLabel.Style = Obj.TitleStyle;
            Obj.Components.InstituteAddressLabel.Text = Obj.AddressLabel;
            Obj.Components.InstituteAddressLabel.Style = Obj.AddressStyle;
            Obj.Components.LogoImage.ImageSource = Obj.LogoSource;
        end

    end

    methods (Access = public)
        
        function hUpdate(Obj, app, event)
            Obj.Parent
            % ---------------------------------------------------------
            % Check if app is valid
            % ---------------------------------------------------------
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
                    Obj.LogoSource = app.Props.Settings.Report.LogoSource;
                    Obj.TitleLabel = app.Props.Settings.Report.content.header.InstituteName;
                    Obj.AddressLabel = app.Props.Settings.Report.content.header.InstituteAddress;
                case {'eStyleChanged'}
                    % Update styles from app state
                    Obj.TitleStyle = app.Props.Settings.Report.style.title;
                    Obj.AddressStyle = app.Props.Settings.Report.style.small;
                case {'eLogoChanged'}
                    % Update logo from app state
                    Obj.LogoSource = app.Props.Settings.Report.LogoSource;
                case {'eContentChanged'}
                    % Update content from app state
                    Obj.TitleLabel = app.Props.Settings.Report.content.header.InstituteName;
                    Obj.AddressLabel = app.Props.Settings.Report.content.header.InstituteAddress;
            end
        end
    end
end
