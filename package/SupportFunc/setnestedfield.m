% SETNESTEDFIELDS
% [insert description]

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

function s = setnestedfield(s, fnames, val)
    % Navigate to the last field
    f = fnames{1};
    if isscalar(fnames)
        s.(f) = val;
    else
        if ~isfield(s, f) || ~isstruct(s.(f))
            s.(f) = struct();
        end
        s.(f) = setnestedfield(s.(f), fnames(2:end), val);
    end
end