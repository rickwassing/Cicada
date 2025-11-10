function hoverObjs = findHoverableComponents(parent)
% Initialize empty array
hoverObjs = [];
% Loop over all children
children = parent.Components;
for k = 1:numel(children)
    c = children(k);

    for n = 1:length(c)
        flds = fieldnames(c(n));
        for f = 1:numel(flds)

            % Check the tag name
            if isprop(c.(flds{f}), 'Tag')
                if strcmp(c.(flds{f}).Tag, 'hoverable')
                    hoverObjs = [hoverObjs, c.(flds{f})]; %#ok<AGROW>
                end
            end

            % Recursively search children
            if isprop(c.(flds{f}), 'Components')
                if ~isempty(c.(flds{f}).Components)
                    hoverObjs = [hoverObjs, findHoverableComponents(c.(flds{f}))]; %#ok<AGROW>
                end
            end
        end
    end
end
end