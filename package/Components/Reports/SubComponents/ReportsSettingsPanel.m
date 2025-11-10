% REPORTSSETTINGSPANEL
% Panel with all the settings (Fonts, colors etc.)

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-10-12, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef ReportsSettingsPanel < matlab.ui.componentcontainer.ComponentContainer
    
    properties (Access = public)
        
    end
    
    properties (Access = private, Transient, NonCopyable)
        Components
    end
    
    methods (Access = protected)
        function setup(Obj)

            % Create Grid
            Obj.Components.Grid = uigridlayout(Obj);
            Obj.Components.Grid.ColumnWidth = {'1x'};
            Obj.Components.Grid.RowHeight = {24, 47, 47, 47, 47, 93, '1x'};
            Obj.Components.Grid.ColumnSpacing = 6;
            Obj.Components.Grid.RowSpacing = 6;
            Obj.Components.Grid.Padding = [6 6 6 6];
            Obj.Components.Grid.BackgroundColor = [0.6392 0.8118 0.7294];

            % Create ExportButton
            Obj.Components.ExportButton = uibutton(Obj.Components.Grid, 'push');
            Obj.Components.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            Obj.Components.ExportButton.BackgroundColor = [0.149 0.1804 0.4];
            Obj.Components.ExportButton.FontSize = 10;
            Obj.Components.ExportButton.FontWeight = 'bold';
            Obj.Components.ExportButton.FontColor = [1 1 1];
            Obj.Components.ExportButton.Layout.Row = 1;
            Obj.Components.ExportButton.Layout.Column = 1;
            Obj.Components.ExportButton.Text = 'EXPORT PDF';

            % Create TitleSettingsPanel
            Obj.Components.TitleSettingsPanel = uipanel(Obj.Components.Grid);
            Obj.Components.TitleSettingsPanel.BorderColor = [0.8 0.8 0.8];
            Obj.Components.TitleSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            Obj.Components.TitleSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            Obj.Components.TitleSettingsPanel.Title = 'TITLES';
            Obj.Components.TitleSettingsPanel.BackgroundColor = [1 1 1];
            Obj.Components.TitleSettingsPanel.Layout.Row = 2;
            Obj.Components.TitleSettingsPanel.Layout.Column = 1;
            Obj.Components.TitleSettingsPanel.FontWeight = 'bold';
            Obj.Components.TitleSettingsPanel.FontSize = 11;

            % Create TitleGrid
            Obj.Components.TitleGrid = uigridlayout(Obj.Components.TitleSettingsPanel);
            Obj.Components.TitleGrid.ColumnWidth = {'1x', 50, 34};
            Obj.Components.TitleGrid.RowHeight = {20};
            Obj.Components.TitleGrid.ColumnSpacing = 3;
            Obj.Components.TitleGrid.RowSpacing = 3;
            Obj.Components.TitleGrid.Padding = [3 3 3 3];
            Obj.Components.TitleGrid.BackgroundColor = [1 1 1];

            % Create TitleFontFamilyInput
            Obj.Components.TitleFontFamilyInput = uidropdown(Obj.Components.TitleGrid);
            Obj.Components.TitleFontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            Obj.Components.TitleFontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.TitleFontFamilyInput.Tag = 'title-fontFamily';
            Obj.Components.TitleFontFamilyInput.FontSize = 11;
            Obj.Components.TitleFontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.TitleFontFamilyInput.Layout.Row = 1;
            Obj.Components.TitleFontFamilyInput.Layout.Column = 1;
            Obj.Components.TitleFontFamilyInput.Value = 'Georgia';

            % Create TitleFontSizeInput
            Obj.Components.TitleFontSizeInput = uidropdown(Obj.Components.TitleGrid);
            Obj.Components.TitleFontSizeInput.Items = {};
            Obj.Components.TitleFontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.TitleFontSizeInput.Tag = 'title-fontSize';
            Obj.Components.TitleFontSizeInput.FontSize = 11;
            Obj.Components.TitleFontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.TitleFontSizeInput.Layout.Row = 1;
            Obj.Components.TitleFontSizeInput.Layout.Column = 2;
            Obj.Components.TitleFontSizeInput.Value = {};

            % Create H1SettingsPanel
            Obj.Components.H1SettingsPanel = uipanel(Obj.Components.Grid);
            Obj.Components.Components.H1SettingsPanel.BorderColor = [0.8 0.8 0.8];
            Obj.Components.H1SettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            Obj.Components.H1SettingsPanel.HighlightColor = [0.8 0.8 0.8];
            Obj.Components.H1SettingsPanel.Title = 'HEADERS';
            Obj.Components.H1SettingsPanel.BackgroundColor = [1 1 1];
            Obj.Components.H1SettingsPanel.Layout.Row = 3;
            Obj.Components.H1SettingsPanel.Layout.Column = 1;
            Obj.Components.H1SettingsPanel.FontWeight = 'bold';
            Obj.Components.H1SettingsPanel.FontSize = 11;

            % Create H1Grid
            Obj.Components.H1Grid = uigridlayout(Obj.Components.H1SettingsPanel);
            Obj.Components.H1Grid.ColumnWidth = {'1x', 50, 34};
            Obj.Components.H1Grid.RowHeight = {20};
            Obj.Components.H1Grid.ColumnSpacing = 3;
            Obj.Components.H1Grid.RowSpacing = 3;
            Obj.Components.H1Grid.Padding = [3 3 3 3];
            Obj.Components.H1Grid.BackgroundColor = [1 1 1];

            % Create H1FontFamilyInput
            Obj.Components.H1FontFamilyInput = uidropdown(Obj.Components.H1Grid);
            Obj.Components.H1FontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            Obj.Components.H1FontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.H1FontFamilyInput.Tag = 'h1-fontFamily';
            Obj.Components.H1FontFamilyInput.FontSize = 11;
            Obj.Components.H1FontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.H1FontFamilyInput.Layout.Row = 1;
            Obj.Components.H1FontFamilyInput.Layout.Column = 1;
            Obj.Components.H1FontFamilyInput.Value = 'Georgia';

            % Create H1FontSizeInput
            Obj.Components.H1FontSizeInput = uidropdown(Obj.Components.H1Grid);
            Obj.Components.H1FontSizeInput.Items = {};
            Obj.Components.H1FontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.H1FontSizeInput.Tag = 'h1-fontSize';
            Obj.Components.H1FontSizeInput.FontSize = 11;
            Obj.Components.H1FontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.H1FontSizeInput.Layout.Row = 1;
            Obj.Components.H1FontSizeInput.Layout.Column = 2;
            Obj.Components.H1FontSizeInput.Value = {};

            % Create ParSettingsPanel
            Obj.Components.ParSettingsPanel = uipanel(Obj.Components.Grid);
            Obj.Components.ParSettingsPanel.BorderColor = [0.8 0.8 0.8];
            Obj.Components.ParSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            Obj.Components.ParSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            Obj.Components.ParSettingsPanel.Title = 'PARAGRAPH';
            Obj.Components.ParSettingsPanel.BackgroundColor = [1 1 1];
            Obj.Components.ParSettingsPanel.Layout.Row = 4;
            Obj.Components.ParSettingsPanel.Layout.Column = 1;
            Obj.Components.ParSettingsPanel.FontWeight = 'bold';
            Obj.Components.ParSettingsPanel.FontSize = 11;

            % Create ParGrid
            Obj.Components.ParGrid = uigridlayout(Obj.Components.ParSettingsPanel);
            Obj.Components.ParGrid.ColumnWidth = {'1x', 50, 34};
            Obj.Components.ParGrid.RowHeight = {20};
            Obj.Components.ParGrid.ColumnSpacing = 3;
            Obj.Components.ParGrid.RowSpacing = 3;
            Obj.Components.ParGrid.Padding = [3 3 3 3];
            Obj.Components.ParGrid.BackgroundColor = [1 1 1];

            % Create ParFontFamilyInput
            Obj.Components.ParFontFamilyInput = uidropdown(Obj.Components.ParGrid);
            Obj.Components.ParFontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            Obj.Components.ParFontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.ParFontFamilyInput.Tag = 'paragraph-fontFamily';
            Obj.Components.ParFontFamilyInput.FontSize = 11;
            Obj.Components.ParFontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.ParFontFamilyInput.Layout.Row = 1;
            Obj.Components.ParFontFamilyInput.Layout.Column = 1;
            Obj.Components.ParFontFamilyInput.Value = 'Helvetica';

            % Create ParFontSizeInput
            Obj.Components.ParFontSizeInput = uidropdown(Obj.Components.ParGrid);
            Obj.Components.ParFontSizeInput.Items = {};
            Obj.Components.ParFontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.ParFontSizeInput.Tag = 'paragraph-fontSize';
            Obj.Components.ParFontSizeInput.FontSize = 11;
            Obj.Components.ParFontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.ParFontSizeInput.Layout.Row = 1;
            Obj.Components.ParFontSizeInput.Layout.Column = 2;
            Obj.Components.ParFontSizeInput.Value = {};

            % Create SmallSettingsPanel
            Obj.Components.SmallSettingsPanel = uipanel(Obj.Components.Grid);
            Obj.Components.SmallSettingsPanel.BorderColor = [0.8 0.8 0.8];
            Obj.Components.SmallSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            Obj.Components.SmallSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            Obj.Components.SmallSettingsPanel.Title = 'SMALL';
            Obj.Components.SmallSettingsPanel.BackgroundColor = [1 1 1];
            Obj.Components.SmallSettingsPanel.Layout.Row = 5;
            Obj.Components.SmallSettingsPanel.Layout.Column = 1;
            Obj.Components.SmallSettingsPanel.FontWeight = 'bold';
            Obj.Components.SmallSettingsPanel.FontSize = 11;

            % Create SmallGrid
            Obj.Components.SmallGrid = uigridlayout(Obj.Components.SmallSettingsPanel);
            Obj.Components.SmallGrid.ColumnWidth = {'1x', 50, 34};
            Obj.Components.SmallGrid.RowHeight = {20};
            Obj.Components.SmallGrid.ColumnSpacing = 3;
            Obj.Components.SmallGrid.RowSpacing = 3;
            Obj.Components.SmallGrid.Padding = [3 3 3 3];
            Obj.Components.SmallGrid.BackgroundColor = [1 1 1];

            % Create SmallFontFamilyInput
            Obj.Components.SmallFontFamilyInput = uidropdown(Obj.Components.SmallGrid);
            Obj.Components.SmallFontFamilyInput.Items = {'Georgia', 'Times New Roman', 'Calibri', 'Helvetica', 'Arial'};
            Obj.Components.SmallFontFamilyInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.SmallFontFamilyInput.Tag = 'small-fontFamily';
            Obj.Components.SmallFontFamilyInput.FontSize = 11;
            Obj.Components.SmallFontFamilyInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.SmallFontFamilyInput.Layout.Row = 1;
            Obj.Components.SmallFontFamilyInput.Layout.Column = 1;
            Obj.Components.SmallFontFamilyInput.Value = 'Helvetica';

            % Create SmallFontSizeInput
            Obj.Components.SmallFontSizeInput = uidropdown(Obj.Components.SmallGrid);
            Obj.Components.SmallFontSizeInput.Items = {};
            Obj.Components.SmallFontSizeInput.ValueChangedFcn = createCallbackFcn(app, @SettingsChanged, true);
            Obj.Components.SmallFontSizeInput.Tag = 'small-fontSize';
            Obj.Components.SmallFontSizeInput.FontSize = 11;
            Obj.Components.SmallFontSizeInput.BackgroundColor = [0.9804 0.9804 0.9804];
            Obj.Components.SmallFontSizeInput.Layout.Row = 1;
            Obj.Components.SmallFontSizeInput.Layout.Column = 2;
            Obj.Components.SmallFontSizeInput.Value = {};

            % Create LogoSettingsPanel
            Obj.Components.LogoSettingsPanel = uipanel(Obj.Components.Grid);
            Obj.Components.LogoSettingsPanel.BorderColor = [0.8 0.8 0.8];
            Obj.Components.LogoSettingsPanel.ForegroundColor = [0.0196 0.2392 0.2784];
            Obj.Components.LogoSettingsPanel.HighlightColor = [0.8 0.8 0.8];
            Obj.Components.LogoSettingsPanel.Title = 'LOGO';
            Obj.Components.LogoSettingsPanel.BackgroundColor = [1 1 1];
            Obj.Components.LogoSettingsPanel.Layout.Row = 6;
            Obj.Components.LogoSettingsPanel.Layout.Column = 1;
            Obj.Components.LogoSettingsPanel.FontWeight = 'bold';
            Obj.Components.LogoSettingsPanel.FontSize = 11;

            % Create LogoGrid
            Obj.Components.LogoGrid = uigridlayout(Obj.Components.LogoSettingsPanel);
            Obj.Components.LogoGrid.ColumnWidth = {'1x', 75};
            Obj.Components.LogoGrid.RowHeight = {20, 20, 20};
            Obj.Components.LogoGrid.ColumnSpacing = 3;
            Obj.Components.LogoGrid.RowSpacing = 3;
            Obj.Components.LogoGrid.Padding = [3 3 3 3];
            Obj.Components.LogoGrid.BackgroundColor = [1 1 1];

            % Create ChooseFileButton
            Obj.Components.ChooseFileButton = uibutton(Obj.Components.LogoGrid, 'push');
            Obj.Components.ChooseFileButton.ButtonPushedFcn = createCallbackFcn(app, @ChooseFileButtonPushed, true);
            Obj.Components.ChooseFileButton.BackgroundColor = [0.4196 0.4588 0.4902];
            Obj.Components.ChooseFileButton.FontSize = 11;
            Obj.Components.ChooseFileButton.FontWeight = 'bold';
            Obj.Components.ChooseFileButton.FontColor = [1 1 1];
            Obj.Components.ChooseFileButton.Layout.Row = 2;
            Obj.Components.ChooseFileButton.Layout.Column = 2;
            Obj.Components.ChooseFileButton.Text = 'Choose File';

            % Create LogoImage
            Obj.Components.LogoImage = uiimage(Obj.Components.LogoGrid);
            Obj.Components.LogoImage.Layout.Row = [1 3];
            Obj.Components.LogoImage.Layout.Column = 1;

        end
        
        function update(Obj)
            % Do something
        end

    end

end