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

            % Copy each public, non-transient, copyable property
            for i = 1:length(props)
                prop = props(i);
                % Only copy if: public access, not transient, not noncopyable
                if strcmp(prop.GetAccess, 'public') && ...
                        ~prop.Transient && ...
                        ~prop.NonCopyable
                    try
                        newObj.(prop.Name) = obj.(prop.Name);
                    catch
                        % Skip properties that can't be copied
                    end
                end
            end

            % Ensure visual update if the method exists
            if ismethod(newObj, 'update')
                newObj.update();
            end
        end

    end
end