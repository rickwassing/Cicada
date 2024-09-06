% APP_ASCIILOGO
% Displays the ASCII logo of Cicada in the Command Window along with
% information about the version, authors, acknowledgements, and license.
%
% Usage:
%   >> app_asciilogo();
%
% Inputs:
%   none
%
% Outputs: 
%   none
%
% See also DISP.

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

function app_asciilogo()

disp('     ___  ____  ___    __    ____    __   ')
disp('    / __)(_  _)/ __)  /__\  (  _ \  /__\  ')
disp('   ( (__  _)(_( (__  /(__)\  )(_) )/(__)\ ')
disp('    \___)(____)\___)(__)(__)(____/(__)(__)')
disp(' ')
disp('For analysing actigraphy and other wearable data')
disp(' ')
disp(['Version: ', cic_version()])
disp(' ')
disp('Authors:')
disp('   Rick Wassing, rick.wassing@woolcock.org.au')
disp(' ')
disp('Acknowledgements:')
disp('   Vincent T. van Hees, Maxim Osipov, Bart Te Lindert,')
disp('   German Gómez-Herrero, Yorgi Mavros, and Hyatt Moore.')
disp(' ')
disp('License:')
disp('   Cicada (C) 2023 by Rick Wassing is licensed under Attribution-')
disp('   NonCommercial-ShareAlike 4.0 International License.')
disp(' ')

end