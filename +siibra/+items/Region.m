classdef Region < handle
    properties
        Name string
        Parcellation (1, :) siibra.items.Parcellation
        ParcellationMaps (1, :) siibra.items.maps.ParcellationMap
        Spaces (1, :) siibra.items.Space
        Parent (1, 1) % Region
        Children (1, :) % Region
    end
    methods
        function region = Region(name, parcellation, dataset_specs)
            region.Name = name;
            region.Parcellation = parcellation;

            parcellationMaps = siibra.items.maps.ParcellationMap.empty;

            % parse dataset_specs for this region
            if ~isempty(dataset_specs)
                for i = 1:numel(dataset_specs)
                    if iscell(dataset_specs)
                        specs = dataset_specs{i};
                    else
                        specs = dataset_specs(i);
                    end
                    if isfield(specs, "space_id")
                        for spaceIndex = 1:numel(parcellation.Spaces)
                             space = parcellation.Spaces(spaceIndex);
                             if specs.space_id == space.Id
                                parcellationMaps(end +1) = siibra.items.maps.mapFactory( ...
                                region, ...
                                space, ...
                                specs.url, ...
                                specs.map_type ...
                                );
                             end
                        end
                    end
                end
            end

            region.ParcellationMaps = parcellationMaps;
        end

        function spaces = get.Spaces(obj)
            if isempty(obj.ParcellationMaps)
                spaces = siibra.items.Space.empty;
            else
                spaces = [obj.ParcellationMaps.Space];
            end
        end
        function space = space(obj, spaceName)
            spaceNames = {obj.Spaces.Name};
            spaceIndex = siibra.internal.fuzzyMatching(spaceName, spaceNames);
            space = obj.ParcellationMaps(spaceIndex).Space;
        end
        function children = get.Children(obj)
            children = obj.Parcellation.getChildRegions(obj.Name);
        end
        function parent = get.Parent(obj)
            parent = obj.Parcellation.getParentRegion(obj.Name);
        end
        function map = continuousMap(obj, spaceName)
            map = obj.parcellationMapForSpace(spaceName);
            if ~isa(map, 'siibra.items.maps.ContinuousMap')
                error("Region has no continuous map");
            end
        end
        function map = labeledMap(obj, spaceName)
            map = obj.parcellationMapForSpace(spaceName);
            if ~isa(map, 'siibra.items.maps.LabeledMap')
                error("Region has no labeled map");
            end
        end
    end
    methods (Access= private)
        function map = parcellationMapForSpace(obj, spaceName)
            found_space = false;
            for i = 1:numel(obj.ParcellationMaps)
                if strcmp(obj.ParcellationMaps(i).Space.Name, spaceName)
                    found_space = true;
                    map = obj.ParcellationMaps(i);
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
        end  

    end  
end