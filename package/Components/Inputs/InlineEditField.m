% INLINEEDITFIELD
% A custom MATLAB component for multiline text with hover and edit functionality

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

classdef InlineEditField < CicadaComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties (Access = public)
        Keys char
        Text char
        Style struct = struct('fontFamily', 'Helvetica', 'fontSize', 11, 'fontColor', '#262626', 'fontWeight', 'normal', 'fontStyle', 'normal', 'textAlign', 'left', 'lineHeight', 1);
        IsHovered logical = false;
        ShowEditableIndicator logical = false;
        Id char
        CallbackFcn char = ''
        Event char = ''
        Disabled logical = false;
    end
    properties (Access = private, Transient, NonCopyable)
        Label
        Input
        Grid matlab.ui.container.GridLayout
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        function setup(Obj)
            
            Obj.Tag = 'editable';
            Obj.Id = getuuid('full');

            % Create the main grid layout
            Obj.Grid = uigridlayout(Obj, [1 1]);
            Obj.Grid.Padding = [0, 1, 0, 0];
            Obj.Grid.RowSpacing = 0;
            Obj.Grid.ColumnSpacing = 0;
            
            % Create the text area
            Obj.Label = uilabel(Obj.Grid);
            Obj.Label.Tag = 'clickable';
            Obj.Label.Text = '';
            Obj.Label.Layout.Row = 1;
            Obj.Label.Layout.Column = 1;
            Obj.Label.UserData.Id = Obj.Id;
            Obj.Label.VerticalAlignment = 'center';

            Obj.Input = uitextarea(Obj.Grid);
            Obj.Input.Value = '';
            Obj.Input.Visible = 'off';
            Obj.Input.Layout.Row = 1;
            Obj.Input.Layout.Column = 1;
            Obj.Input.UserData.Id = Obj.Id;

        end
        
        function update(Obj)

            if isempty(Obj.Style)
                return
            end

            Obj.Label.Text = strsplit(Obj.Text, '\\n');
            Obj.Label.FontSize = Obj.Style.fontSize;
            Obj.Label.FontName = Obj.Style.fontFamily;
            Obj.Label.FontColor = Obj.Style.fontColor;
            Obj.Label.FontWeight = Obj.Style.fontWeight;
            Obj.Label.FontAngle = Obj.Style.fontStyle;
            Obj.Label.HorizontalAlignment = Obj.Style.textAlign;

            Obj.Input.Value = strsplit(Obj.Text, '\\n');
            Obj.Input.FontSize = Obj.Style.fontSize;
            Obj.Input.FontName = Obj.Style.fontFamily;
            Obj.Input.FontColor = Obj.Style.fontColor;
            Obj.Input.FontWeight = Obj.Style.fontWeight;
            Obj.Input.FontAngle = Obj.Style.fontStyle;
            Obj.Input.HorizontalAlignment = Obj.Style.textAlign;

            clr = app_colors();
            
            % Update component visual state based on hover and editable indicator
            % When ReportTab is hovered, show border on all editable fields
            if Obj.ShowEditableIndicator && ~Obj.Disabled
                Obj.Grid.BackgroundColor = clr.bs_secondary;
                Obj.Label.BackgroundColor = clr.bs_secondary_subtle.^0.33;
            else
                Obj.Grid.BackgroundColor = [1, 1, 1];
                Obj.Label.BackgroundColor = [1, 1, 1];
            end
            
            % When individual field is hovered, also change label background
            if Obj.IsHovered
                Obj.Label.BackgroundColor = clr.bs_secondary_subtle;
            end

        end
    end
    % =====================================================================
    methods
        function OnClick(Obj, ~)
            if Obj.Disabled
                return
            end
            Obj.Input.Visible = 'on';
            drawnow()
            focus(Obj.Input)
        end
        function OnBlur(Obj, event)
            if Obj.Disabled
                return
            end
            Obj.Input.Visible = 'off';
            Obj.Text = strjoin(Obj.Input.Value, '\\n');
            if ~isempty(Obj.CallbackFcn)
                app_callback({event, Obj}, Obj.CallbackFcn, {Obj.Event})
            end
        end
        function hUpdate(Obj, app, event)
            if ~isvalid(Obj)
                return
            end
            if Obj.Disabled
                return
            end
            % Handle different events
            if strcmpi(event.EventName, 'eReportTabHovered')
                % Update the editable indicator based on report tab hover state
                Obj.ShowEditableIndicator = event.UserData.Payload{2};
            elseif strcmpi(event.EventName, 'eMouseMotion')
                % Update individual hover state
                Obj.IsHovered = app.IsHovered(Obj);
            end
        end
    end
    
end
