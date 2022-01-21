classdef Atlas
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
            atlas.parcellations = Parcellation.empty;
            parcellations_json = webread(atlas_json.links.parcellations.href);
            for parcellation_row = 1:numel(parcellations_json)
                atlas.parcellations(length(atlas.parcellations) + 1) = Parcellation(parcellations_json(parcellation_row), atlas.id);
            end


        end
        function parcellation = getParcellation(obj, parcellation_name_query)
            parcellations = webread(Siibra.apiEndpoint + "atlases/" + obj.id + "/parcellations");
            for percellation_row = 1:numel(parcellations)
                if parcellation_name_query == parcellations(percellation_row).name
                    parcellation = Parcellation(parcellations(percellation_row).id, parcellations(percellation_row).name, obj.id);
                    break
                end
            end
        end
    end
end