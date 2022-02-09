classdef Region < handle
    properties
        Name
        ID
        Parcellation
        SpaceAndRegionUrl
    end
    methods
        function region = Region(name, id, parcellation, dataset_specs)
            region.Name = name;
            region.ID = id;
            region.Parcellation = parcellation;
            
            space_and_region_url.Spaces = Space.empty;
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
                for parcellation_index = 1:numel(parcellation.Spaces)
                    if space_ids(region_index) == parcellation.Spaces(parcellation_index).ID
                        space_and_region_url.Spaces(end + 1) = parcellation.Spaces(parcellation_index);
                        space_and_region_url.Url(end + 1) = space_urls(region_index);
                        break
                    end
                end
            end
            region.SpaceAndRegionUrl = space_and_region_url;
        end

        function parent = getParentName(obj)
            parent = obj.Parcellation.getParentName(obj.Name);
        end
        function children = getChildrenNames(obj)
            children = obj.Parcellation.getChildrenNames(obj.Name);
        end
        function pmap = probabilityMap(obj, space_name)
            found_space = false;
            for i = 1:numel(obj.SpaceAndRegionUrl)
                if obj.SpaceAndRegionUrl(i).Space.Name == space_name
                    found_space = true;
                    nifti_data = webread(obj.SpaceAndRegionUrl.Url);
                    assert(obj.SpaceAndRegionUrl(i).Space.Format == 'nii', "Currently supports nii format only")
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