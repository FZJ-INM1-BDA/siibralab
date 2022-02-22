classdef Region < handle
    properties
        name
        id
        parcellation
        spaceAndRegionUrl
    end
    methods
        function region = Region(name, id, parcellation, dataset_specs)
            region.name = name;
            region.id = id;
            region.parcellation = parcellation;
            
            space_and_region_url.Spaces = siibra.core.Space.empty;
            space_and_region_url.Url = string.empty;
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
                    if space_ids(region_index) == parcellation.spaces(parcellation_index).ID
                        space_and_region_url.Spaces(end + 1) = parcellation.spaces(parcellation_index);
                        space_and_region_url.Url(end + 1) = space_urls(region_index);
                        break
                    end
                end
            end
            region.spaceAndRegionUrl = space_and_region_url;
        end
        function parent_region = getParentRegion(obj)
            parent_region = obj.parcellation.getParentRegion(obj.name);
        end
        function parent_name = getParentName(obj)
            parent_name = obj.parcellation.getParentName(obj.name);
        end
    
        function children = getChildrenNames(obj)
            children = obj.parcellation.getChildrenNames(obj.name);
        end
        function pmap = probabilityMap(obj, space_name)
            found_space = false;
            for i = 1:numel(obj.spaceAndRegionUrl)
                if obj.spaceAndRegionUrl(i).Space.Name == space_name
                    found_space = true;
                    nifti_data = webread(obj.spaceAndRegionUrl.Url);
                    assert(obj.spaceAndRegionUrl(i).Space.Format == 'nii', "Currently supports nii format only")
                    file_handle = fopen("tmp_nifti.nii.gz", "w");
                    fwrite(file_handle, nifti_data);
                    fclose(file_handle);
                    pmap = cast(niftiread("tmp_nifti.nii.gz") * 255, "uint8");
                    delete "tmp_nifti.nii.gz"
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
            
        end
    end
end