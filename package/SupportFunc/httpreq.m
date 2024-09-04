% HTTPREQ
% Sends an HTTP request to Microsoft Flow to subscribe the user.
%
% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2024-09-03, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function [req, resp, status] = httpreq(MSFlowURI, varargin)
import matlab.net.*
import matlab.net.http.*
dataStruct = struct();
for i = 1:2:length(varargin)
    dataStruct.(lower(varargin{i})) = varargin{i+1};
end
% Create the message body from the JSON data
body = matlab.net.http.MessageBody(dataStruct);
% Set the content type to 'application/json'
contentType = matlab.net.http.field.ContentTypeField('application/json');
% Create an Accept field (optional, but good practice)
acceptField = matlab.net.http.field.AcceptField('application/json');
% Combine the headers
header = [contentType, acceptField];
% Set the request method to POST
method = matlab.net.http.RequestMethod.POST;
% Construct the request message with the method, header, and body
req = matlab.net.http.RequestMessage(method, header, body);
% Define the URI of the Power Automate Flow
uri = matlab.net.URI(MSFlowURI);
% Send the request and get the response
resp = send(req, uri);
% Check the status code of the response
status = resp.StatusCode;

end