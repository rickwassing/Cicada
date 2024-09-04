% EVENTSTAB
% The container to create and edit events

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-08-22, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef EventsTab < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        SelectedSegment = [];
        SelectedEventId = '';
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        EventGroupPanel EventGroupPanel
        Buttons
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Colors = app_colors();
            Obj.Tag = 'EventsTab';
            % -------------------------------------------------------------
            Obj.Panel = uipanel(Obj, ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'Tag', 'EventsTab_Panel', ...
                'BorderType', 'none', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', Colors.bg_primary, ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'EventsTab_GridLayout', ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_primary);
            % -------------------------------------------------------------
            Obj.EventGroupPanel = EventGroupPanel(Obj.GridLayout, 'Verbose', Obj.Verbose); %#ok<PROP>
            Obj.EventGroupPanel.Layout.Row = 1;
            Obj.EventGroupPanel.Layout.Column = 1;
            app_addlisteners([], Obj.EventGroupPanel, ...
                {'eDatasetChanged', 'eDataChanged'});
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                % Do something?
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: EventsTab updated in %.1g s.\n', (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in EventsTab.m')
            end
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, ~)
            try
                % ---------------------------------------------------------
                % Do something?
                % ---------------------------------------------------------
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in EventsTab.m')
            end
        end
    end
end