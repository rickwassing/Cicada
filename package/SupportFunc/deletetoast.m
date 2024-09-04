% DELETETOAST
% Deletes a 'Toast' object and its associated 'timer' object.
%
% See also TOAST, TIMER.

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

function deletetoast(Timer, ~, Obj)
% -------------------------------------------------------------------------
% Delete the toast object
if ~isempty(Obj)
    if isvalid(Obj)
        delete(Obj)
    end
end
% -------------------------------------------------------------------------
% Stop and delete the timer
stop(Timer)
delete(Timer)
end