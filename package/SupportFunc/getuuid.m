% Create unique identifier
function id = getuuid(varargin)

if nargin > 0
    if strcmpi(varargin{1}, 'full')
        id = char(matlab.lang.internal.uuid());
        return
    end
end

id = char(matlab.lang.internal.uuid());
id = id(1:8);
end