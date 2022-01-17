classdef Atlas
    properties
        id
        name
    end
    methods
        function atlas = Atlas(id, name)
            atlas.id = id;
            atlas.name = name;
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