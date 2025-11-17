% PERFORMANCETRACKER
% Centralized performance tracking for Cicada components

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-17, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef PerformanceTracker < handle
    % *********************************************************************
    % CONSTANTS
    properties (Access = private, Constant)
        SLOW_THRESHOLD = 0.1; % Components taking longer than 0.1s are flagged as slow
    end
    
    % *********************************************************************
    % INSTANCE PROPERTIES
    properties (Access = private)
        dataStore = struct();
    end
    
    % *********************************************************************
    % SINGLETON PATTERN
    methods (Static)
        % =================================================================
        function obj = getInstance()
            % Returns the singleton instance of PerformanceTracker
            persistent instance;
            if isempty(instance) || ~isvalid(instance)
                instance = PerformanceTracker();
            end
            obj = instance;
        end
    end
    
    % *********************************************************************
    % PUBLIC INSTANCE METHODS
    methods (Access = public)
        % =================================================================
        function startTracking(obj, componentName, verbosityLevel)
            % Start tracking a component update
            % Only proceed if verbosity is enabled
            if verbosityLevel == 0
                return
            end
            
            % Store start time for this component
            if ~isfield(obj.dataStore, 'activeTimers')
                obj.dataStore.activeTimers = struct();
            end
            obj.dataStore.activeTimers.(obj.sanitizeName(componentName)) = now;
        end
        
        % =================================================================
        function endTracking(obj, componentName, verbosityLevel)
            % End tracking and handle logging/storage
            % Only proceed if verbosity is enabled
            if verbosityLevel == 0
                return
            end
            
            % Calculate duration
            sanitizedName = obj.sanitizeName(componentName);
            if ~isfield(obj.dataStore, 'activeTimers') || ~isfield(obj.dataStore.activeTimers, sanitizedName)
                % No start time found, skip
                return
            end

            startTime = obj.dataStore.activeTimers.(sanitizedName);
            duration = (now - startTime) * 24 * 60 * 60; %#ok<TNOW1> % Convert to seconds
            
            % Remove from active timers
            obj.dataStore.activeTimers = rmfield(obj.dataStore.activeTimers, sanitizedName);
            
            % Store the timing data
            if ~isfield(obj.dataStore, 'records')
                obj.dataStore.records = struct();
            end
            
            if ~isfield(obj.dataStore.records, sanitizedName)
                % First time tracking this component
                obj.dataStore.records.(sanitizedName) = struct(...
                    'name', componentName, ...
                    'count', 0, ...
                    'totalTime', 0, ...
                    'maxTime', 0);
            end
            
            % Update statistics
            record = obj.dataStore.records.(sanitizedName);
            record.count = record.count + 1;
            record.totalTime = record.totalTime + duration;
            record.maxTime = max(record.maxTime, duration);
            obj.dataStore.records.(sanitizedName) = record;
            
            % Handle logging based on verbosity level
            if verbosityLevel >= 2
                % Level 2 or 3: Log individual updates
                fprintf('>> CIC: %s updated in %.1g s.\n', componentName, duration);
            end
        end
        
        % =================================================================
        function displaySummary(obj, eventName)
            % Display performance summary (called on event broadcasts)
            if ~isfield(obj.dataStore, 'records') || isempty(fieldnames(obj.dataStore.records))
                % No data to display
                return
            end
            
            % Convert struct to array for easier processing
            records = struct2cell(obj.dataStore.records);
            numRecords = length(records);
            
            if numRecords == 0
                return
            end
            
            % Calculate statistics
            totalUpdates = 0;
            totalDuration = 0;
            for i = 1:numRecords
                totalUpdates = totalUpdates + records{i}.count;
                totalDuration = totalDuration + records{i}.totalTime;
            end
            
            % Sort by frequency (descending)
            counts = cellfun(@(r) r.count, records);
            [~, freqIdx] = sort(counts, 'descend');
            
            % Sort by average time (descending)
            avgTimes = cellfun(@(r) r.totalTime / r.count, records);
            [~, slowIdx] = sort(avgTimes, 'descend');
            
            % Find slow components
            slowComponents = find(avgTimes > obj.SLOW_THRESHOLD);
            
            % Display header
            fprintf('\n');
            fprintf('>> CICADA PERFORMANCE ');
            if nargin > 0 && ~isempty(eventName)
                fprintf('(%s) ', eventName);
            end
            fprintf('\n');
            fprintf('Updates: %d | Duration: %.1fs\n\n', totalUpdates, totalDuration);
            
            % Display most frequent updates (top 5)
            fprintf('MOST FREQUENT UPDATES:\n');
            numToShow = min(10, numRecords);
            for i = 1:numToShow
                idx = freqIdx(i);
                rec = records{idx};
                avgTime = rec.totalTime / rec.count;
                warningFlag = '';
                if avgTime > PerformanceTracker.SLOW_THRESHOLD
                    warningFlag = ' ⏳';
                end
                fprintf('  %-30s %3dx (avg: %.3fs, max: %.3f)%s\n', ...
                    obj.truncateName(rec.name, 30), ...
                    rec.count, avgTime, rec.maxTime, warningFlag);
            end
            
            % Display slow components if any
            if ~isempty(slowComponents)
                fprintf('\nSLOW COMPONENTS (>%.1fs):\n', obj.SLOW_THRESHOLD);
                for i = 1:length(slowComponents)
                    idx = slowComponents(i);
                    rec = records{idx};
                    avgTime = rec.totalTime / rec.count;
                    warningLevel = '';
                    if avgTime > obj.SLOW_THRESHOLD * 2
                        warningLevel = ' ⏳';
                    end
                    fprintf('  %-30s %3dx (avg: %.3fs, max: %.3fs)%s\n', ...
                        obj.truncateName(rec.name, 30), ...
                        rec.count, avgTime, rec.maxTime, warningLevel);
                end
            end
            
            % Display component update counts
            fprintf('\nCOMPONENT UPDATE COUNTS:\n  ');
            lineLength = 2;
            for i = 1:numRecords
                idx = freqIdx(i);
                rec = records{idx};
                componentStr = sprintf('%s: %d', obj.getShortName(rec.name), rec.count);
                
                % Add to line with separator
                if i > 1
                    componentStr = [' | ', componentStr]; %#ok<AGROW>
                end
                
                % Check if we need to wrap to next line
                if lineLength + length(componentStr) > 80
                    fprintf('\n  ');
                    lineLength = 2;
                    % Remove leading separator if at start of line
                    if startsWith(componentStr, ' | ')
                        componentStr = componentStr(4:end);
                    end
                end
                
                fprintf('%s', componentStr);
                lineLength = lineLength + length(componentStr);
            end
            fprintf('\n');
            
            fprintf('================================================================\n');
            fprintf('\n');
        end
        
        % =================================================================
        function clearData(obj)
            % Clear all accumulated performance data
            obj.dataStore = struct();
        end
    end
    
    % *********************************************************************
    % PRIVATE HELPER METHODS
    methods (Access = private)
        % =================================================================
        function sanitized = sanitizeName(~, name)
            % Sanitize component name for use as struct field
            % Replace any non-alphanumeric characters with underscores
            sanitized = regexprep(name, '[^a-zA-Z0-9_]', '_');
            % Ensure it starts with a letter
            if ~isempty(sanitized) && ~isletter(sanitized(1))
                sanitized = ['x', sanitized];
            end
        end
        
        % =================================================================
        function short = getShortName(~, name)
            % Get short version of component name (remove package paths)
            parts = strsplit(name, '.');
            short = parts{end};
        end
        
        % =================================================================
        function truncated = truncateName(obj, name, maxLen)
            % Truncate name to maximum length, keeping the end
            short = obj.getShortName(name);
            if length(short) <= maxLen
                truncated = short;
            else
                truncated = ['...', short(end-maxLen+4:end)];
            end
        end
    end
end
