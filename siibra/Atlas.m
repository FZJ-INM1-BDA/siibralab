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

            % Parcellations
            parcellations = Parcellation.empty;
            parcellations_json = webread(atlas_json.links.parcellations.href);
            for parcellation_row = 1:numel(parcellations_json)
                parcellation = Parcellation(parcellations_json(parcellation_row), atlas.Id);
                parcellations(end +1) = parcellation;
            end
            atlas.Parcellations = table(string({parcellations.Name}).', parcellations.', 'VariableNames', {'Name', 'Parcellation'});
            
            % Spaces
            spaces = Space.empty;
            spaces_json = webread(atlas_json.links.spaces.href);
            for space_row = 1:numel(spaces_json)
                space = Space(spaces_json(space_row), atlas.Id);
                spaces(end +1) = space;
            end
            atlas.Spaces = table(string({spaces.Name}).', spaces.', 'VariableNames', {'Name', 'Space'});
        end
        function parcellation = getParcellation(obj, parcellation_name_query)
            for percellation_row = 1:numel(obj.Parcellations)
                if parcellation_name_query == obj.Parcellations.Name(percellation_row)
                    parcellation = obj.Parcellations.Parcellation(percellation_row);
                    break
                end
            end
        end
    end
end