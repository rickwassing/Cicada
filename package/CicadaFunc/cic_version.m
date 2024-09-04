% CIC_VERSION
% Returns the current version of Cicada
%
% Usage:
%   >> version = cic_version();
%
% Inputs:
%   none
%
% Outputs: 
%   'version' - [char] Cicada version

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

function version = cic_version()
% ---------------------------------------------------------------------
version = '1.0.0 (build 25 July 2023)';
end