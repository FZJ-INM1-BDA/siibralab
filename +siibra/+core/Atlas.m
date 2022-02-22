classdef Atlas < handle
    properties
        id
        name
        parcellations
        spaces
    end
    methods
        function atlas = Atlas(atlas_json)
            atlas.id = atlas_json.id;
            atlas.name = atlas_json.name;

            % Spaces
            spaces = siibra.core.Space.empty;
            spaces_json = webread(atlas_json.links.spaces.href);
            for space_row = 1:numel(spaces_json)
                space = siibra.core.Space(spaces_json(space_row), atlas.id);
                spaces(end +1) = space;
            end
            atlas.spaces = spaces;

            % Parcellations
            parcellations = siibra.core.Parcellation.empty;
            parcellations_json = webread(atlas_json.links.parcellations.href);
            for parcellation_row = 1:numel(parcellations_json)
                parcellation = siibra.core.Parcellation(parcellations_json(parcellation_row), atlas);
                parcellations(end +1) = parcellation;
            end
            atlas.parcellations = parcellations;
            
        end
        function parcellation = parcellation(obj, parcellation_name_query)
            parcellationNames = {obj.parcellations.name};
            parcellation = obj.parcellations(siibra.internal.fuzzyMatching(parcellation_name_query, parcellationNames));
        end
    end
end