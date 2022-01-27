classdef Atlas
    properties
        Id
        Name
        Parcellations
        Spaces
    end
    methods
        function atlas = Atlas(atlas_json)
            atlas.Id = atlas_json.id;
            atlas.Name = atlas_json.name;
            atlas.Parcellations = Parcellation.empty;
            parcellations_json = webread(atlas_json.links.parcellations.href);
            for parcellation_row = 1:numel(parcellations_json)
                atlas.Parcellations(length(atlas.Parcellations) + 1) = Parcellation(parcellations_json(parcellation_row), atlas.Id);
            end
            % spaces_json = webread(atlas_json.links.spaces.href);

        end
        function parcellation = getParcellation(obj, parcellation_name_query)
            for percellation_row = 1:numel(obj.Parcellations)
                if parcellation_name_query == obj.Parcellations(percellation_row).name
                    parcellation = obj.Parcellations(percellation_row);
                    break
                end
            end
        end
    end
end