% MAINTABGROUP
% The main tab group to show epoched data, summary statistics, sleep
% statistics, and custom-event statistics.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-03-17, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef MainTabGroup < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        TabTitles = {'Data'};
        IsVisible;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Placeholder Placeholder;
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
            Obj.Tag = 'MainTabGroup';
            Obj.TabGroup = uitabgroup(Obj, ...
                'Tag', 'MainTabGroup_TabGroup', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.Placeholder = Placeholder(Obj, ...
                'ImageSrc', 'no-data.png', ...
                'Header', 'Nothing to see here.', ...
                'SubHeader', {'Please import a new dataset', 'or load an existing one.'}, ...
                'Size', 220, ...
                'Units', 'normalized', ...
                'BackgroundColor', Colors.bg_primary, ...
                'Position', [0, 0, 1, 1]); %#ok<PROP>
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
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
                % ---------------------------------------------------------
                switch Obj.IsVisible
                    case 'on'
                        Obj.TabGroup.Visible = 'on';
                        Obj.Placeholder.Visible = 'off';
                    case 'off'
                        Obj.TabGroup.Visible = 'off';
                        Obj.Placeholder.Visible = 'on';
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: MainTabGroup updated in %.1g s.\n', (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in MainTabGroup.m')
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
                % DATA CONTAINER
                % ---------------------------------------------------------
                Obj.TabGroup.Children(i).UserData.DataTab = DataTab(Obj.TabGroup.Children(i).UserData.GridLayout, ...
                    'ActogramLength', 1, ...
                    'NumPanels', 0, ...
                    'Verbose', Obj.Verbose);
                app_addlisteners([], Obj.TabGroup.Children(i).UserData.DataTab, ...
                    {'eDatasetChanged', 'eDataChanged', 'eActogramSettingsChanged'});
            end
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % ---------------------------------------------------------
                if isempty(app.ACT)
                    % Turn off all tabs
                    Obj.IsVisible = 'off';
                else
                    % Turn on the tabs
                    Obj.IsVisible = 'on';
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in MainTabGroup.m')
            end
        end
    end
end