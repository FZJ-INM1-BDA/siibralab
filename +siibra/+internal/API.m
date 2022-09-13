classdef API
    % The API class holds all the api calls in one place
    
    properties (Constant=true)
        Endpoint = "https://siibra-api-stable.apps.hbp.eu/v1_0/"
    end

    methods (Static)
        function link = absoluteLink(relativeLink)
            link = siibra.internal.API.Endpoint + relativeLink;
        end
        function result = doWebreadWithLongTimeout(link)
            options = weboptions;
            options.Timeout = 30;
            result = webread(link);
        end
        function atlases = atlases()
            link = siibra.internal.API.absoluteLink("atlases");
            atlases = siibra.internal.API.doWebreadWithLongTimeout(link);
        end
    end
    
end

