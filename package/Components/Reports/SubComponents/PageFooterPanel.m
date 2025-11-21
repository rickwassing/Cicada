% PAGEFOOTERPANEL
% Footer panel displaying page number

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
% adapt, they must license the modified material under
% identical terms.

classdef PageFooterPanel < CicadaComponentContainer
    
    properties (Access = public)
        PageNum = 1;
        SmallStyle
        Components
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid matlab.ui.container.GridLayout
        FooterGrid matlab.ui.container.GridLayout
    end
    
    methods (Access = protected)
        function setup(Obj)
            
            Obj.Grid = uigridlayout(Obj);
            Obj.Grid.ColumnWidth = {'1x', '3x'};
            Obj.Grid.RowHeight = {'1x'};
            Obj.Grid.ColumnSpacing = 0;
            Obj.Grid.RowSpacing = 3;
            Obj.Grid.Padding = [0 0 0 0];
            Obj.Grid.BackgroundColor = [1 1 1];
            
            % Page number label
            Obj.Components.PageNumberLabel = uilabel(Obj.Grid);
            Obj.Components.PageNumberLabel.HorizontalAlignment = 'center';
            Obj.Components.PageNumberLabel.VerticalAlignment = 'center';
            Obj.Components.PageNumberLabel.Layout.Row = 1;
            Obj.Components.PageNumberLabel.Layout.Column = 1;
            
            % Footer info label (version, license, docs)
            Obj.Components.FooterInfoLabel = uilabel(Obj.Grid);
            Obj.Components.FooterInfoLabel.HorizontalAlignment = 'center';
            Obj.Components.FooterInfoLabel.VerticalAlignment = 'top';
            Obj.Components.FooterInfoLabel.Layout.Row = 1;
            Obj.Components.FooterInfoLabel.Layout.Column = 2;
            
        end
        
        function update(Obj)
            % ---------------------------------------------------------
            if isempty(Obj.SmallStyle)
                return
            end
            % ---------------------------------------------------------
            % Update page number
            Obj.Components.PageNumberLabel.Text = sprintf('Page %i', Obj.PageNum);
            Obj.Components.PageNumberLabel.FontSize = Obj.SmallStyle.fontSize;
            Obj.Components.PageNumberLabel.FontName = Obj.SmallStyle.fontFamily;
            Obj.Components.PageNumberLabel.FontColor = Obj.SmallStyle.fontColor;
            Obj.Components.PageNumberLabel.FontWeight = Obj.SmallStyle.fontWeight;
            Obj.Components.PageNumberLabel.FontAngle = Obj.SmallStyle.fontStyle;
            
            % Update footer info (version, license, docs)
            footerText = sprintf('Cicada %s. CC BY-NC-SA 4.0. cicada-actigraphy-suite.readthedocs.io', cic_version());
            Obj.Components.FooterInfoLabel.Text = footerText;
            Obj.Components.FooterInfoLabel.FontSize = Obj.SmallStyle.fontSize;
            Obj.Components.FooterInfoLabel.FontName = Obj.SmallStyle.fontFamily;
            Obj.Components.FooterInfoLabel.FontColor = Obj.SmallStyle.fontColor;
            Obj.Components.FooterInfoLabel.FontWeight = Obj.SmallStyle.fontWeight;
            Obj.Components.FooterInfoLabel.FontAngle = Obj.SmallStyle.fontStyle;
        end
        
    end
    
    methods (Access = public)
        % =================================================================
        function hInit(Obj, app)
            % Update styles from app state
            Obj.SmallStyle = app.Props.Settings.Report.style.small;
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
                case {'eDatasetChanged', 'eStyleChanged'}
                    % Update styles from app state
                    Obj.SmallStyle = app.Props.Settings.Report.style.small;
            end
        end
    end
end
