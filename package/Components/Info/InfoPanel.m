% INFOPANEL
% Displays the meta data in 'ACT.info'.

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

classdef InfoPanel < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Title;
        KeyValues;
        Row;
        Verbose;
        Enable;
    end
    properties (Access = private, Transient, NonCopyable)
        Panel matlab.ui.container.Panel
        GridLayout matlab.ui.container.GridLayout
        KeyLabels matlab.ui.control.Label
        ValueLabels matlab.ui.control.Label
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            Colors = app_colors();
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.Tag = 'InfoPanel';
            Obj.Panel = uipanel(Obj, ...
                'Tag', 'InfoPanel_Panel', ...
                'Title', 'Study', ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', Colors.body_primary, ...
                'BackgroundColor', [1, 1, 1], ...
                'HighLightColor', [0.8, 0.8, 0.8], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.GridLayout = uigridlayout(Obj.Panel, ...
                'Tag', 'InfoPanel_GridLayout', ...
                'ColumnWidth', {'3x', '5x'}, ...
                'RowHeight', {14}, ...
                'ColumnSpacing', 3, ...
                'RowSpacing', 3, ...
                'Padding', 3, ...
                'BackgroundColor', [1, 1, 1]);
        end
        % =================================================================
        function update(Obj)
            try
                % -------------------------------------------------------------
                % Timer
                if Obj.Verbose; Time = now; end %#ok<TNOW1>
                % -------------------------------------------------------------
                Colors = app_colors();
                % -------------------------------------------------------------
                Obj.Layout.Row = Obj.Row;
                Obj.Panel.Title = Obj.Title;
                Obj.Panel.Enable = Obj.Enable;
                Obj.GridLayout.RowHeight = repmat({14}, 1, size(Obj.KeyValues, 1));
                for i = 1:size(Obj.KeyValues, 1)
                    if i > length(Obj.KeyLabels)
                        Obj.RenderKeyValueLabels(i, Obj.KeyValues{i, 1}, Obj.KeyValues{i, 2}, Colors.body_primary)
                    elseif ~isvalid(Obj.KeyLabels(i))
                        Obj.RenderKeyValueLabels(i, Obj.KeyValues{i, 1}, Obj.KeyValues{i, 2}, Colors.body_primary)
                    else
                        Obj.KeyLabels(i).Text = strrep(Obj.KeyValues{i, 1}, '_', ' ');
                        Obj.ValueLabels(i).Text = Obj.KeyValues{i, 2};
                    end
                end
                for i = length(Obj.KeyLabels):-1:size(Obj.KeyValues, 1)+1
                    delete(Obj.KeyLabels(i));
                    delete(Obj.ValueLabels(i));
                end
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: InfoPanel ''%s'' updated in %.1g s.\n', Obj.Title, (now-Time)*24*60*60) %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in InfoPanel.m')
            end
        end
        % =================================================================
        function RenderKeyValueLabels(Obj, i, Key, Label, Color)
            Obj.KeyLabels(i) = uilabel(Obj.GridLayout, ...
                'Text', strrep(Key, '_', ' '), ...
                'FontWeight', 'bold', ...
                'FontColor', Color, ...
                'HorizontalAlignment', 'right', ...
                'FontSize', 10);
            Obj.ValueLabels(i) = uilabel(Obj.GridLayout, ...
                'Text', strrep(Label, '_', ' '), ...
                'FontSize', 10);
            Obj.KeyLabels(i).Layout.Column = 1;
            Obj.KeyLabels(i).Layout.Row = i;
            Obj.ValueLabels(i).Layout.Column = 2;
            Obj.ValueLabels(i).Layout.Row = i;
        end
    end
    % *********************************************************************
    methods (Access = public)
        % =================================================================
        function hUpdate(Obj, app, event) %#ok<INUSD>
            try
                % -------------------------------------------------------------
                % If the dataset is empty, then disable the panel and initiate the KeyVals to empty
                if isempty(app.ACT)
                    Obj.Enable = 'off';
                    Obj.KeyValues = {};
                    return
                else
                    % ---------------------------------------------------------
                    % Otherwise, the dataset is not empty, enable panels and generate key-value pairs
                    Obj.Enable = 'on';
                    Obj.KeyValues = {};
                    switch lower(Obj.Title)
                        case 'study'
                            Obj.KeyValues = {...
                                'Institute', app.ACT.info.institute; ...
                                'Name', app.ACT.info.study; ...
                                'Researcher', app.ACT.info.researcher};
                        case 'participant'
                            Obj.KeyValues = {...
                                'ID', app.ACT.info.participant_id; ...
                                'Group', app.ACT.info.group; ...
                                'Session', app.ACT.info.session; ...
                                'Condition', app.ACT.info.condition; ...
                                'DOB', datestr(datenum(app.ACT.info.dob, 'yyyy-mm-dd'), 'dd mmm yyyy'); ...
                                'Sex', app.ACT.info.sex; ...
                                'Height', ifelse(isnan(app.ACT.info.height), '', sprintf('%i cm', app.ACT.info.height)); ...
                                'Weight', ifelse(isnan(app.ACT.info.weight), '', sprintf('%.1f kg', app.ACT.info.weight)); ...
                                'Handedness', app.ACT.info.handedness}; %#ok<DATNM,DATST>
                        case 'recording'
                            Obj.KeyValues = {...
                                'Start_date', iso2human(app.ACT.xmin, 'OmitMilliseconds', true); ...
                                'End_date', iso2human(app.ACT.xmax, 'OmitMilliseconds', true); ...
                                'Duration', duration2str(...
                                datenum(app.ACT.xmax, 'yyyy-mm-ddTHH:MM:SS.FFF') - ...
                                datenum(app.ACT.xmin, 'yyyy-mm-ddTHH:MM:SS.FFF'))}; %#ok<DATNM>
                        case 'modalities'
                            Obj.KeyValues = cell(0);
                            M = app.ACT.info.modalities;
                            for i = 1:length(M)
                                Obj.KeyValues(end+1, :) = [upper(M(i)), {''}];
                                for j = 1:length(app.ACT.data)
                                    if ~strcmpi(app.ACT.data(j).modality, M{i})
                                        continue
                                    end
                                    device = app.ACT.data(j).device;
                                    loc = app.ACT.data(j).loc;
                                    srate = app.ACT.data(j).srate;
                                    srateformat = ifelse(mod(srate, 1) == 0, '%i', '%.3f');
                                    Obj.KeyValues(end+1, :) = [{device}, {sprintf(['%s (', srateformat, ' Hz)'], ...
                                        loc, srate)}];
                                end
                            end
                    end
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''hUpdate'' in InfoPanel.m')
            end
        end
    end
end