classdef Parcellation
    properties
        Id
        Name
        AtlasId
        Graph
    end
    methods
        function parcellation = Parcellation(id, name, atlasId)
            parcellation.Id = strcat(id.kg.kgSchema, '/', id.kg.kgId);
            parcellation.Name = name;
            parcellation.AtlasId = atlasId;
            % call api to get parcellation tree
            regions = api_call(Siibra.apiEndpoint + "atlases/" + parcellation.AtlasId + "/parcellations/" + parcellation.Id + "/regions");
            root.name = parcellation.Name;
            root.children = regions;
            [source, target, region] = Parcellation.traverseTree(parcellation, root, string.empty, string.empty, Region.empty);
            % append root node
            nodes = target;
            nodes(length(nodes) + 1) = root.name;
            region(length(region) + 1) = Region(root.name, "root", parcellation, []);
            % make nodes unique
            [unique_nodes, unique_indices, ~] = unique(nodes);
            nodeTable = table(unique_nodes.', region(unique_indices).', 'VariableNames', ["Name", "Region"]);
            % store graph
            parcellation.Graph = digraph(source, target, zeros(length(target), 1),  nodeTable);
        end
        function region = getRegion(obj, region_name_query)
            nodeId = obj.Graph.findnode(region_name_query);
            region = obj.Graph.Nodes.Region(nodeId);
        end
        function children = getChildrenNames(obj, region_name)
            nodeId = obj.Graph.findnode(region_name);
            childrenIds = obj.Graph.successors(nodeId);
            children = obj.Graph.Nodes.Name(childrenIds);
        end
    end
    methods (Static)
        function [source, target, regions] = traverseTree(parcellation, root, source, target, regions)
            % Parses the parcellation tree.
            % Recursively calls itself to parse the children of the current
            % root.
            % Creates a region for each node in the parcellation tree.

            for child_num = 1:numel(root.children)
                child = root.children(child_num);
                source(length(source) + 1) = root.name;
                target(length(target) + 1) = child.name;
                regions(length(regions) + 1) = Region(child.name, child.id, parcellation, child.x_dataset_specs);
                [source, target, regions] = Parcellation.traverseTree(parcellation, child, source, target, regions);
            end
        end
    end
end