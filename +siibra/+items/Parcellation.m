classdef Parcellation < handle
    %PARCELLATION The parcellation belongs to a certain atlas and holds the
    %RegionTree and the available spaces.
    
    properties
        Id (1, 1) string
        Name (1, 1) string
        Atlas (1, :) siibra.items.Atlas
        Modality (1, 1) string
        Description (1, 1) string
        RegionTree (1, 1) digraph
        Regions (1, :) siibra.items.Region
        Spaces (1, :) siibra.items.Space
    end

    methods
        function parcellation = Parcellation(parcellationJson, atlas)
            parcellation.Id = parcellationJson.x_id;
            parcellation.Name = parcellationJson.name;
            parcellation.Atlas = atlas;
            
            if isempty(parcellationJson.modality)
                parcellation.Modality = "";
            else
                parcellation.Modality = parcellationJson.modality;
            end

            spaceIds = arrayfun(@(atlasVersion) atlasVersion.coordinateSpace, parcellationJson.brainAtlasVersions);
            spaces = arrayfun(@(spaceId) atlas.Spaces([atlas.Spaces.Id] == spaceId.x_id), spaceIds);
            if isempty(spaces)
                parcellation.Spaces = siibra.items.Space.empty();
            else
                parcellation.Spaces = spaces;
            end
            
            regionsJson = siibra.internal.API.regions(parcellation.Id);
            function result = getSrc(regionJson)
                if isempty(regionJson.hasParent)
                    result = regionJson.x_id;
                else
                    result = regionJson.hasParent.x_id;
                end

            end
            % the api returns the same regions multiple times. so we filter
            % them here.
            [~, uniqueRegionIndices, ~] = unique({regionsJson.x_id});
            parcellation.Regions = arrayfun(@(regionJson) siibra.items.Region(regionJson.x_id, regionJson.name, parcellation), regionsJson(uniqueRegionIndices));
            srcIds = arrayfun(@(regionJson) getSrc(regionJson), regionsJson(uniqueRegionIndices), "UniformOutput",false);
            regionIds = [parcellation.Regions.Id];
            src = arrayfun(@(srcId) find(regionIds == srcId), srcIds);
            dst = 1:numel(src);

            nodeTable = table([parcellation.Regions.Id].', [parcellation.Regions.Name].', parcellation.Regions.', 'VariableNames', ["Name", "RegionName", "Region"]);
            % store graph
            parcellation.RegionTree = digraph(src, dst, zeros(length(src), 1),  nodeTable);
        end

        function map = parcellationMap(obj, space)
            map = siibra.items.maps.ParcellationMap(obj, space);
        end
       
        function regionNames = findRegion(obj, regionNameQuery)
            regionNames = obj.RegionTree.Nodes(contains(obj.RegionTree.Nodes.RegionName, regionNameQuery), 2);
        end
        function region = decodeRegion(obj, regionNameQuery)
            index = siibra.internal.fuzzyMatching(regionNameQuery, [obj.RegionTree.Nodes.RegionName]);
            region = obj.RegionTree.Nodes.Region(index);
        end
        function region = getRegion(obj, regionNameQuery)
            nodeIndex = find(obj.RegionTree.Nodes.RegionName == regionNameQuery);
            region = obj.RegionTree.Nodes.Region(nodeIndex);
        end
        function children = getChildRegions(obj, region)
            nodeId = obj.RegionTree.findnode(region.Id);
            childrenIds = obj.RegionTree.successors(nodeId);
            children = obj.RegionTree.Nodes.Region(childrenIds);
        end
        function parentRegion = getParentRegion(obj, region)
            nodeId = obj.RegionTree.findnode(region.Id);
            parents = obj.RegionTree.predecessors(nodeId);
            assert(length(parents) == 1, "Expect just one parent in a tree structure");
            parentId = parents(1);
            parentRegion = obj.RegionTree.Nodes.Region(parentId);
        end

        function streamlineCounts = getStreamlineCounts(obj)
            streamlineCountsJson = siibra.internal.API.regionalConnectivity(obj, "StreamlineCounts");
            streamlineCounts = arrayfun(@(json) siibra.items.features.StreamlineCounts(obj, json), streamlineCountsJson);
        end
    end
    
end