% DETECTOPERATINGSYSTEM
% Name and version number of the operating system.
%   OS = DETECTOS returns the name of the operating system as one of the
%   following character vectors: 'windows', 'macos' (which includes OS X),
%   'solaris', 'aix', or another Unix/Linux distro in all lowercase
%   characters (such as 'ubuntu' or 'centos'). An error is thrown if the
%   operating system cannot be determined.
%
%   [~, OSVERSION] = DETECTOS returns the operating system version number
%   as a numeric row vector. For example, version 6.1.7601 is reported as
%   OSVERSION = [6, 1, 7601]. If the OS version cannot be determined, a
%   warning is issued and the empty numeric array is returned.
%
%See also COMPUTER, ISMAC, ISPC, ISUNIX.
% Created 2016-01-05 by Jorg C. Woehl
% 2016-10-10 (JCW): Converted to standalone function, comments added (v1.0.1).
% 2018-04-20 (JCW): Used the recommended “replace” instead of “strrep”.
% 2021-04-22 (JCW): Version information added (v1.1).
% 2024-05-13 (JCW): Updated comments.
% 2025-11-07 (Rick Wassing): Edits made so the function does not throw any errors, but returns 'unknown' and [] if detection fails

function [OS, OSVersion] = detectoperatingsystem()

% Wrap entire function in try-catch to ensure no errors are thrown
try
    if ismac
        % Mac
        % See https://support.apple.com/en-us/HT201260 for version numbers
        OS = 'macos';
        [status, OSVersion] = system('sw_vers -productVersion');
        if (status ~= 0)
            OSVersion = 'unknown';
        else
            OSVersion = strtrim(OSVersion);
            if isempty(OSVersion)
                OSVersion = 'unknown';
            end
        end
    elseif ispc
        % Windows
        % See https://en.wikipedia.org/wiki/Ver_(command) for version numbers
        OS = 'windows';
        [status, OSVersion] = system('ver');
        if (status ~= 0)
            OSVersion = 'unknown';
        else
            OSVersion = regexp(OSVersion, '\d[.\d]*', 'match');
            if isempty(OSVersion)
                OSVersion = 'unknown';
            end
        end
    elseif isunix
        % Unix/Linux
        % Inspired in part by
        %   http://linuxmafia.com/faq/Admin/release-files.html and
        %   http://unix.stackexchange.com/questions/92199/how-can-i-reliably-get-the-operating-systems-name/92218#92218
        [status, OS] = system('uname -s'); % Results in 'SunOS', 'AIX', or 'Linux'
        OS = strtrim(OS);
        if ~(status == 0) || isempty(OS)
            % Unable to determine Unix distribution
            OS = 'unix';
            OSVersion = 'unknown';
        elseif strcmpi(OS, 'SunOS')
            OS = 'solaris';
            [status, OSVersion] = system('uname -v');
            if (status ~= 0)
                OSVersion = 'unknown';
            else
                OSVersion = regexp(OSVersion, '\d[.\d]*', 'match');
                if isempty(OSVersion)
                    OSVersion = 'unknown';
                end
            end
        elseif strcmpi(OS, 'AIX')
            OS = 'aix';
            [status, OSVersion] = system('oslevel');
            if (status ~= 0)
                OSVersion = 'unknown';
            else
                OSVersion = regexp(OSVersion, '\d[.\d]*', 'match');
                if isempty(OSVersion)
                    OSVersion = 'unknown';
                end
            end
        elseif strcmpi(OS, 'Linux')
            OS = '';
            OSVersion = '';
            % First check if /etc/os-release exists and read it
            [status, result] = system('cat /etc/os-release');
            if (status == 0)
                % Add newline to beginning and end of output character vector (makes parsing easier)
                result = sprintf('\n%s\n', result);
                % Determine OS
                OS = regexpi(result, '(?<=\nID=).*?(?=\n)', 'match'); % ID=... (shortest match)
                if isempty(OS)
                    OS = '';
                else
                    % Extract first match and process it
                    if iscell(OS)
                        OS = OS{1};
                    end
                    OS = lower(strtrim(replace(OS, '"', ''))); % Remove quotes, leading/trailing spaces, and make lowercase
                end
                % Determine OS version
                OSVersion = regexpi(result, '(?<=\nVERSION_ID=)"*\d[.\d]*"*(?=\n)', 'match'); % VERSION_ID=... (longest match)
                if iscell(OSVersion)
                    OSVersion = OSVersion{1};
                end
                OSVersion = replace(OSVersion, '"', '');                % Remove quotes
            else
                % Check for output from lsb_release (more standardized than /etc/lsb-release itself)
                [status, result] = system('lsb_release -a');
                if (status == 0)
                    % Add newline to beginning and end of output character vector (makes parsing easier)
                    result = sprintf('\n%s\n', result);
                    % Determine OS
                    OS = regexpi(result, '(?<=\nDistributor ID:\t).*?(?=\n)', 'match'); % Distributor ID: ... (shortest match)
                    if isempty(OS)
                        OS = '';
                    else
                        % Extract first match and process it
                        if iscell(OS)
                            OS = OS{1};
                        end
                        OS = lower(strtrim(OS)); % Remove leading/trailing spaces, and convert to lowercase
                    end
                    % Determine OS version
                    OSVersion = regexpi(result, '(?<=\nRelease:\t)\d[.\d]*(?=\n)', 'match'); % Release: ... (longest match)
                    if iscell(OSVersion)
                        OSVersion = OSVersion{1};
                    end
                else
                    % Extract information from /etc/*release or /etc/*version filename
                    [status, result] = system('ls -m /etc/*version'); % Comma-delimited file listing
                    fileListStr = '';
                    if (status == 0)
                        fileListStr = result;
                    end
                    [status, result] = system('ls -m /etc/*release'); % Comma-delimited file listing
                    if (status == 0)
                        if ~isempty(fileListStr)
                            fileListStr = [fileListStr ', ' result];
                        else
                            fileListStr = result;
                        end
                    end
                    % Convert to cell array of file paths
                    fileListStr = replace(fileListStr, ',', ' ');
                    fileListStr = strtrim(fileListStr);
                    fileList = strtrim(strsplit(fileListStr));
                    % Find the first file that's different from 'os', 'lsb', 'system', or 'debian'/'redhat' (unless it's the only one)
                    OS = '';
                    OSFile = '';
                    for ii = 1:numel(fileList)
                        % Extract OS name from file path
                        osName = regexpi(fileList{ii}, '(?<=/etc/).*?(?=[-_][rv])', 'match');
                        if isempty(osName)
                            continue;
                        end
                        if iscell(osName)
                            osName = osName{1};
                        end
                        % Check if this is a good candidate
                        if ~(strcmpi(osName, 'os') || strcmpi(osName, 'lsb') || strcmpi(osName, 'system') || ...
                                isempty(osName) || strcmpi(osName, 'redhat') || strcmpi(osName, 'debian'))
                            OS = osName;
                            OSFile = fileList{ii};
                            break;
                        elseif (strcmpi(osName, 'redhat') || strcmpi(osName, 'debian'))
                            % Assign temporarily as fallback, but keep searching
                            if isempty(OS)
                                OS = osName;
                                OSFile = fileList{ii};
                            end
                        end
                    end
                    % Determine OS version
                    if ~isempty(OSFile)
                        [status, OSVersion] = system(['cat ' OSFile]);
                        if (status == 0)
                            OSVersion = regexp(OSVersion, '\d[.\d]*', 'match');
                            if iscell(OSVersion)
                                OSVersion = OSVersion{1};
                            end
                        else
                            OSVersion = '';
                        end
                    end
                end
            end
            if isempty(OS)
                % Unable to determine Linux distribution
                OS = 'unix';
            end
            if isempty(OSVersion)
                OSVersion = 'unknown';
            end
        else
            % Unknown Unix distribution
            OS = 'unix';
            OSVersion = 'unknown';
        end
    else
        % Platform not found
        OS = 'unknown';
        OSVersion = 'unknown';
    end
    % Ensure OSVersion is always a character array
    if iscell(OSVersion)
        % Check if cell array is empty
        if isempty(OSVersion)
            OSVersion = 'unknown';
        else
            % Convert cell to character vector
            OSVersion = OSVersion{1};
            if isempty(OSVersion)
                OSVersion = 'unknown';
            end
        end
    end
    if ~ischar(OSVersion)
        % Convert anything else to character array
        try
            OSVersion = char(OSVersion);
        catch
            OSVersion = 'unknown';
        end
    end

catch ME
    % If anything goes wrong, return safe defaults
    OS = 'unknown';
    OSVersion = 'unknown';
end
end
