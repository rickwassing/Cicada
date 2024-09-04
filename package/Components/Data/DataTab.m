% DATATAB
% The content of the tab thats displays all epoched data in 'ACT.metrics'.

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

classdef DataTab < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        ActogramWidth;
        ActogramLength;
        ActogramStart;
        ActogramEnd;
        NumPanels;
        PanelHeight;
        Pool;
        Verbose;
    end
    properties (Access = public, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        DataPanel DataPanel
    end
    events
        eDataPanelPulled; % When a new data panel is pulled, re-render its components
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
            Obj.Tag = 'DataTab';
            Obj.Units = 'normalized';
            Obj.Position = [0, 0, 1, 1];
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'DataTab_Panel', ...
                'BorderType', 'none', ...
                'BackgroundColor', Colors.bg_secondary, ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'DataTab_GridLayout', ...
                'ColumnWidth', {'1x', 0}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', 0, ...
                'Scrollable', 'on', ...
                'BackgroundColor', Colors.bg_secondary);
            Obj.Pool = DataPanelPool(Obj.GridLayout);
            Obj.Pool.Layout.Column = 2;
        end
        % =================================================================
        function update(Obj)
            try
                % ---------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % ---------------------------------------------------------
                PanelPulled = false;
                Obj.Pool.Verbose = Obj.Verbose;
                % ---------------------------------------------------------
                Obj.GridLayout.RowHeight = repmat({Obj.PanelHeight}, 1, Obj.NumPanels);
                for i = 1:Obj.NumPanels
                    DoRender = false;
                    if i > length(Obj.DataPanel)
                        DoRender = true;
                    elseif ~isvalid(Obj.DataPanel(i))
                        DoRender = true;
                    end
                    if DoRender
                        PanelPulled = true;
                        Obj.DataPanel(i) = Obj.Pool.pull(Obj.GridLayout);
                    else
                        Obj.DataPanel(i).Parent = Obj.GridLayout;
                    end
                    Obj.DataPanel(i).PanelNum = i;
                    Obj.DataPanel(i).PanelHeight = Obj.PanelHeight;
                    Obj.DataPanel(i).Verbose = Obj.Verbose;
                    Obj.DataPanel(i).Layout.Column = 1;
                    Obj.DataPanel(i).Layout.Row = i;
                end
                for i = length(Obj.DataPanel):-1:Obj.NumPanels+1
                    Obj.Pool.recycle(Obj.DataPanel(i));
                    Obj.DataPanel(i) = [];
                end
                % ---------------------------------------------------------
                if PanelPulled
                    app_notify([], {'eDataPanelPulled'}); % first argument can be empty, in which case the handle is searched using 'findall'
                end
                % ---------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DataTab updated ''%i'' panels in %.1g s.\n', Obj.NumPanels, (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DataTab.m')
            end
        end
        % =================================================================
        function cfg = config(~, ACT)
            % -------------------------------------------------------------
            cfg = struct();
            cfg.Width = ACT.info.actogram.width;
            cfg.Length = ACT.info.actogram.length;
            % -------------------------------------------------------------
            % Create date-time objects of the actogram start and end dates
            cfg.Start = iso2datetime([ACT.xmin(1:10), 'T', ACT.info.actogram.start, ':00.000']);
            cfg.End = iso2datetime([ACT.xmax(1:10), 'T', ACT.info.actogram.end, ':00.000']);
            % -------------------------------------------------------------
            % The actogram start must be before the start of the recording
            while cfg.Start > iso2datetime(ACT.xmin)
                cfg.Start = cfg.Start - days(1);
            end
            % The actogram end must be after the end of the recording
            while cfg.End < iso2datetime(ACT.xmax)
                cfg.End = cfg.End + days(1);
            end
            cfg.NumDays = days(cfg.End - cfg.Start);
            cfg.NumPanels = floor(cfg.NumDays) - ifelse(strcmpi(ACT.info.actogram.width, 'single'), 0, 1);
            % -------------------------------------------------------------
            % Convert to char
            cfg.Start = datetime2iso(cfg.Start);
            cfg.End = datetime2iso(cfg.End);
        end
    end
    % *********************************************************************
    methods (Access = public)
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % ---------------------------------------------------------
                if isempty(app.ACT)
                    % Set to default values
                    Obj.ActogramLength = 1;
                    Obj.NumPanels = 0;
                else
                    % Get number of days given actogram start and end clock,
                    % and the recording duration.
                    cfg = Obj.config(app.ACT);
                    Obj.ActogramWidth = ifelse(strcmpi(cfg.Width, 'single'), 1, 2);
                    Obj.ActogramLength = min([cfg.NumPanels, cfg.Length])+0.33;
                    Obj.ActogramStart = cfg.Start;
                    Obj.ActogramEnd = cfg.End;
                    Obj.NumPanels = cfg.NumPanels;
                    % Due to implementation differences between Matlab 2021 and
                    % 2023, the Panel height cannot be derived in the same way.
                    % First try the 2023 way and if that fails then try the
                    % 2021 way.
                    try
                        Obj.PanelHeight = Obj.GridLayout.Position(4)/Obj.ActogramLength;
                    catch
                        Obj.Units = 'pixels';
                        Obj.PanelHeight = Obj.Position(4)/Obj.ActogramLength;
                        Obj.Units = 'normalized';
                    end
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in DataTab.m')
            end
        end
    end
end