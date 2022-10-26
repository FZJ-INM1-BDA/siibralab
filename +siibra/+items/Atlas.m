classdef Atlas < handle
    %ATLAS The atlas holds the available parcellations and spaces
    properties
        Id (1, 1) string
        Name (1, 1) string
        Parcellations (1, :) siibra.items.Parcellation
        Spaces (1, :) siibra.items.Space
    end
    methods
        function atlas = Atlas(atlas_json)
            atlas.Id = atlas_json.id;
            atlas.Name = atlas_json.name;

            % Spaces
            spaces_json = webread(atlas_json.links.spaces.href);
            atlas.Spaces = arrayfun(@(j) siibra.items.Space(j, atlas.Name), spaces_json);

            % Parcellations
            parcellations_json = webread(atlas_json.links.parcellations.href);
            atlas.Parcellations = arrayfun(@(json) siibra.items.Parcellation(json, atlas), parcellations_json);
            
        end
        function parcellation = getParcellation(obj, parcellation_name_query)
            arguments
                obj 
                parcellation_name_query (1, 1) string
            end
            parcellationNames = [obj.Parcellations.Name];
            parcellation = obj.Parcellations(siibra.internal.fuzzyMatching(parcellation_name_query, parcellationNames));
        end
        function space = getSpace(obj, spaceName)
            arguments
                obj
                spaceName (1, 1) string
            end
            spaceNames = [obj.Spaces.Name];
            space = obj.Spaces(siibra.internal.fuzzyMatching(spaceName, spaceNames));
        end
    end
end