% SIDETABGROUP
% The side tab group to show display settings, events and annotations

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-11-03, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef SideTabGroup < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        TabTitles = {'Display', 'Events', 'Annotation'};
        IsVisible;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        TabGroup matlab.ui.container.TabGroup
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
            Obj.Tag = 'SideTabGroup';
            Obj.BackgroundColor = Colors.bg_primary;
            Obj.TabGroup = uitabgroup(Obj, ...
                'Tag', 'SideTabGroup_TabGroup', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
        end
        % =================================================================
        function update(Obj)
            try
                % -------------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % -------------------------------------------------------------
                for i = 1:length(Obj.TabTitles)
                    if i > length(Obj.TabGroup.Children)
                        Obj.RenderTab(i, Obj.TabTitles{i});
                    elseif ~isvalid(Obj.TabGroup.Children(i))
                        Obj.RenderTab(i, Obj.TabTitles{i});
                    else
                        Obj.TabGroup.Children(i).Title = Obj.TabTitles{i};
                    end
                end
                for i = length(Obj.TabGroup.Children):-1:length(Obj.TabTitles)+1
                    delete(Obj.TabGroup.Children(i));
                end
                % -------------------------------------------------------------
                switch Obj.IsVisible
                    case 'on'
                        Obj.TabGroup.Visible = 'on';
                    case 'off'
                        Obj.TabGroup.Visible = 'off';
                end
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: SideTabGroup updated in %.1g s.\n', (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in SideTabGroup.m')
            end
        end
        % =================================================================
        function RenderTab(Obj, i, Title)
            Colors = app_colors();
            Obj.TabGroup.Children(i) = uitab(Obj.TabGroup, ...
                'Title', Title, ...
                'BackgroundColor', Colors.bg_primary);
            Obj.TabGroup.Children(i).UserData.GridLayout = uigridlayout(Obj.TabGroup.Children(i), ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', 0, ...
                'BackgroundColor', Colors.bg_primary);
            % -------------------------------------------------------------
            % Here we initialize the children of the tabs
            if i == 1
                % ---------------------------------------------------------
                % DISPLAY SETTINGS
                % ---------------------------------------------------------
                Obj.TabGroup.Children(i).UserData.DisplaySettingsTab = DisplaySettingsTab(Obj.TabGroup.Children(i).UserData.GridLayout, ...
                    'Verbose', Obj.Verbose);
                app_addlisteners([], Obj.TabGroup.Children(i).UserData.DisplaySettingsTab, ...
                    {'eDatasetChanged'});
            elseif i == 2
                % ---------------------------------------------------------
                % EVENTS
                % ---------------------------------------------------------
                Obj.TabGroup.Children(i).UserData.EventsTab = EventsTab(Obj.TabGroup.Children(i).UserData.GridLayout, ...
                    'Verbose', Obj.Verbose);
            end
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, event)
            try
                % -------------------------------------------------------------
                if isempty(app.ACT)
                    % Turn off all tabs
                    Obj.IsVisible = 'off';
                else
                    % Turn on the tabs
                    Obj.IsVisible = 'on';
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in SideTabGroup.m')
            end
        end
    end
end