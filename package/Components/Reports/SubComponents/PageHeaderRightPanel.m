% PAGEHEADERRIGHTPANEL
% Right panel for the header on each page

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

classdef PageHeaderRightPanel < CicadaComponentContainer
    
    properties (Access = public)
        TitleLabel
        TitleStyle
        SmallStyle
        Components
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid matlab.ui.container.GridLayout
    end
    
    methods (Access = protected)
        function setup(Obj)

            Obj.Grid = uigridlayout(Obj, [2 2]);
            Obj.Grid.ColumnWidth = {'1x'};
            Obj.Grid.RowHeight = {24, '1x'};
            Obj.Grid.ColumnSpacing = 6;
            Obj.Grid.RowSpacing = 0;
            Obj.Grid.Padding = [0 0 0 0];
            Obj.Grid.BackgroundColor = [1 1 1];

            Obj.Components.TitleLabel = InlineEditField(Obj.Grid, ...
                'Keys', 'content-header-ReportTitle', ...
                'Event', 'eContentChanged');
            Obj.Components.TitleLabel.Layout.Row = 1;
            Obj.Components.TitleLabel.Layout.Column = 1;

            Obj.Components.DateLabel = uilabel(Obj.Grid);
            Obj.Components.DateLabel.VerticalAlignment = 'top';
            Obj.Components.DateLabel.Layout.Row = 2;
            Obj.Components.DateLabel.Layout.Column = 1;

        end
        
        function update(Obj)
            Style = Obj.TitleStyle;
            Style.textAlign = 'right';
            Obj.Components.TitleLabel.Text = Obj.TitleLabel;
            Obj.Components.TitleLabel.Style = Style;
            Obj.Components.DateLabel.Text = sprintf('Generated: %s', datenum2iso(now, 'dd mmmm yyyy, HH:MM')); %#ok<TNOW1>
            Obj.Components.DateLabel.FontSize = Obj.SmallStyle.fontSize;
            Obj.Components.DateLabel.FontName = Obj.SmallStyle.fontFamily;
            Obj.Components.DateLabel.FontColor = Obj.SmallStyle.fontColor;
            Obj.Components.DateLabel.FontWeight = Obj.SmallStyle.fontWeight;
            Obj.Components.DateLabel.FontAngle = Obj.SmallStyle.fontStyle;
            Obj.Components.DateLabel.HorizontalAlignment = 'right';
        end

    end

    methods (Access = public)
        function hUpdate(Obj, app, event)
            switch event.EventName
                case 'eStyleChanged'
                    tStyle = app.State.style.title;
                    tStyle.textAlign = 'right';
                    sStyle = app.State.style.small;
                    sStyle.textAlign = 'right';
                    Obj.TitleStyle = tStyle;
                    Obj.SmallStyle = sStyle;
                case 'eContentChanged'
                    try
                        srcId = event.UserData.Payload{1}.Id;
                        if strcmpi(Obj.Components.TitleLabel.Id, srcId)
                            Obj.TitleLabel = event.UserData.Payload{1}.Text;
                        end
                    catch
                        % fallback
                    end
            end
        end

        function newObj = deepCopy(obj, parent)
            % Create a new instance of this component in the target UIFigure
            newObj = PageHeaderRightPanel(parent);
            % Copy relevant public properties
            newObj.TitleLabel = obj.TitleLabel;
            newObj.TitleStyle = obj.TitleStyle;
            newObj.SmallStyle = obj.SmallStyle;
            % Ensure visual update
            newObj.update();
        end
    end
end