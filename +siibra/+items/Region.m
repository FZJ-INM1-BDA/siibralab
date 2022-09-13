classdef Region < handle
    %REGION A region is a node in the RegionTree of the parcellation.
    properties
        Name string
        NormalizedName string
        Parcellation (1, :) siibra.items.Parcellation
        Spaces (1, :) siibra.items.Space
        Parent (1, 1) % Region
        Children (1, :) % Region
        IsLeaf logical
    end
    methods
        function region = Region(name, parcellation, dataset_specs)
            region.Name = name;
            region.Parcellation = parcellation;
            spaces = siibra.items.Space.empty;
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
                                spaces(end + 1) = space;
                                
                             end
                        end
                    end
                end
            end
            region.Spaces = spaces;
        end
        function normalizedRegionName = get.NormalizedName(obj)
            normalizedRegionName = strrep(obj.Name, " ", "");
            normalizedRegionName = strrep(normalizedRegionName, "/", "-");
        end
        function space = matchAgainstSpacesParcellationSupports(obj, spaceName)
            spaceNames = {obj.Parcellation.Spaces.Name};
            spaceIndex = siibra.internal.fuzzyMatching(spaceName, spaceNames);
            space = obj.Parcellation.Spaces(spaceIndex);
        end
        function support = doesRegionSupportSpace(obj, space)
            support = any(strcmp([obj.Spaces.Id], space.Id));
        end
        function children = get.Children(obj)
            children = obj.Parcellation.getChildRegions(obj.Name);
        end
        function parent = get.Parent(obj)
            parent = obj.Parcellation.getParentRegion(obj.Name);
        end
        function isLeaf = get.IsLeaf(obj)
            isLeaf = isempty(obj.Children);
        end
        function mask = getMask(obj, spaceName)
            % Perform Breadth-first search
            % when node supports space, add to list of regions to join
            % when node does not support space check its children
            space = obj.matchAgainstSpacesParcellationSupports(spaceName);
            regions = obj;
            regionsThatSupportRequestedSpace = siibra.items.Region.empty;
            while ~isempty(regions)
                region = regions(1);
                regions = regions(2:end);
                if region.doesRegionSupportSpace(space)
                    regionsThatSupportRequestedSpace(end + 1) = region;
                else
                    regions = [regions, region.Children.'];
                end
            end
            mask = siibra.items.maps.LabelledRegionMap(obj.NormalizedName, regionsThatSupportRequestedSpace, space);
        end

        function map = continuousMap(obj, spaceName)
            space = obj.matchAgainstSpacesParcellationSupports(spaceName);
            if obj.IsLeaf
                map = siibra.items.maps.ContinuousRegionMap(obj, space);
            else
                error("continuous maps are supported on leafs only!");
            end 
        end
    end
end