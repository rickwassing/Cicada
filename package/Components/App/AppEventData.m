% APPEVENTDATA
% Extends the 'AppEventData' class to include the field 'UserData'.

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

classdef (ConstructOnLoad) AppEventData < event.EventData
    % *********************************************************************
    % PROPERTIES
    properties
        UserData
    end
    % *********************************************************************
    % METHODS
    methods
        function data = AppEventData(event, varargin)
            data.UserData.Source = event.Source;
            data.UserData.EventName = event.EventName;
            data.UserData.Payload = varargin{1};
        end
    end
end