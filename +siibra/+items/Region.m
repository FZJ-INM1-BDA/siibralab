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
        function region = Region(name, parcellation, datasetSpecs)
            region.Name = name;
            region.Parcellation = parcellation;
            spaces = siibra.items.Space.empty;
            % parse datasetSpecs for this region
            if ~isempty(datasetSpecs)
                for i = 1:numel(datasetSpecs)
                    if iscell(datasetSpecs)
                        specs = datasetSpecs{i};
                    else
                        specs = datasetSpecs(i);
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
            mask = siibra.items.maps.LabelledRegionMap(obj, space);
        end

        function map = continuousMap(obj, spaceName)
            space = obj.matchAgainstSpacesParcellationSupports(spaceName);
            if obj.IsLeaf
                map = siibra.items.maps.ContinuousRegionMap(obj, space);
            else
                error("continuous maps are supported on leafs only!");
            end 
        end

        function features = getAllFeatures(obj)
            cached_file_name = siibra.internal.cache(obj.NormalizedName + ".mat", "region_features");
            if ~isfile(cached_file_name)
                features = siibra.internal.API.doWebreadWithLongTimeout( ...
                    siibra.internal.API.featuresForRegion( ...
                    obj.Parcellation.Atlas.Id, ...
                    obj.Parcellation.Id, ...
                    obj.Name));
                
                % make sure to always return a cell array
                if ~iscell(features)
                    features = num2cell(features);
                end

                save(cached_file_name, 'features');
            else
                load(cached_file_name, 'features')
            end
        end

        function receptorDensities = getReceptorDensities(obj)
            allFeatures = obj.getAllFeatures();
            receptorIdx = cellfun(@(e) strcmp(e.x_type,'siibra/features/receptor'), allFeatures);
            if ~any(receptorIdx)
                receptorDensities = siibra.items.features.ReceptorDensity.empty;
                return
            end
            assert(nnz(receptorIdx) == 1, "Expecting exactly one receptor density feature for region")
            receptorDensities = cellfun(@(json) siibra.items.features.ReceptorDensity(obj, json), allFeatures(receptorIdx));

        end
    end
end