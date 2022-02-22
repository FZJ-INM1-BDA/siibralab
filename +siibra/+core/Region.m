classdef Region < handle
    properties
        name
        id
        parcellation
        spaceAndRegionUrl
        spaces
        parent
        children
    end
    methods
        function region = Region(name, id, parcellation, dataset_specs)
            region.name = name;
            region.id = id;
            region.parcellation = parcellation;
            
            spaceAndRegion.spaces = siibra.core.Space.empty;
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
                for parcellation_index = 1:numel(parcellation.spaces)
                    if space_ids(region_index) == parcellation.spaces(parcellation_index).id
                        spaceAndRegion.spaces(end + 1) = parcellation.spaces(parcellation_index);
                        spaceAndRegion.url(end + 1) = space_urls(region_index);
                        break
                    end
                end
            end
            region.spaceAndRegionUrl = spaceAndRegion;
        end

        function spaces = get.spaces(obj)
            spaces = obj.spaceAndRegionUrl.spaces;
        end
        function space = space(obj, spaceName)
            spaceNames = {obj.spaceAndRegionUrl.spaces.name};
            spaceIndex = siibra.internal.fuzzyMatching(spaceName, spaceNames);
            space = obj.spaceAndRegionUrl.spaces(spaceIndex);
        end
        function children = get.children(obj)
            children = obj.parcellation.getChildrenRegions(obj.name);
        end
        function parent = get.parent(obj)
            parent = obj.parcellation.getParentRegion(obj.name);
        end
        function volume = visualizeProbabilityMapInTemplate(obj, space_name)
            % Combine the probability map of the region with
            % its corresponding template.
            space = obj.space(space_name);
            pmap = obj.probabilityMap(space.name);
            template = space.getTemplate();

            % to rgb
            pmapRGB = cat(4, pmap, zeros(size(pmap)), zeros(size(pmap)));
            templateRGB = cat(4, template, template, template);

            % cutout
            cutout = min(size(template), size(pmap));
            pmapRGB = pmapRGB(1:cutout(1), 1:cutout(2), 1:cutout(3), :);
            templateRGB = templateRGB(1:cutout(1), 1:cutout(2), 1:cutout(3), :);


            % mix both layer
            volume = pmapRGB .*0.5 + templateRGB;

        end
        function pmap = probabilityMap(obj, space_name)
            found_space = false;
            for i = 1:numel(obj.spaceAndRegionUrl.spaces)
                if strcmp(obj.spaceAndRegionUrl.spaces(i).name, space_name)
                    found_space = true;
                    nifti_data = webread(obj.spaceAndRegionUrl.url(i));
                    assert(strcmp(obj.spaceAndRegionUrl.spaces(i).format, 'nii'), "Currently supports nii format only")
                    tmp_path = '+siibra/cache/tmp_nifti.nii.gz';
                    file_handle = fopen(tmp_path, "w");
                    fwrite(file_handle, nifti_data);
                    fclose(file_handle);
                    pmap = cast(niftiread(tmp_path) * 2^16, "uint16");
                    delete(tmp_path);
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
            
        end
    end
end