classdef Parcellation < handle
    properties
        Id
        Name
        Atlas
        Modality
        Description
        Graph
        Spaces
    end

    methods
        function parcellation = Parcellation(parcellation_json, atlas)
            parcellation.Id = strcat(parcellation_json.id.kg.kgSchema, '/', parcellation_json.id.kg.kgId);
            parcellation.Name = parcellation_json.name;
            parcellation.Atlas = atlas;
            parcellation.Modality = parcellation_json.modality;
            if ~ isempty(parcellation_json.infos)
                parcellation.Description = parcellation_json.infos(1).description;
            end

            % link spaces from atlas
            parcellation.Spaces = Space.empty;
            % retrieve available spaces from atlas
            for available_space_index = 1:numel(parcellation_json.availableSpaces)
                % store handle to space object
                for atlas_space_index = 1:numel(atlas.Spaces.Space)
                    if isequal(atlas.Spaces.Space(atlas_space_index).ID, parcellation_json.availableSpaces(available_space_index).id)
                        parcellation.Spaces(end +1) = atlas.Spaces.Space(atlas_space_index);
                    end
                end
            end
            
            % call api to get parcellation tree
            regions = webread(parcellation_json.links.regions.href);
            
            % store graph
            parcellation.Graph = Parcellation.createParcellationTree(parcellation, regions);
            
            
            %parcellation.Spaces = table(string({spaces_subset.Name}).', spaces_subset.', 'VariableNames', {'Name', 'Space'});
        end
        %getters
        function space_table = spaceTable(obj)  
            space_table = table(string({obj.Spaces.Name}).', obj.Spaces.', 'VariableNames', {'Name', 'Space'});
        end
        function region_table = findRegion(obj, region_name_query)
            region_table = obj.Graph.Nodes(contains(obj.Graph.Nodes.Name, region_name_query), :);
        end
        function region = decodeRegion(obj, region_name_query)
            region_table = obj.findRegion(region_name_query);
            assert(height(region_table) == 1, "query was not unambiguous!")
            region = region_table.Region(1);
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
        function parent_region = getParentRegion(obj, region_name)
            nodeId = obj.Graph.findnode(region_name);
            parents = obj.Graph.predecessors(nodeId);
            assert(length(parents) == 1, "Expect just one parent in a tree structure");
            parentID = parents(1);
            parent_region = obj.Graph.Nodes.Region(parentID);
        end
        function parent_name = getParentName(obj, region_name)
            parent_region = obj.getParentRegion(region_name);
            parent_name = parent_region.Name;
        end
    end
    methods (Static)
        function tree = createParcellationTree(parcellation, regions)
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
            tree = digraph(source, target, zeros(length(target), 1),  nodeTable);
        end

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