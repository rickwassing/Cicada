% DATAPANELPOOL
% An pre-initiated pool of data-panel objects.

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

classdef DataPanelPool < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        Pool matlab.ui.componentcontainer.ComponentContainer
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            % Create first pool singleton and add event listener
            % -------------------------------------------------------------
            Obj.Tag = 'DataPanelPool';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'DataPanelPool_Panel', ...
                'Title', 'Pool', ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.Pool(1) = DataPanel(Obj.Panel, 'Title', 'none', 'Status', 'idle', 'Verbose', true);
        end
        % =================================================================
        function update(Obj)
            % -------------------------------------------------------------
            % Do something or not?
            Obj; %#ok<VUNUS> 
        end
    end
    methods (Access = public)
        % =================================================================
        % Pull an object from the pool, or create new if pool is empty
        function Singleton = pull(Obj, Parent)
            if length(Obj.Pool) == 1
                if Obj.Verbose
                    fprintf('>> CIC: Copying a DataPanel from the Pool.\n')
                end
                Singleton = copyobj(Obj.Pool(1), Parent);
                app_addlisteners([], Singleton, {'eDatasetChanged', 'eDataChanged', 'eDataPanelPulled', 'eDisplaySettingsChanged'});
            else
                if Obj.Verbose
                    fprintf('>> CIC: Grabbing a DataPanel from the Pool.\n')
                end
                Singleton = Obj.Pool(end);
                Singleton.Parent = Parent;
                Obj.Pool(end) = [];
            end
            Singleton.Status = 'active';
        end
        % =================================================================
        % Return the single object to the unused pool, once we are done with it
        function recycle(Obj, Singleton)
            fprintf('>> CIC: Recycling a DataPanel back to the Pool.\n')
            Singleton.Title = 'none';
            Singleton.PanelNum = [];
            Singleton.Start = [];
            Singleton.End = [];
            Singleton.ActogramWidth = '';
            Singleton.Metric = struct('y', [], 'modality', '', 'device', '', 'labels', {}, 'srate', [], 'pnts', [], 'xmin', '', 'xmax', '', 'showSingleMetric', [], 'show', [], 'height', [], 'log', [], 'ylim', [], 'color', [], 'zindex', []);
            Singleton.IsHovered = false;
            Singleton.Status = 'idle';
            Singleton.Parent = Obj.Panel;
            Obj.Pool(end+1) = Singleton;
        end
    end
end