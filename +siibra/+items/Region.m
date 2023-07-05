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

        function visualizeInTemplate(obj, spaceName, colormap_name)
            arguments
                obj
                spaceName string
                colormap_name string = "jet"
            end

            space = obj.matchAgainstSpacesParcellationSupports(spaceName);
            template = space.loadTemplate().normalizedData();
            continuousMap = obj.continuousMap(spaceName).fetch().loadData();

            fig = uifigure;
            g = uigridlayout(fig, [2, 2]);
            viewer = viewer3d(g);
            viewer.Layout.Row = 2;
            viewer.Layout.Column = 2;
            viewer.BackgroundColor="white";
            viewer.BackgroundGradient="off";
            hVolumeContinuous = volshow(template, ...
                OverlayData=continuousMap, ...
                Parent=viewer, ...
                Alphamap=linspace(0,0.2,256), ...
                OverlayRenderingStyle="GradientOverlay", ...
                RenderingStyle="GradientOpacity");
            
            hVolumeContinuous.OverlayAlphamap=linspace(0,0.5,256);
            
            cmap = colormap(colormap_name);
            cmap(1, :) = [0, 0, 0];
            color_indices = cast(continuousMap * 254 + 1, "uint8");
            probability_color_volume = reshape(cmap(color_indices, :), [size(continuousMap), 3]);
            
            cmap = colormap("gray");
            color_indices = template;
            template_color_volume = reshape(cmap(color_indices, :), [size(template), 3]);
            
            mixed_volume = template_color_volume;
            mixed_volume(continuousMap>0) = probability_color_volume(continuousMap>0);
            
            panel1 = uipanel(g);
            panel1.Layout.Row = 1;
            panel1.Layout.Column = 1;
            sliceViewer(permute(mixed_volume, [2, 1, 3, 4]), "Parent",panel1, "SliceDirection","Y");
            
            panel2 = uipanel(g);
            panel2.Layout.Row = 1;
            panel2.Layout.Column = 2;
            sliceViewer(mixed_volume, "Parent",panel2, "SliceDirection","Y");
            
            panel3 = uipanel(g);
            panel3.Layout.Row = 2;
            panel3.Layout.Column = 1;
            sliceViewer(flip(permute(mixed_volume, [2, 1, 3, 4]), 1), "Parent",panel3, "SliceDirection","Z");
        end

    end
end