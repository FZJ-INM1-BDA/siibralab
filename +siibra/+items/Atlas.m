classdef Atlas < handle
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
            spaces = siibra.items.Space.empty;
            spaces_json = webread(atlas_json.links.spaces.href);
            for space_row = 1:numel(spaces_json)
                space = siibra.items.Space(spaces_json(space_row), atlas.Id);
                spaces(end +1) = space;
            end
            atlas.Spaces = spaces;

            % Parcellations
            parcellations = siibra.items.Parcellation.empty;
            parcellations_json = webread(atlas_json.links.parcellations.href);
            for parcellation_row = 1:numel(parcellations_json)
                parcellation = siibra.items.Parcellation(parcellations_json(parcellation_row), atlas);
                parcellations(end +1) = parcellation;
            end
            atlas.Parcellations = parcellations;
            
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