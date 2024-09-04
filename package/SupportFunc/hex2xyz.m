% HEX2XYZ
% Converts hexadecimal values from the GeneActiv watch to XYZ accelerometry
% data, light intensity data, and button presses.

% Authors:
%   German Gomez-Herrero, FindHotel, Amsterdam, The Netherlands
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created a long time ago, German Gomez-Herrero

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function [xyz, light, button] = hex2xyz(hstr)
% Hexadecimal to decimal conversion of data values
n_bytes = floor(numel(hstr)/2);
n_meas = floor(n_bytes/6);
hstr = reshape(hstr(1:n_bytes*2), 2, n_bytes)';
bin_values = dec2bin(hex2dec(hstr))';
bin_values = reshape(bin_values, 1, n_bytes*8);
idx = repmat((1:48:48*n_meas)', 1, 12) + repmat(0:11, n_meas, 1);
x = tc2dec(bin_values(idx),12);
y = tc2dec(bin_values(idx+12),12);
z = tc2dec(bin_values(idx+24),12);
idx = repmat((37:48:48*n_meas)', 1, 10) + repmat(0:9, n_meas, 1);
light = bin2dec(bin_values(idx));
button = bin_values((47:48:48*n_meas)')=='1';
f = bin_values((48:48:48*n_meas)')=='1';
if any(f)
    error('The (f) field is not zero!');
end
xyz = [x(:),y(:),z(:)];
button = button(:);
light = light(:);

    function value = tc2dec(bin,N)
    % Two-complement to decimal conversion
    val = bin2dec(bin);
    s = sign(2^(N-1)-val).*(2^(N-1)-abs(2^(N-1)-val));
    value = s;
    condition = (s == 0 & val ~= 0);
    value(condition) = -val(condition);
    end
end