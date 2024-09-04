% DEFAULTCOLORMAP
% Applies a default colormap to the metric data structure

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

function metric = defaultcolormap(metric)
% -------------------------------------------------------------------------
Colors = app_colors(); %#ok<NASGU>
% -------------------------------------------------------------------------
modalities = unique({metric.modality});
for i = 1:length(modalities)
    switch modalities{i}
        case 'accel'
            cname = 'teal';
        case 'light'
            cname = 'orange';
        case 'thermo'
            cname = 'violet';
        otherwise
    end
    idxList = find(strcmpi({metric.modality}, modalities{i}));
    for j = 1:length(idxList)
        clr = eval(sprintf('Colors.lab_%s_%i', cname, mod(j-1, 3)+1));
        metric(idxList(j)).color = clr;
    end
end

end