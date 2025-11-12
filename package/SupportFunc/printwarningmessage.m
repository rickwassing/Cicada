% PRINTWARNINGMESSAGE
% Prints a warning message to the command window in yellow text.

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2024-12-04, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function printwarningmessage(ME, varargin)
fprintf('\n');
fprintf('* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n');
fprintf('Oops, a warning. "Just keep swimming." - Dory\n');
fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
fprintf('Warning message:\n');
fprintf(getReport(ME));
fprintf('\n');
if nargin > 1
    fprintf('\n');
    for i = 1:length(varargin)
        fprintf('%s\n', varargin{i})
    end
end
fprintf('* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n');
fprintf('\n');

% Send telemetry data
p = struct();
p.severity = 'warning';
p.message = ME.message;
p.stack = cleanErrorReport(getReport(ME, 'extended', 'hyperlinks', 'off'));

Telemetry.post('error', p)

end