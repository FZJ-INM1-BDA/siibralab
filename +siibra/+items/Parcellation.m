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
        Spaces (1, :) siibra.items.Space
    end

    methods
        function parcellation = Parcellation(parcellationJson, atlas)
            parcellation.Id = strcat(parcellationJson.id.kg.kgSchema, '/', parcellationJson.id.kg.kgId);
            parcellation.Name = parcellationJson.name;
            parcellation.Atlas = atlas;
            
            if isempty(parcellationJson.modality)
                parcellation.Modality = "";
            else
                parcellation.Modality = parcellationJson.modality;
            end

            % some parcellations do have a description
            if ~ isempty(parcellationJson.infos)
                parcellation.Description = parcellationJson.infos(1).description;
            end

            % link spaces from atlas
            parcellation.Spaces = siibra.items.Space.empty;
            % retrieve available spaces from atlas
            for idx = 1:numel(parcellationJson.availableSpaces)
                % store handle to space object
                for atlasSpaceIndex = 1:numel(atlas.Spaces)
                    if isequal(atlas.Spaces(atlasSpaceIndex).Id, parcellationJson.availableSpaces(idx).id)
                        parcellation.Spaces(end +1) = atlas.Spaces(atlasSpaceIndex);
                    end
                end
            end
            
            % call api to get parcellation tree
            regions = webread(parcellationJson.links.regions.href);
            
            % store graph
            parcellation.RegionTree = siibra.items.Parcellation.createParcellationTree(parcellation, regions);
        end

        function map = parcellationMap(obj, spaceName)
            idx = siibra.internal.fuzzyMatching(spaceName, [obj.Spaces.Name]);
            map = siibra.items.maps.ParcellationMap(obj, obj.Spaces(idx));
        end
       
        function regionNames = findRegion(obj, regionNameQuery)
            regionNames = obj.RegionTree.Nodes(contains(obj.RegionTree.Nodes.Name, regionNameQuery), 1);
        end
        function region = decodeRegion(obj, regionNameQuery)
            index = siibra.internal.fuzzyMatching(regionNameQuery, [obj.RegionTree.Nodes.Name]);
            region = obj.RegionTree.Nodes.Region(index);
        end
        function region = getRegion(obj, regionNameQuery)
            nodeId = obj.RegionTree.findnode(regionNameQuery);
            region = obj.RegionTree.Nodes.Region(nodeId);
        end
        function children = getChildRegions(obj, regionName)
            nodeId = obj.RegionTree.findnode(regionName);
            childrenIds = obj.RegionTree.successors(nodeId);
            children = obj.RegionTree.Nodes.Region(childrenIds);
        end
        function parentRegion = getParentRegion(obj, regionName)
            nodeId = obj.RegionTree.findnode(regionName);
            parents = obj.RegionTree.predecessors(nodeId);
            assert(length(parents) == 1, "Expect just one parent in a tree structure");
            parentId = parents(1);
            parentRegion = obj.RegionTree.Nodes.Region(parentId);
        end

        function features = getAllFeatures(obj)
            cached_file_name = siibra.internal.cache(obj.Name + ".mat", "parcellation_features");
            if ~isfile(cached_file_name)
                features = siibra.internal.API.featuresForParcellation(obj.Atlas.Id, obj.Id);
                save(cached_file_name, 'features');
            else
                load(cached_file_name, 'features')
            end

        end

        function streamlineCounts = getStreamlineCounts(obj)
            allFeatures = obj.getAllFeatures();
            streamlineCountIdx = arrayfun(@(e) strcmp(e.x_type,'siibra/features/connectivity/streamlineCounts'), allFeatures);
            streamlineCounts = arrayfun(@(json) siibra.items.features.StreamlineCounts(obj, json), allFeatures(streamlineCountIdx));
        end
    end
    

    methods (Static)
        function tree = createParcellationTree(parcellation, regions)
            root.name = parcellation.Name;
            root.children = regions;
            [source, target, region] = siibra.items.Parcellation.traverseTree(parcellation, root, string.empty, string.empty, siibra.items.Region.empty);
            % append root node
            nodes = target;
            nodes(length(nodes) + 1) = root.name;
            region(length(region) + 1) = siibra.items.Region(root.name, parcellation, []);
            % make nodes unique
            [uniqueNodes, uniqueIndices, ~] = unique(nodes);
            nodeTable = table(uniqueNodes.', region(uniqueIndices).', 'VariableNames', ["Name", "Region"]);
            tree = digraph(source, target, zeros(length(target), 1),  nodeTable);
        end

        function [source, target, regions] = traverseTree(parcellation, root, source, target, regions)
            % Parses the parcellation tree.
            % Recursively calls itself to parse the children of the current
            % root.
            % Creates a region for each node in the parcellation tree.

            for childNum = 1:numel(root.children)
                child = root.children(childNum);
                source(length(source) + 1) = root.name;
                target(length(target) + 1) = child.name;
                regions(length(regions) + 1) = siibra.items.Region(child.name, parcellation, child.x_dataset_specs);
                [source, target, regions] = siibra.items.Parcellation.traverseTree(parcellation, child, source, target, regions);
            end
        end
    end
end