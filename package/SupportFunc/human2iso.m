% HUMAN2ISO
% Convert a human-typed date string into ISO format (YYYY-MM-DD). It tries
% multiple date formats and returns an ISO string. Throws an error if none
% of the formats match.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-14, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function iso = human2iso(dstr)
% Input validation
if isempty(dstr) || (isstring(dstr) && strlength(dstr) == 0) || (ischar(dstr) && isempty(strtrim(dstr)))
    iso = '';
    return;
end
if ~ischar(dstr) && ~isstring(dstr)
    error('Input must be a char or string, got %s', class(dstr));
end
if isstring(dstr)
    dstr = char(dstr);
end
dstr = strtrim(dstr);

% List of accepted formats (extend as needed)
fmts = getdateformats();
dt = [];
% Try parsing with original casing first, then lowercase
dstrVariants = {dstr, lower(dstr)};
for v = 1:numel(dstrVariants)
    for i = 1:numel(fmts)
        try %#ok<TRYNC>
            dt = datetime(dstrVariants{v}, 'InputFormat', fmts{i});
            break;
        end
    end
    if ~isempty(dt)
        break;
    end
end
% As a fallback, try MATLAB's flexible parser
if isempty(dt)
    try
        dt = datetime(dstr);
    catch
        try
            dt = datetime(lower(dstr));
        catch
            error("Cannot parse date string: '%s'", dstr);
        end
    end
end
% Fix two-digit years: assume years < 1950 should be in 2000s
% (e.g., '25' -> 2025, not 1925)
if dt.Year < 1950
    dt.Year = dt.Year + 100;
end
% Output ISO format
iso = char(dt, 'yyyy-MM-dd');

    function fmts = getdateformats()
        fmts = {
            'dd MMMM yyyy'
            'd MMMM yyyy'
            'dd MMM yyyy'
            'd MMM yyyy'
            'dd MM yyyy'
            'd MM yyyy'
            'dd M yyyy'
            'd M yyyy'
            'dd/MMMM/yyyy'
            'd/MMMM/yyyy'
            'dd/MMM/yyyy'
            'd/MMM/yyyy'
            'dd/MM/yyyy'
            'd/MM/yyyy'
            'dd/M/yyyy'
            'd/M/yyyy'
            'dd-MMMM-yyyy'
            'd-MMMM-yyyy'
            'dd-MMM-yyyy'
            'd-MMM-yyyy'
            'dd-MM-yyyy'
            'd-MM-yyyy'
            'dd-M-yyyy'
            'd-M-yyyy'
            'dd MMMM yy'
            'd MMMM yy'
            'dd MMM yy'
            'd MMM yy'
            'dd MM yy'
            'd MM yy'
            'dd M yy'
            'd M yy'
            'dd/MMMM/yy'
            'd/MMMM/yy'
            'dd/MMM/yy'
            'd/MMM/yy'
            'dd/MM/yy'
            'd/MM/yy'
            'dd/M/yy'
            'd/M/yy'
            'dd-MMMM-yy'
            'd-MMMM-yy'
            'dd-MMM-yy'
            'd-MMM-yy'
            'dd-MM-yy'
            'd-MM-yy'
            'dd-M-yy'
            'd-M-yy'
            'MMMM dd yyyy'
            'MMMM d yyyy'
            'MMM dd yyyy'
            'MMM d yyyy'
            'MM dd yyyy'
            'MM d yyyy'
            'M dd yyyy'
            'M d yyyy'
            'MMMM/dd/yyyy'
            'MMMM/d/yyyy'
            'MMM/dd/yyyy'
            'MMM/d/yyyy'
            'MM/dd/yyyy'
            'MM/d/yyyy'
            'M/dd/yyyy'
            'M/d/yyyy'
            'MMMM-dd-yyyy'
            'MMMM-d-yyyy'
            'MMM-dd-yyyy'
            'MMM-d-yyyy'
            'MM-dd-yyyy'
            'MM-d-yyyy'
            'M-dd-yyyy'
            'M-d-yyyy'
            'MMMM dd yy'
            'MMMM d yy'
            'MMM dd yy'
            'MMM d yy'
            'MM dd yy'
            'MM d yy'
            'M dd yy'
            'M d yy'
            'MMMM/dd/yy'
            'MMMM/d/yy'
            'MMM/dd/yy'
            'MMM/d/yy'
            'MM/dd/yy'
            'MM/d/yy'
            'M/dd/yy'
            'M/d/yy'
            'MMMM-dd-yy'
            'MMMM-d-yy'
            'MMM-dd-yy'
            'MMM-d-yy'
            'MM-dd-yy'
            'MM-d-yy'
            'M-dd-yy'
            'M-d-yy'
            'dd.MMMM.yyyy'
            'd.MMMM.yyyy'
            'dd.MMM.yyyy'
            'd.MMM.yyyy'
            'dd.MM.yyyy'
            'd.MM.yyyy'
            'dd.M.yyyy'
            'd.M.yyyy'
            'dd.MMMM.yy'
            'd.MMMM.yy'
            'dd.MMM.yy'
            'd.MMM.yy'
            'dd.MM.yy'
            'd.MM.yy'
            'dd.M.yy'
            'd.M.yy'
            'MMMM.dd.yyyy'
            'MMMM.d.yyyy'
            'MMM.dd.yyyy'
            'MMM.d.yyyy'
            'MM.dd.yyyy'
            'MM.d.yyyy'
            'M.dd.yyyy'
            'M.d.yyyy'
            'MMMM.dd.yy'
            'MMMM.d.yy'
            'MMM.dd.yy'
            'MMM.d.yy'
            'MM.dd.yy'
            'MM.d.yy'
            'M.dd.yy'
            'M.d.yy'
            'yyyy MMMM dd'
            'yyyy MMMM d'
            'yyyy MMM dd'
            'yyyy MMM d'
            'yyyy MM dd'
            'yyyy MM d'
            'yyyy M dd'
            'yyyy M d'
            'yyyy/MMMM/dd'
            'yyyy/MMMM/d'
            'yyyy/MMM/dd'
            'yyyy/MMM/d'
            'yyyy/MM/dd'
            'yyyy/MM/d'
            'yyyy/M/dd'
            'yyyy/M/d'
            'yyyy-MMMM-dd'
            'yyyy-MMMM-d'
            'yyyy-MMM-dd'
            'yyyy-MMM-d'
            'yyyy-MM-dd'
            'yyyy-MM-d'
            'yyyy-M-dd'
            'yyyy-M-d'
            'yyyy.MMMM.dd'
            'yyyy.MMMM.d'
            'yyyy.MMM.dd'
            'yyyy.MMM.d'
            'yyyy.MM.dd'
            'yyyy.MM.d'
            'yyyy.M.dd'
            'yyyy.M.d'
            'yy MMMM dd'
            'yy MMMM d'
            'yy MMM dd'
            'yy MMM d'
            'yy MM dd'
            'yy MM d'
            'yy M dd'
            'yy M d'
            'yy/MMMM/dd'
            'yy/MMMM/d'
            'yy/MMM/dd'
            'yy/MMM/d'
            'yy/MM/dd'
            'yy/MM/d'
            'yy/M/dd'
            'yy/M/d'
            'yy-MMMM-dd'
            'yy-MMMM-d'
            'yy-MMM-dd'
            'yy-MMM-d'
            'yy-MM-dd'
            'yy-MM-d'
            'yy-M-dd'
            'yy-M-d'
            'yy.MMMM.dd'
            'yy.MMMM.d'
            'yy.MMM.dd'
            'yy.MMM.d'
            'yy.MM.dd'
            'yy.MM.d'
            'yy.M.dd'
            'yy.M.d'
            'ddMMyyyy'
            'ddMMyy'
            'MMddyyyy'
            'MMddyy'
            'yyyyMMdd'
            'yyMMdd'
            'yyyy-MM-dd HH:mm:ss'
            'yyyy/MM/dd HH:mm:ss'
            'yyyy.MM.dd HH:mm:ss'
            'yyyy MM dd HH:mm:ss'
            };
    end
end