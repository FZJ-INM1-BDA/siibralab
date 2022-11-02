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
            atlas.Id = atlasJson.id;
            atlas.Name = atlasJson.name;

            % Spaces
            spacesJson = webread(atlasJson.links.spaces.href);
            atlas.Spaces = arrayfun(@(j) siibra.items.Space(j, atlas.Name), spacesJson);

            % Parcellations
            parcellationsJson = webread(atlasJson.links.parcellations.href);
            atlas.Parcellations = arrayfun(@(json) siibra.items.Parcellation(json, atlas), parcellationsJson);
            
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