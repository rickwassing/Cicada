% MERGESTRUCTS
% Merge two structures. Fields in structure X overwrite or extend those in
% structure S. Existing fields in S that are not present in X are preserved.
%
% Usage:
%   s = mergestructs(s, x)
%
% Example:
%   s = struct('id', 'someid', 'name', 'myname', 'accepted', false);
%   x = struct('accepted', true, 'newfield', 123);
%   s = mergestructs(s, x);
%
% Result:
% >> s
%    s =
%      struct with fields:
%              id: 'someid'
%            name: 'myname'
%        accepted: 1
%        newfield: 123
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-07, Rick Wassing
%
% Cicada (C) 2025 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function s = mergestructs(s, x, varargin)

ExistingOnly = false;

for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'existingonly'
            ExistingOnly = varargin{i+1};
    end
end


% Validate inputs
if ~isstruct(s) || ~isstruct(x)
    error('Both inputs must be structures.');
end

% Get field names from x and copy them into s
fields = fieldnames(x);
for i = 1:numel(fields)
    if ExistingOnly && ~isfield(s, fields{i})
        continue
    else
        if ischar(x.(fields{i})) && length(x.(fields{i})) > 255
            s.(fields{i}) = x.(fields{i})(1:255);
        else
            s.(fields{i}) = x.(fields{i});
        end
    end
end
end