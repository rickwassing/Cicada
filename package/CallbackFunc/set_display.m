% SET_DISPLAY
% Update the display settings of data traces of a modality
%
% Usage:
%   >> set_display(ACT, src, event);
%
% Inputs:
%   'ACT' - [struct] standardized ACT structure
%   'event' - [Object] event data.
%
% Outputs:
%   'ACT' - [struct] standardized ACT structure

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-07-25, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function ACT = set_display(ACT, event)
try
    % =========================================================================
    % Extract the user data from the source component
    Obj = [];
    Metric = [];
    for i = 1:2:length(event.Source.UserData)
        switch lower(event.Source.UserData{i})
            case 'obj'
                Obj = event.Source.UserData{i+1};
            case 'metric'
                Metric = event.Source.UserData{i+1};
        end
    end
    % =========================================================================
    % The tag will tell us what parameter to update
    for i = 1:length(Metric)
        % ---------------------------------------------------------------------
        % Find the index of the metric to update the parameter
        idx = ...
            strcmpi({ACT.metric.modality}, Metric(i).modality) & ...
            strcmpi({ACT.metric.device}, Metric(i).device) & ...
            strcmpi({ACT.metric.label}, Metric(i).label) & ...
            strcmpi({ACT.metric.loc}, Metric(i).loc);
        % ---------------------------------------------------------------------
        % Go on and update the parameter
        switch lower(event.Source.Tag)
            % -----------------------------------------------------------------
            case 'height'
                % -------------------------------------------------------------
                % Change the relative height of the axis
                ACT.metric(idx).height = event.Value;
            case 'show'
                % -------------------------------------------------------------
                % Show or hide data traces
                if ~strcmpi(Metric.modality, 'ACCEL')
                    % If not acceleration, simply set the show/hide value
                    ACT.metric(idx).show = event.Value;
                else
                    % Only change if the new value is true
                    if ~event.Value
                        event.Source.Value = true;
                        return
                    end
                    % Accelerometry can only show one trace, so first set all values to false
                    for j = 1:length(ACT.metric)
                        if strcmpi(ACT.metric(j).modality, 'ACCEL')
                            ACT.metric(j).show = false;
                        end
                    end
                    % Set the current value to what the user set it to
                    ACT.metric(idx).show = event.Value;
                end
            case 'log'
                % -------------------------------------------------------------
                % Logarithmic or linear
                ACT.metric(idx).log = event.Value;
            case 'ymin'
                % -------------------------------------------------------------
                % Minimum value
                ACT.metric(idx).ymin = event.Value;
            case 'ymax'
                % -------------------------------------------------------------
                % Maximum value
                ACT.metric(idx).ymax = event.Value;
            case 'color'
                % -------------------------------------------------------------
                % Set the new color, and update the colorpicker button color
                ACT.metric(idx).color = event.Source.BackgroundColor;
            case 'moveup'
                % -------------------------------------------------------------
                % Find the trace that has a higher zindex and swap
                idxModality = find(strcmpi({ACT.metric.modality}, Metric(i).modality));
                zindex = [ACT.metric(idxModality).zindex];
                idxNew = find(zindex > Metric(i).zindex, 1, 'first');
                Current = Metric(i).zindex;
                New = zindex(idxNew);
                ACT.metric(idxModality(idxNew)).zindex = Current;
                ACT.metric(idx).zindex = New;
            case 'movedown'
                % -------------------------------------------------------------
                % Find the trace that has a lower zindex and swap
                idxModality = find(strcmpi({ACT.metric.modality}, Metric(i).modality));
                zindex = [ACT.metric(idxModality).zindex];
                idxNew = find(zindex < Metric(i).zindex, 1, 'first');
                Current = Metric(i).zindex;
                New = zindex(idxNew);
                ACT.metric(idxModality(idxNew)).zindex = Current;
                ACT.metric(idx).zindex = New;
        end
    end
    % -------------------------------------------------------------------------
    % If the DisplaySettings (Modality) panel was passed, then update its
    % 'Metric' property so it is automatically updated
    if ~isempty(Obj)
        Subset = ACT.metric(strcmpi({ACT.metric.modality}, Metric(1).modality));
        % Sort by Z-index
        [~, idx] = sort([Subset.zindex], 'descend');
        Subset = Subset(idx);
        Obj.Metric = Subset;
    end
    % -------------------------------------------------------------------------
    % If the currenst status is saved, then change it to unsaved
    if strcmpi(ACT.status, 'saved')
        ACT.status = 'unsaved'; % 'saved', 'unsaved', 'neversaved', 'error'
    end
catch ME
    % ---------------------------------------------------------------------
    % Something went wrong, set status and error message
    ACT.status = 'error';
    ACT.etc.error = ME;
    printerrormessage(ME);
end
end