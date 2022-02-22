classdef Parcellation < handle
    properties
        id
        name
        atlas
        modality
        desciption
        regionTree
        spaces
    end

    methods
        function parcellation = Parcellation(parcellation_json, atlas)
            parcellation.id = strcat(parcellation_json.id.kg.kgSchema, '/', parcellation_json.id.kg.kgId);
            parcellation.name = parcellation_json.name;
            parcellation.atlas = atlas;
            parcellation.modality = parcellation_json.modality;
            if ~ isempty(parcellation_json.infos)
                parcellation.desciption = parcellation_json.infos(1).description;
            end

            % link spaces from atlas
            parcellation.spaces = siibra.core.Space.empty;
            % retrieve available spaces from atlas
            for available_space_index = 1:numel(parcellation_json.availableSpaces)
                % store handle to space object
                for atlas_space_index = 1:numel(atlas.spaces)
                    if isequal(atlas.spaces(atlas_space_index).id, parcellation_json.availableSpaces(available_space_index).id)
                        parcellation.spaces(end +1) = atlas.spaces(atlas_space_index);
                    end
                end
            end
            
            % call api to get parcellation tree
            regions = webread(parcellation_json.links.regions.href);
            
            % store graph
            parcellation.regionTree = siibra.core.Parcellation.createParcellationTree(parcellation, regions);
            
            %parcellation.Spaces = table(string({spaces_subset.Name}).', spaces_subset.', 'VariableNames', {'Name', 'Space'});
        end
       
        function region_names = findRegion(obj, region_name_query)
            region_names = obj.regionTree.Nodes(contains(obj.regionTree.Nodes.Name, region_name_query), 1);
        end
        function region = decodeRegion(obj, region_name_query)
            region_table = obj.findRegion(region_name_query);
            assert(height(region_table) == 1, "query was not unambiguous!")
            region = region_table.Region(1);
        end
        function region = getRegion(obj, region_name_query)
            nodeId = obj.regionTree.findnode(region_name_query);
            region = obj.regionTree.Nodes.Region(nodeId);
        end
        function children = getChildrenRegions(obj, region_name)
            nodeId = obj.regionTree.findnode(region_name);
            childrenIds = obj.regionTree.successors(nodeId);
            children = obj.regionTree.Nodes.Region(childrenIds);
        end
        function parent_region = getParentRegion(obj, region_name)
            nodeId = obj.regionTree.findnode(region_name);
            parents = obj.regionTree.predecessors(nodeId);
            assert(length(parents) == 1, "Expect just one parent in a tree structure");
            parentID = parents(1);
            parent_region = obj.regionTree.Nodes.Region(parentID);
        end
    end
    methods (Static)
        function tree = createParcellationTree(parcellation, regions)
            root.name = parcellation.name;
            root.children = regions;
            [source, target, region] = siibra.core.Parcellation.traverseTree(parcellation, root, string.empty, string.empty, siibra.core.Region.empty);
            % append root node
            nodes = target;
            nodes(length(nodes) + 1) = root.name;
            region(length(region) + 1) = siibra.core.Region(root.name, "root", parcellation, []);
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
                regions(length(regions) + 1) = siibra.core.Region(child.name, child.id, parcellation, child.x_dataset_specs);
                [source, target, regions] = siibra.core.Parcellation.traverseTree(parcellation, child, source, target, regions);
            end
        end
    end
end