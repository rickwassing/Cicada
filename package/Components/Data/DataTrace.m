% DATATRACE
% A single data trace

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

classdef DataTrace < handle
    % *********************************************************************
    % PROPERTIES
    properties
        Metric;
        Offset;
        Height;
        Tag;
        Verbose;
    end
    properties (Access = private, Transient, NonCopyable)
        Line (1,1) matlab.graphics.chart.primitive.Line
    end
    % *********************************************************************
    % METHODS
    methods
        % =================================================================
        function Obj = DataTrace(Parent, varargin)
            % -------------------------------------------------------------
            % Create line
            % Create the original and smooth lines
            Obj.Tag = 'DataTrace';
            Obj.Line = plot(Parent, NaN, NaN, ...
                'Tag', 'DataTrace_Line', ...
                'LineWidth', 1.25);
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
                if isempty(Obj.Metric)
                    delete(Obj.Line);
                    return
                end
                % -------------------------------------------------------------
                if ~Obj.Metric.show
                    Obj.Line.XData = NaN;
                    Obj.Line.YData = NaN;
                    return
                end
                % -------------------------------------------------------------
                if isempty(Obj.Metric.y)
                    Obj.Line.XData = NaN;
                    Obj.Line.YData = NaN;
                    return
                end
                % -------------------------------------------------------------
                % Get the data
                YData = Obj.Metric.y;
                % Scale the data
                if Obj.Metric.log
                    % Make sure there are no zeros for log-transform
                    if any(YData < 0)
                        YData = YData - min(YData);
                    end
                    YSort = sort(YData);
                    idx = find(YSort > 0, 1, 'first');
                    if isempty(idx)
                        MinYData = 1;
                    else
                        MinYData = YSort(idx);
                    end
                    % Replace zeros with minimum non-zero value
                    YData(YData < MinYData) = MinYData;
                    % Apply log-10 transformation to data
                    YData = log10(YData);
                    % Apply log-10 transformation to y-limits
                    YLim = single([Obj.Metric.ymin, Obj.Metric.ymax]);
                    if any(YLim < 0)
                        YLim = YLim - min(YLim);
                    end
                    YLim(YLim < MinYData) = MinYData;
                    YLim = log10(YLim);
                else
                    % Get the y-limits
                    YLim = [Obj.Metric.ymin, Obj.Metric.ymax];
                end
                % Crop YData between the limits and apply scaling
                YData(YData < YLim(1)) = YLim(1);
                YData(YData > YLim(2)) = YLim(2);
                YData = (YData - YLim(1)) / (YLim(2) - YLim(1));
                % Place the data in the correct sub-axes
                YData = Obj.Offset + Obj.Height .* YData;
                % Apply XData YData and color
                Obj.Line.XData = gettimes(Obj.Metric, 'datenum');
                Obj.Line.YData = YData;
                Obj.Line.Color = Obj.Metric.color;
                % Set the tag
                Obj.Tag = ['DataTrace_', strrep(Obj.Metric.label, ' ', '_')];
                Obj.Line.Tag = ['DataTrace_Line_', strrep(Obj.Metric.label, ' ', '_')];
                % -------------------------------------------------------------
                if Obj.Verbose
                    fprintf('>> CIC: DataTrace ''%s'' at ''%s'' updated in %.1g s.\n', Obj.Metric.label, datenum2iso(Obj.Line.XData(1)), (now-Time)*24*60*60); %#ok<TNOW1>
                end
            catch ME
                printerrormessage(ME, 'The error occurred during ''update'' in DataTrace.m')
            end
        end
    end
end