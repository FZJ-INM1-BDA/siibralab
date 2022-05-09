classdef Region < handle
    properties
        Name string
        Parcellation (1, :) siibra.items.Parcellation
        SpaceAndRegionUrl (1, :) struct
        Spaces (1, :) siibra.items.Space
        Parent (1, 1) % Region
        Children (1, :) % Region
    end
    methods
        function region = Region(name, parcellation, dataset_specs)
            region.Name = name;
            region.Parcellation = parcellation;
            
            spaceAndRegion.spaces = siibra.items.Space.empty;
            spaceAndRegion.url = string.empty;
            space_ids = string.empty;
            space_urls = string.empty;

            % parse dataset_specs for this region
            if ~isempty(dataset_specs)
                for i = 1:numel(dataset_specs)
                    if iscell(dataset_specs) && isfield(dataset_specs{i, 1}, "space_id")
                        space_ids(end +1) = dataset_specs{i, 1}.space_id;
                        space_urls(end +1) = dataset_specs{i, 1}.url;
                    elseif isfield(dataset_specs(i), "space_id")
                        space_ids(end +1) = dataset_specs(i).space_id;
                        space_urls(end +1) = dataset_specs(i).url;
                    end
                end
            end
            for region_index = 1:numel(space_ids)
                for parcellation_index = 1:numel(parcellation.Spaces)
                    if space_ids(region_index) == parcellation.Spaces(parcellation_index).Id
                        spaceAndRegion.spaces(end + 1) = parcellation.Spaces(parcellation_index);
                        spaceAndRegion.url(end + 1) = space_urls(region_index);
                        break
                    end
                end
            end
            region.SpaceAndRegionUrl = spaceAndRegion;
        end

        function spaces = get.Spaces(obj)
            spaces = obj.SpaceAndRegionUrl.spaces;
        end
        function space = space(obj, spaceName)
            spaceNames = {obj.SpaceAndRegionUrl.spaces.Name};
            spaceIndex = siibra.internal.fuzzyMatching(spaceName, spaceNames);
            space = obj.SpaceAndRegionUrl.spaces(spaceIndex);
        end
        function children = get.Children(obj)
            children = obj.Parcellation.getChildRegions(obj.Name);
        end
        function parent = get.Parent(obj)
            parent = obj.Parcellation.getParentRegion(obj.Name);
        end
        function orthosliceview = visualizeProbabilityMapInTemplate(obj, space_name)
            % Combine the probability map of the region with
            % its corresponding template.
            space = obj.space(space_name);
            pmap = obj.probabilityMap(space.Name);
            template = space.Template;
            templateImage = template.getWarpedImage();
            pmap_overlay = pmap.Map;
           
            % to rgb
            pmapRGB = cat(4, pmap_overlay, zeros(size(pmap_overlay)), zeros(size(pmap_overlay)));
            templateRGB = cat(4, templateImage, templateImage, templateImage);

            % mix both layer
            orthosliceview = orthosliceViewer(pmapRGB .*0.5 + templateRGB);
        end
        function map = probabilityMap(obj, space_name)
            found_space = false;
            for i = 1:numel(obj.SpaceAndRegionUrl.spaces)
                if strcmp(obj.SpaceAndRegionUrl.spaces(i).Name, space_name)
                    assert(strcmp(obj.SpaceAndRegionUrl.spaces(i).Format, 'nii'), "Currently supports nii format only")
                    found_space = true;
                    map = siibra.items.ProbabilityMap(obj, obj.SpaceAndRegionUrl.spaces(i), obj.SpaceAndRegionUrl.url(i));
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
        end
    end
end