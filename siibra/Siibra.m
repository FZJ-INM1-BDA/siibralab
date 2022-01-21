classdef Siibra
    properties(Constant)
        % Swagger documentation
        % https://siibra-api-latest.apps-dev.hbp.eu/v1_0/docs
        apiEndpoint = "https://siibra-api-latest.apps-dev.hbp.eu/v1_0/"
    end
    properties
        atlases
    end
    methods
        function siibra = Siibra()
            siibra.atlases = Atlas.empty;
            atlases_json = webread(Siibra.apiEndpoint + "atlases");
            for atlas_row = 1:numel(atlases_json)
                siibra.atlases(length(siibra.atlases) + 1) = Atlas(atlases_json(atlas_row));
            end

        end
    end
end