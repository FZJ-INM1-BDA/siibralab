classdef Atlas < handle
    %ATLAS The atlas holds the available parcellations and spaces
    properties
        Id (1, 1) string
        Name (1, 1) string
        Parcellations (1, :) siibra.items.Parcellation
        Spaces (1, :) siibra.items.Space
    end
    methods
        function atlas = Atlas(atlasJson)
            atlas.Id = atlasJson.x_id;
            atlas.Name = atlasJson.name;

            % Spaces
            atlas.Spaces = arrayfun(@(spaceRef) siibra.items.Space(siibra.internal.API.space(spaceRef.x_id), atlas.Name), atlasJson.spaces);

            % Parcellations
            atlas.Parcellations = arrayfun(@(parcellationRef) siibra.items.Parcellation(siibra.internal.API.parcellation(parcellationRef.x_id), atlas), atlasJson.parcellations);
            
        end
        function parcellation = getParcellation(obj, parcellationNameQuery)
            arguments
                obj 
                parcellationNameQuery (1, 1) string
            end
            parcellationNames = [obj.Parcellations.Name];
            parcellation = obj.Parcellations(siibra.internal.fuzzyMatching(parcellationNameQuery, parcellationNames));
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