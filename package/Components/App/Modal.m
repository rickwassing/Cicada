% MODAL
% A modal for interactions whilst blocking interaction with the main app.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-01-10, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef Modal < handle
    % *********************************************************************
    % PROPERTIES
    properties
        disableBackdropClose;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        BgModalImage matlab.ui.control.Image
        Content
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = Modal(parent)
            % -------------------------------------------------------------
            Colors = app_colors();
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.BgModalImage = uiimage(parent, ...
                'ImageSource', 'bg-modal.png', ...
                'ScaleMethod', 'fill', ...
                'Position', [1, 1, 1, 1], ...
                'Visible', 'off');
        end
        % =================================================================
        function hUpdate(Obj, app, event, component, varargin) %#ok<INUSD>
            try
                % ---------------------------------------------------------
                % Parse varagin
                Obj.disableBackdropClose = false;
                for i = 1:2:length(varargin)
                    switch lower(varargin{i})
                        case 'disablebackdropclose'
                            Obj.disableBackdropClose = varargin{i+1};
                    end
                end
                % ---------------------------------------------------------
                % Set the image clicked function so clicking on the
                % background toggles the modal off
                if ~Obj.disableBackdropClose && isempty(Obj.BgModalImage.ImageClickedFcn)
                    Obj.BgModalImage.ImageClickedFcn = @(source, event) app.hModal(event, []);
                elseif Obj.disableBackdropClose
                    Obj.BgModalImage.ImageClickedFcn = [];
                end
                % ---------------------------------------------------------
                if app.Props.ToggleModal
                    % -----------------------------------------------------
                    % MODAL ON
                    % -----------------------------------------------------
                    % Set the component
                    switch component
                        case 'EventExcerpt'
                            if length(app.Props.SelectedSegment) ~= 2
                                return
                            end
                            Obj.Content = EventExcerpt(app.UIFigure, 'Verbose', app.Props.Verbose);
                            app_addlisteners(app, Obj.Content, {'eKeyPress'});
                        case 'RegisterUser'
                            Obj.Content = RegisterUser(app.UIFigure, 'Verbose', app.Props.Verbose);
                        otherwise
                            app.Props.ToggleModal = false;
                            return
                    end
                    Obj.Content.Position(1) = round((app.UIFigure.Position(3)/2) - (Obj.Content.Size(1)/2));
                    Obj.Content.Position(2) = round((app.UIFigure.Position(4)/2) - (Obj.Content.Size(2)/2));
                    Obj.Content.Position(3:4) = Obj.Content.Size;
                    % -----------------------------------------------------
                    % Set the background image
                    Obj.BgModalImage.Visible = 'on';
                    Obj.BgModalImage.Position = [1, 1, app.UIFigure.Position(3:4)] + [-10000, -10000, 20000, 20000];
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Call the update handle
                    Obj.Content.hUpdate(app);
                else
                    % -----------------------------------------------------
                    % MODAL OFF
                    % -----------------------------------------------------
                    Obj.BgModalImage.Visible = 'off';
                    delete(Obj.Content);
                    Obj.Content = [];
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in Modal.m')
            end
        end
    end
end