function result = api_call(uri_str)
% Helper function to make simple get requests
import matlab.net.*
import matlab.net.http.*
import matlab.net.http.io.*
json_accept = matlab.net.http.MediaType('application/json');
acceptField = matlab.net.http.field.AcceptField([json_accept]);
header = [acceptField];
method = matlab.net.http.RequestMethod.GET;
request = matlab.net.http.RequestMessage(method,header);
resp = send(request,URI(uri_str));
result = resp.Body.Data;
end
