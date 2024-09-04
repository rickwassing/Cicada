% TOAST
% Displays messages to the user when certain events have completed, and
% shows the status of that event ('success', 'warning', or 'error')

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-06-27, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

classdef Toast < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Id;
        Title = '';
        Message = '';
        Color;
        Timeout;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        ToastPanel matlab.ui.container.Panel
        ToastGridLayout matlab.ui.container.GridLayout
        ToastTitlePanel matlab.ui.container.Panel
        ToastTitleGridLayout matlab.ui.container.GridLayout
        ToastTitleLabel matlab.ui.control.Label
        ToastTitleButton matlab.ui.control.Button
        ToastMessagePanel matlab.ui.container.Panel
        ToastMessageGridLayout matlab.ui.container.GridLayout
        ToastMessageLabel matlab.ui.control.Label
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function setup(Obj)
            % -------------------------------------------------------------
            % Create sub-components
            % -------------------------------------------------------------
            Obj.Id = datestr(now, 'HHMMSSFFF');
            Obj.Tag = ['Toast_id-', Obj.Id];
            Obj.Timeout = 5;
            % -------------------------------------------------------------
            Obj.ToastPanel = uipanel(Obj, ...
                'Tag', ['Toast_Panel_id-', Obj.Id], ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % -------------------------------------------------------------
            Obj.ToastGridLayout = uigridlayout(Obj.ToastPanel, ...
                'Tag', ['Toast_GridLayout_id-', Obj.Id], ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {24, 24}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', 0);
            % -------------------------------------------------------------
            Obj.ToastTitlePanel = uipanel(Obj.ToastGridLayout, ...
                'Tag', ['Toast_TitlePanel_id-', Obj.Id], ...
                'BorderType', 'none', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.ToastTitlePanel.Layout.Column = 1;
            Obj.ToastTitlePanel.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.ToastTitleGridLayout = uigridlayout(Obj.ToastTitlePanel, ...
                'Tag', ['Toast_TitleGridLayout_id-', Obj.Id], ...
                'ColumnWidth', {'1x', 24}, ...
                'RowHeight', {24}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [6, 0, 0, 0]);
            % -------------------------------------------------------------
            Obj.ToastTitleLabel = uilabel(Obj.ToastTitleGridLayout, ...
                'Tag', ['Toast_TitleLabel_id-', Obj.Id], ...
                'Text', '', ...
                'FontWeight', 'bold', ...
                'FontColor', [1, 1, 1], ...
                'FontSize', 11);
            Obj.ToastTitleLabel.Layout.Column = 1;
            Obj.ToastTitleLabel.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.ToastTitleButton = uibutton(Obj.ToastTitleGridLayout, ...
                'Tag', ['Toast_TitleButton_id-', Obj.Id], ...
                'Text', '×', ...
                'FontWeight', 'bold', ...
                'FontColor', [1, 1, 1], ...
                'ButtonPushedFcn', @(Obj, event) delete(Obj.Parent.Parent.Parent.Parent.Parent));
            Obj.ToastTitleButton.Layout.Column = 2;
            Obj.ToastTitleButton.Layout.Row = 1;
            % -------------------------------------------------------------
            Obj.ToastMessagePanel = uipanel(Obj.ToastGridLayout, ...
                'Tag', ['Toast_MessagePanel_id-', Obj.Id], ...
                'BorderType', 'none', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            Obj.ToastMessagePanel.Layout.Column = 1;
            Obj.ToastMessagePanel.Layout.Row = 2;
            % -------------------------------------------------------------
            Obj.ToastMessageGridLayout = uigridlayout(Obj.ToastMessagePanel, ...
                'Tag', ['Toast_MessageGridLayout_id-', Obj.Id], ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0, ...
                'Padding', [6, 0, 0, 0]);
            % -------------------------------------------------------------
            Obj.ToastMessageLabel = uilabel(Obj.ToastMessageGridLayout, ...
                'Tag', ['Toast_MessageLabel_id-', Obj.Id], ...
                'Text', '', ...
                'FontColor', [33, 37, 41]./255, ...
                'FontSize', 10);
            Obj.ToastMessageLabel.Layout.Column = 1;
            Obj.ToastMessageLabel.Layout.Row = 1;
        end
        % =================================================================
        function update(Obj)
            try
            % -------------------------------------------------------------
            % Timer
            if Obj.Verbose; Time = now; end
            % -------------------------------------------------------------
            Obj.ToastTitleLabel.Text = Obj.Title;
            Obj.ToastMessageLabel.Text = Obj.Message;
            % -------------------------------------------------------------
            if isempty(Obj.Message)
                Obj.Position(4) = 26;
            end
            % -------------------------------------------------------------
            Colors = app_colors();
            switch lower(Obj.Color)
                case 'success'
                    Obj.ToastTitleGridLayout.BackgroundColor = Colors.bs_success;
                    Obj.ToastTitleButton.BackgroundColor = Colors.bs_success;
                    Obj.ToastMessageGridLayout.BackgroundColor = Colors.bs_success_subtle;
                case 'warning'
                    Obj.ToastTitleGridLayout.BackgroundColor = Colors.bs_warning;
                    Obj.ToastTitleButton.BackgroundColor = Colors.bs_warning;
                    Obj.ToastMessageGridLayout.BackgroundColor = Colors.bs_warning_subtle;
                case 'danger'
                    Obj.ToastTitleGridLayout.BackgroundColor = Colors.bs_danger;
                    Obj.ToastTitleButton.BackgroundColor = Colors.bs_danger;
                    Obj.ToastMessageGridLayout.BackgroundColor = Colors.bs_danger_subtle;
                case 'info'
                    Obj.ToastTitleGridLayout.BackgroundColor = Colors.bs_info;
                    Obj.ToastTitleButton.BackgroundColor = Colors.bs_info;
                    Obj.ToastMessageGridLayout.BackgroundColor = Colors.bs_info_subtle;
            end
            % -------------------------------------------------------------
            Timing = timer(...
                'StartDelay', Obj.Timeout, ...
                'TimerFcn', {@deletetoast, Obj});
            start(Timing);
            % -------------------------------------------------------------
            if Obj.Verbose
                fprintf('>> CIC: Toast ''%s'' updated in %.1g s.\n', Obj.Id, (now-Time)*24*60*60)
            end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in Toast.m')
            end
        end
    end
    methods (Access = public)
        function hUpdate(Obj, app, event) %#ok<INUSD>
            % do something
        end
    end
end