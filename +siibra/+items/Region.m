classdef Region < handle
    %REGION A region is a node in the RegionTree of the parcellation.
    properties
        Id string
        Name string
        NormalizedName string
        Parcellation (1, :) siibra.items.Parcellation
    end
    methods
        function region = Region(id, name, parcellation)
            region.Id = id;
            region.Name = name;
            region.Parcellation = parcellation;
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
        function children = children(obj)
            children = obj.Parcellation.getChildRegions(obj);
        end
        function parent = parent(obj)
            parent = obj.Parcellation.getParentRegion(obj);
        end
        function isLeaf = isLeaf(obj)
            isLeaf = isempty(obj.children);
        end
        function mask = getMask(obj, space)
            mask = siibra.items.maps.LabelledRegionMap(obj, space);
        end

        function map = continuousMap(obj, space)
            if obj.isLeaf
                map = siibra.items.maps.ContinuousRegionMap(obj, space);
            else
                error("continuous maps are supported on leafs only!");
            end 
        end

        function features = getAllFeatures(obj)
            cached_file_name = siibra.internal.cache(obj.NormalizedName + ".mat", "region_features");
            if ~isfile(cached_file_name)
                features = siibra.internal.API.featuresForRegion(obj);
                
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
            featureTypes = cellfun(@(e) e.x_type, allFeatures, "UniformOutput",false);
            receptorIdx = strcmp(featureTypes, "siibra-0.4/feature/tabular/receptor_density_fp");
            if ~any(receptorIdx)
                receptorDensities = siibra.items.features.ReceptorDensity.empty;
                return
            end
            assert(nnz(receptorIdx) == 1, "Expecting exactly one receptor density feature for region")
            receptorDensities = cellfun(@(json) siibra.items.features.ReceptorDensity(obj, json), allFeatures(receptorIdx));

        end

        function visualizeInTemplate(obj, space, colormap_name)
            arguments
                obj
                space siibra.items.Space
                colormap_name string = "jet"
            end

            
            template = space.loadTemplateResampledForParcellation(obj.Parcellation).normalizedData();
            continuousMap = obj.continuousMap(space).fetch().loadData();

            fig = uifigure;
            g = uigridlayout(fig, [2, 2]);
            viewer = viewer3d(g);
            viewer.Layout.Row = 2;
            viewer.Layout.Column = 2;
            viewer.BackgroundColor="white";
            viewer.BackgroundGradient="off";
            
            
            cmap = colormap(colormap_name);
            cmap(1, :) = [0, 0, 0];
            color_indices = cast(continuousMap * 254 + 1, "uint8");
            probability_color_volume = reshape(cmap(color_indices, :), [size(continuousMap), 3]);
            
            cmap = colormap("gray");
            color_indices = template;
            template_color_volume = reshape(cmap(color_indices, :), [size(template), 3]);
            
            mixed_volume = template_color_volume;
            mixed_volume(continuousMap>0) = probability_color_volume(continuousMap>0);
            
            hVolumeContinuous = volshow(template, ...
                OverlayData=cast(continuousMap * 254 + 1, "uint8"), ...
                OverlayRenderingStyle="VolumeOverlay", ...
                OverlayColormap=colormap(colormap_name), ...
                RenderingStyle="GradientOpacity", ...
                Parent=viewer, ...
                Alphamap=linspace(0,0.2,256));
                
            
            hVolumeContinuous.OverlayAlphamap=linspace(0,0.1,256);
            
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