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
        function volume = visualizeProbabilityMapInTemplate(obj, space_name)
            % Combine the probability map of the region with
            % its corresponding template.
            space = obj.space(space_name);
            pmap = obj.probabilityMap(space.Name);
            template = space.getTemplate();
            
            % Currently the template and probability maps support
            % translation matrices only
            pmap_offset = pmap.offsetRelativeTo(template);
            pmap_start = max(-pmap_offset, 1);
            template_start = max(pmap_offset, 1);
            pmap_end = min((size(pmap.Data) - pmap_start), (size(template.Data)-template_start)) + 1;
            pmap_cutout = pmap.Data(pmap_start(1):pmap_end(1), pmap_start(2):pmap_end(2), pmap_start(3):pmap_end(3));
            padded_pmap = zeros(size(template.Data), class(pmap_cutout));
            pmap_cutout_size = pmap_end - pmap_start + 1;
            padded_pmap( ...
                template_start(1):pmap_cutout_size(1), ...
                template_start(2):pmap_cutout_size(2), ...
                template_start(3):pmap_cutout_size(3)) = pmap_cutout;
            % to rgb
            pmapRGB = cat(4, padded_pmap, zeros(size(padded_pmap)), zeros(size(padded_pmap)));
            templateRGB = cat(4, template.Data, template.Data, template.Data);

            % mix both layer
            volume = pmapRGB .*0.5 + templateRGB;

        end
        function niftiImage = probabilityMap(obj, space_name)
            found_space = false;
            for i = 1:numel(obj.SpaceAndRegionUrl.spaces)
                if strcmp(obj.SpaceAndRegionUrl.spaces(i).Name, space_name)
                    assert(strcmp(obj.SpaceAndRegionUrl.spaces(i).Format, 'nii'), "Currently supports nii format only")
                    found_space = true;
                    cache_path = strcat("+siibra/cache/region_cache/", strrep(obj.Name, " ", ""), strrep(space_name, " ", ""), ".nii.gz");
                    if ~isfile(cache_path)
                        nifti_data = webread(obj.SpaceAndRegionUrl.url(i));
                        file_handle = fopen(cache_path, "w");
                        fwrite(file_handle, nifti_data);
                        fclose(file_handle);
                    end
                    niftiImage = siibra.items.NiftiImage(cache_path);
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
        end
    end
end