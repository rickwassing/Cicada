classdef Telemetry

    methods (Static)
        function post(eventType, payload)
            % -------------------------------------------------------------
            % Get handle to app
            app = app_gethandle();
            if ~isfield(app, 'Props')
                return
            end
            if ~isfield(app.Props, 'Settings')
                return
            end
            if ~isfield(app.Props.Settings, 'Auth')
                return
            end
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check if user gave permission to send data
            if ~strcmpi(eventType, 'auth') && ~strcmpi(app.Props.Settings.Auth.shareusagedata, 'yes')
                return;
            end
            % -------------------------------------------------------------
            % Predefined schema for all types of telemetry
            p = struct();
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Authentication
            p.auth = struct();
            p.auth.name = '';
            p.auth.institute = '';
            p.auth.email = '';
            p.auth.subscribe = 'no';
            p.auth.accept = 'no';
            p.auth.is_registered = 'no';
            p.auth.shareusagedata = 'no';
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Errors and warnings
            p.error.severity = '';
            p.error.message = '';
            p.error.stack = '';
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Sessions
            p.session.status = ''; % start or end
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Feature use
            p.feature_use.feature_name = ''; % e.g., 'import', 'open', 'select data'
            p.feature_use.file_id = '';
            p.feature_use.duration = '';

            % -------------------------------------------------------------
            % Insert the payload into the correct field
            p.(eventType) = mergestructs(p.(eventType), payload, 'ExistingOnly', true);

            % -------------------------------------------------------------
            % Compose telemetry data
            data = struct( ...
                'AppId', app.Props.Settings.App.Id, ...
                'SessionId', app.Props.Settings.App.SessionId, ...
                'CicadaVersion', app.Props.Settings.App.CicadaVersion, ...
                'MatlabVersion', app.Props.Settings.App.MatlabVersion, ...
                'SchemaVersion', '1.0', ...
                'SystemOS', app.Props.Settings.App.SystemOS, ...
                'SystemVersion', app.Props.Settings.App.SystemVersion, ...
                'EventType', eventType, ...
                'Payload', p, ...
                'datetime', datetime2iso([]) ...
            );
            % Convert to JSON
            jsonData = jsonencode(data);
            
            % API endpoint
            endpoint = 'https://default82c514c1a7174087be06d40d2070ad.52.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/7d6c317a55e9432c843a21f172302746/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Ri7GHT0vi1EY8x1qslVEYW_gptq1-Y04H1ZFNhuYdh8';

            % -------------------------------------------------------------
            % Send
            try
                fprintf('>> CIC: Sending telemetry data.\n');
                webwrite(endpoint, jsonData, weboptions('MediaType', 'application/json'));
            catch
                % Silently fail (never crash user’s workflow)
            end
        end
    end
end