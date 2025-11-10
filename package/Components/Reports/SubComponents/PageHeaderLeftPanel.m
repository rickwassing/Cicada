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
        TitleLabel
        TitleStyle
        AddressLabel
        AddressStyle
        LogoSource
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
            Obj.Components.InstituteNameLabel.Text = Obj.TitleLabel;
            Obj.Components.InstituteNameLabel.Style = Obj.TitleStyle;
            Obj.Components.InstituteAddressLabel.Text = Obj.AddressLabel;
            Obj.Components.InstituteAddressLabel.Style = Obj.AddressStyle;
            Obj.Components.LogoImage.ImageSource = Obj.LogoSource;
        end

    end

    methods (Access = public)
        
        function hUpdate(Obj, app, event)
            switch event.EventName
                case 'eStyleChanged'
                    Obj.TitleStyle = app.State.style.title;
                    Obj.AddressStyle = app.State.style.small;
                case 'eLogoChanged'
                    Obj.LogoSource = app.LogoImage.ImageSource;
                case 'eContentChanged'
                    try
                        srcId = event.UserData.Payload{1}.Id;
                        if strcmpi(Obj.Components.InstituteNameLabel.Id, srcId)
                            Obj.TitleLabel = event.UserData.Payload{1}.Text;
                        end
                        if strcmpi(Obj.Components.InstituteAddressLabel.Id, srcId)
                            Obj.AddressLabel = event.UserData.Payload{1}.Text;
                        end
                    catch
                        % fallback
                    end
            end
        end

        function newObj = deepCopy(obj, parent)
            % Create a new instance of this component in the target UIFigure
            newObj = PageHeaderLeftPanel(parent);
            % Copy relevant public properties
            newObj.TitleLabel = obj.TitleLabel;
            newObj.TitleStyle = obj.TitleStyle;
            newObj.AddressLabel = obj.AddressLabel;
            newObj.AddressStyle = obj.AddressStyle;
            newObj.LogoSource = obj.LogoSource;
            % Ensure visual update
            newObj.update();
        end
    end
end