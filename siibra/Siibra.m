classdef Siibra
    properties(Constant)
        % Swagger documentation
        % https://siibra-api-latest.apps-dev.hbp.eu/v1_0/docs
        apiEndpoint = "https://siibra-api-latest.apps-dev.hbp.eu/v1_0/"
    end
    methods (Static)
        function atlas = getAtlas(atlas_name_query)
            atlases = api_call(Siibra.apiEndpoint + "atlases");
            for atlas_row = 1:numel(atlases)
                if atlas_name_query == atlases(atlas_row).name
                    atlas = Atlas(atlases(atlas_row).id, atlases(atlas_row).name);
                    break
                end
            end
        end
    end
end