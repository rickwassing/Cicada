% CICADACOMPONENTCONTAINER
% Custom Component Container to inherit common methods

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-07, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

classdef CicadaComponentContainer < matlab.ui.componentcontainer.ComponentContainer
    % *********************************************************************
    % PROPERTIES
    properties
        Verbose double = 0; % 0=off, 1=summary, 2-3=log+summary
    end
    % *********************************************************************
    % METHODS
    methods (Access = protected)
        % =================================================================
        function startPerformanceTracking(Obj)
            % Start tracking component update performance
            if Obj.Verbose > 0
                tracker = PerformanceTracker.getInstance();
                tracker.startTracking(class(Obj), Obj.Verbose);
            end
        end
        
        % =================================================================
        function endPerformanceTracking(Obj)
            % End tracking component update performance
            if Obj.Verbose > 0
                tracker = PerformanceTracker.getInstance();
                tracker.endTracking(class(Obj), Obj.Verbose);
            end
        end
    end
    
    methods (Access = public)
        % =================================================================
        function newObj = deepCopy(obj, parent)
            % Get the class name dynamically
            className = class(obj);

            % Create a new instance using dynamic constructor
            newObj = feval(className, parent);

            % Get all properties of the object
            mc = metaclass(obj);
            props = mc.PropertyList;

            % Copy each property
            for i = 1:length(props)
                prop = props(i);
                
                % Skip if not public access
                if ~strcmp(prop.GetAccess, 'public')
                    continue;
                end
                
                try
                    propValue = obj.(prop.Name);
                    
                    % SPECIAL CASE: CicadaComponentContainer children
                    % These should ALWAYS be deep copied to avoid shallow copy issues
                    % regardless of Transient/NonCopyable attributes
                    if isa(propValue, 'CicadaComponentContainer')
                        % Handle arrays of components
                        if numel(propValue) > 1
                            copiedArray = [];
                            for j = 1:length(propValue)
                                if isvalid(propValue(j))
                                    childParent = newObj.getChildParent(prop.Name);
                                    copiedArray(j) = propValue(j).deepCopy(childParent);
                                end
                            end
                            newObj.(prop.Name) = copiedArray;
                        else
                            % Single component
                            if ~isempty(propValue) && isvalid(propValue)
                                childParent = newObj.getChildParent(prop.Name);
                                newObj.(prop.Name) = propValue.deepCopy(childParent);
                            end
                        end
                        
                    % REGULAR PROPERTIES: Apply Transient/NonCopyable rules
                    elseif ~prop.Transient && ~prop.NonCopyable
                        fprintf('>> CIC: Copying property ''%s''.\n', prop.Name);
                        newObj.(prop.Name) = propValue;
                    end
                    
                catch ME
                    % Skip properties that can't be copied
                end
            end

            % Ensure visual update if the method exists
            if ismethod(newObj, 'update')
                newObj.update();
            end
        end
        
        % =================================================================
        function childParent = getChildParent(obj, propName) %#ok<INUSD>
            % Helper method to determine parent for child components
            % By default, use GridLayout if it exists, otherwise Panel, otherwise the component itself
            % Subclasses can override this for custom behavior
            if isprop(obj, 'GridLayout') && ~isempty(obj.GridLayout)
                childParent = obj.GridLayout;
            elseif isprop(obj, 'Panel') && ~isempty(obj.Panel)
                childParent = obj.Panel;
            else
                childParent = obj;
            end
        end

    end
end
