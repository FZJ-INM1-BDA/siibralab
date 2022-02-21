classdef Siibra < handle
    properties(Constant)
        % Swagger documentation
        % https://siibra-api-latest.apps-dev.hbp.eu/v1_0/docs
        apiEndpoint = "https://siibra-api-latest.apps-dev.hbp.eu/v1_0/"
    end
    properties
        Atlases
    end
    methods
        function siibra = Siibra()
            atlases_json = webread(Siibra.apiEndpoint + "atlases");
            atlases = Atlas.empty;
            for atlas_row = 1:numel(atlases_json)
                atlas = Atlas(atlases_json(atlas_row));
                atlases(end + 1) = atlas;
            end
            siibra.Atlases = table({atlases.Name}.', atlases.', 'VariableNames', {'Name', 'Atlas'});

        end
        function parcellations = Parcellations(obj)
            parcellations = table;
            for i = 1:numel(obj.Atlases.Atlas)
                atlas = obj.Atlases.Atlas(i);
                parcellations = [parcellations; atlas.Parcellations];
            end
            %parcellations = unique(parcellations);
        end
        function spaces = Spaces(obj)
            spaces = table;
            for i = 1:numel(obj.Atlases.Atlas)
                atlas = obj.Atlases.Atlas(i);
                spaces = [spaces; atlas.Spaces];
            end
        end
        function atlas = getAtlas(obj, atlas_query)
            atlas_names = lower(obj.Atlases.Name.');
            difflib = py.importlib.import_module('difflib');
            python_matched_names = difflib.get_close_matches(atlas_query, atlas_names, py.int(1), 0.3);
            matched_names = cellfun(@char,cell(python_matched_names),'UniformOutput',false);
            if isempty(matched_names)
                error ("Cannot find atlas for query " + atlas_query);
            end
            atlas = obj.Atlases.Atlas(find(ismember(atlas_names, matched_names{1})));
        end
    end
end