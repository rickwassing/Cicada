% DATALEGEND
% Labels to indicate the type of data trace

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

classdef DataLegend < handle
    % *********************************************************************
    % PROPERTIES
    properties
        Metric;
        Offset = 0;
        Tag;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Parent
        Graphics matlab.graphics.primitive.Text
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = DataLegend(Parent, varargin)
            % -------------------------------------------------------------
            % Create line
            % Create the original and smooth lines
            Obj.Tag = 'DataLegend';
            Obj.Parent = Parent;
            % -------------------------------------------------------------
            % Set other parameters using name-value pairs
            if nargin > 1
                for i = 1:2:length(varargin)
                    switch lower(varargin{i})
                        case 'verbose'
                            Obj.Verbose = varargin{i+1};
                    end
                end
            end
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
                Modalities = unique({Obj.Metric.modality}, 'stable');
                idx = nan(length(Modalities), 1);
                for i = 1:length(Modalities)
                    idx(i) = find(strcmpi({Obj.Metric.modality}, Modalities{i}) & [Obj.Metric.show], 1, 'first');
                end
                Modality = '';
                Offset = Obj.Offset; %#ok<PROP>
                Obj.Metric = Obj.Metric(idx);
                for i = 1:length(Obj.Metric)
                    if ~strcmpi(Obj.Metric(i).modality, Modality)
                        Modality = Obj.Metric(i).modality;
                        Height = Obj.Metric(i).height;
                        DoRender = false;
                        if i > length(Obj.Graphics)
                            DoRender = true;
                        elseif ~isvalid(Obj.Graphics(i)) || ~isgraphics(Obj.Graphics(i))
                            DoRender = true;
                        end
                        if DoRender
                            Obj.Graphics(i) = text(Obj.Parent, NaN, NaN, '', ...
                                'FontSize', 8, ...
                                'FontWeight', 'bold', ...
                                'Margin', 1, ...
                                'BackgroundColor', Colors.bg_primary, ...
                                'VerticalAlignment', 'top');
                        end
                        Obj.Graphics(i).String = upper(Modality);
                        Obj.Graphics(i).Color = Obj.Metric(i).color;
                        Obj.Graphics(i).Position(1) = iso2datenum(Obj.Metric(i).xmin);
                        Obj.Graphics(i).Position(2) = Offset + Height * 0.9; %#ok<PROP>
                        % Update offset for next one
                        Offset = Offset + Height; %#ok<PROP>
                    end
                end
                % -------------------------------------------------------------
                % Hide legend labels that are not needed
                for i = length(Obj.Graphics):-1:length(Obj.Metric)+1
                    Obj.Graphics(i).String = '';
                    Obj.Graphics(i).Position(2) = -1;
                end
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DataLegend ''%s'' updated in %.1g s.\n', Obj.Parent.Tag, (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DataLegend.m')
            end
        end
    end
end