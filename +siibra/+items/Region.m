classdef Region < handle
    properties
        Name string
        Parcellation (1, :) siibra.items.Parcellation
        ProbabilityMaps (1, :) siibra.items.ProbabilityMap
        Spaces (1, :) siibra.items.Space
        Parent (1, 1) % Region
        Children (1, :) % Region
    end
    methods
        function region = Region(name, parcellation, dataset_specs)
            region.Name = name;
            region.Parcellation = parcellation;

            probabilityMaps = siibra.items.ProbabilityMap.empty;

            % parse dataset_specs for this region
            if ~isempty(dataset_specs)
                for i = 1:numel(dataset_specs)
                    if iscell(dataset_specs)
                        specs = dataset_specs{i};
                    else
                        specs = dataset_specs(i);
                    end
                    if isfield(specs, "space_id")
                        for parcellation_index = 1:numel(parcellation.Spaces)
                             if specs.space_id == parcellation.Spaces(parcellation_index).Id
                                probabilityMaps(end + 1) = siibra.items.ProbabilityMap( ...
                                region, ...
                                parcellation.Spaces(parcellation_index), ...
                                specs.url, ...
                                specs.map_type ...
                                );
                             end
                        end
                    end
                end
            end

            region.ProbabilityMaps = probabilityMaps;
        end

        function spaces = get.Spaces(obj)
            spaces = [obj.ProbabilityMaps.Space];
        end
        function space = space(obj, spaceName)
            spaceNames = {obj.ProbabilityMaps.Space.Name};
            spaceIndex = siibra.internal.fuzzyMatching(spaceName, spaceNames);
            space = obj.ProbabilityMaps(spaceIndex).Space;
        end
        function children = get.Children(obj)
            children = obj.Parcellation.getChildRegions(obj.Name);
        end
        function parent = get.Parent(obj)
            parent = obj.Parcellation.getParentRegion(obj.Name);
        end
        function map = probabilityMap(obj, space_name)
            found_space = false;
            for i = 1:numel(obj.ProbabilityMaps)
                if strcmp(obj.ProbabilityMaps(i).Space.Name, space_name)
                    found_space = true;
                    map = obj.ProbabilityMaps(i);
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
        end
    end
end