% SELECTION
% The selection area in DataPanels

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-03-24, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef Selection < handle
    % *********************************************************************
    % PROPERTIES
    properties
        Tag char;
        IsSelecting = false;
    end
    properties (Access = private, Transient, NonCopyable)
        Patch (1,1) matlab.graphics.primitive.Patch
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = Selection(Parent)
            % -------------------------------------------------------------
            % Create patch
            Colors = app_colors();
            Obj.Tag = 'Selection';
            ColorGradient = [...
                Colors.cic_indigo; ...
                Colors.cic_indigo; ...
                Colors.cic_pink; ...
                Colors.cic_pink ...
                ];
            Obj.Patch = patch(Parent, ...
                'Tag', 'Selection_Patch', ...
                'Faces', 1:4, ...
                'Vertices', zeros(4, 2), ...
                'FaceVertexCData', ColorGradient,...
                'FaceVertexAlphaData', [0.1; 0.1; 0.25; 0.25], ...
                'AlphaDataMapping', 'none', ...
                'EdgeColor', 'interp', ...
                'FaceColor', 'interp', ...
                'EdgeAlpha', 'interp', ...
                'FaceAlpha', 'interp', ...
                'LineStyle', 'none');
        end
        % =================================================================
        function hUpdate(Obj, app, event)
            try
                % ---------------------------------------------------------
                % If there is no data, return no patch
                if isempty(app.ACT)
                    Obj.Patch.Vertices = zeros(4, 2);
                    return
                end
                % ---------------------------------------------------------
                % Check if this panel is hovered
                try
                    DPanel = Obj.Patch.Parent.Parent.Parent.Parent;
                catch
                    % The panel has been removed
                    return
                end
                % If it is, then get the curret point
                if DPanel.IsHovered
                    cp = round(Obj.Patch.Parent.CurrentPoint(1, 1)*24*60)/(24*60);
                    if cp < iso2datenum(app.ACT.xmin)
                        cp = iso2datenum(app.ACT.xmin);
                    end
                    if cp > iso2datenum(app.ACT.xmax)
                        cp = iso2datenum(app.ACT.xmax);
                    end
                else
                    cp = [];
                end
                % ---------------------------------------------------------
                % Update the state of the app
                switch event.EventName
                    case 'eDatasetChanged'
                        % Update the app state
                        app.Props.SelectedSegment = [];
                        % Update the local state
                        Obj.IsSelecting = false;
                    case 'eMouseDown'
                        if ~Obj.IsSelecting
                            % Initialize the start of the selected segment
                            if ~isempty(cp)
                                app.Props.SelectedEventId = [];
                                app.Props.SelectedSegment = cp;
                            end
                            Obj.IsSelecting = true; % Set to true so we do not initialize again
                        end
                    case 'eMouseUp'
                        % The selection is completed, so ready the component to
                        % initialize again upon MouseDown
                        if Obj.IsSelecting
                            Obj.IsSelecting = false;
                        end
                        % Sort the selected segment and set it to the app properties
                        app.Props.SelectedSegment = sort(app.Props.SelectedSegment);
                    case 'eMouseMotion'
                        % Set the second point of the selected segment
                        if Obj.IsSelecting && ~isempty(cp)
                            app.Props.SelectedSegment(2) = cp;
                            app.Props.SelectionMade = true;
                        end
                    case 'eKeyPress'
                        % Set the second point of the selected segment
                        Key = event.UserData.Payload{end};
                        switch lower(Key)
                            case {'escape', 'backspace', 'delete'}
                                % Update the app state
                                app.Props.SelectedSegment = [];
                                % Update the local state
                                Obj.IsSelecting = false;
                        end
                end
                % Plot the patch
                if length(app.Props.SelectedSegment) == 2
                    Obj.Patch.Vertices = [...
                        app.Props.SelectedSegment(1), Obj.Patch.Parent.YLim(1); ...
                        app.Props.SelectedSegment(2), Obj.Patch.Parent.YLim(1); ...
                        app.Props.SelectedSegment(2), Obj.Patch.Parent.YLim(2); ...
                        app.Props.SelectedSegment(1), Obj.Patch.Parent.YLim(2); ...
                        ];
                elseif length(app.Props.SelectedSegment) == 1
                    Obj.Patch.Vertices = zeros(4, 2);
                elseif isempty(app.Props.SelectedSegment)
                    Obj.Patch.Vertices = zeros(4, 2);
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in Selection.m')
            end
        end
    end
end