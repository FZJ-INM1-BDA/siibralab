classdef Region
    properties
        name
        id
        parcellation
        space_url
    end
    methods
        function region = Region(name, id, parcellation, dataset_specs)
            region.name = name;
            region.id = id;
            region.parcellation = parcellation;

            % parse dataset_specs for this region
            if ~isempty(dataset_specs)
                for i = 1:numel(dataset_specs)
                    if iscell(dataset_specs)
                        space_id = dataset_specs{i, 1}.space_id;
                        url = dataset_specs{i, 1}.url;
                    else
                        space_id = dataset_specs(i).space_id;
                        url = dataset_specs(i).url;
                    end
                    % currently "MNI152 2009c nonl asym" is supported only 
                    if space_id == "minds/core/referencespace/v1.0.0/dafcffc5-4826-4bf1-8ff6-46b8a31ff8e2"
                        region.space_url = url;
                        break;
                    end
                end
            else
                % if no region map available
                region.space_url = "";
            end
        end
        function children = getChildrenNames(obj)
            children = obj.parcellation.getChildrenNames(obj.name);
        end
        function pmap = probabilityMap(obj)
            if obj.space_url == ""
                error("This region has no region map!");
            end
            nifti_data = api_call(obj.space_url);
            file_handle = fopen("tmp_nifti.nii.gz", "w");
            fwrite(file_handle, nifti_data);
            fclose(file_handle);
            pmap = cast(niftiread("tmp_nifti.nii.gz") * 255, "uint8");
        end
        function template = getTemplate(obj)
            % currently "MNI152 2009c nonl asym" is supported only 
            template = niftiread("siibra/templates/mni_icbm152_t1_tal_nlin_sym_09a_converted.nii.gz");
        end
        function volume = visualizeRegionInTemplate(obj)
            % Combine the probability map of the region with
            % its corresponding template.
            pmap = obj.probabilityMap();
            template = obj.getTemplate();
            
            % to rgb
            pmap_rgb = cat(4, pmap, zeros(size(pmap)), zeros(size(pmap)));
            template_rgb = cat(4, template, template, template);
            
            % cutout
            cutout = min(size(template), size(pmap));
            pmap_rgb = pmap_rgb(1:cutout(1), 1:cutout(2), 1:cutout(3), :);
            template_rgb = template_rgb(1:cutout(1), 1:cutout(2), 1:cutout(3), :);
            
            % mix both layer
            volume = pmap_rgb .*0.5 + template_rgb .*0.5;
        end
    end
end