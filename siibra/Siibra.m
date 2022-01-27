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
            atlases_json = webread(Siibra.apiEndpoint + "atlases");
            atlases = Atlas.empty;
            for atlas_row = 1:numel(atlases_json)
                atlas = Atlas(atlases_json(atlas_row));
                atlases(end + 1) = atlas;
            end
            siibra.atlases = table({atlases.Name}.', atlases.', 'VariableNames', {'Name', 'Atlas'});

        end
    end
end