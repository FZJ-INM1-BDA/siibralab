classdef Region < handle
    properties
        Name
        Id
        Parcellation
        Spaces
    end
    methods
        function region = Region(name, id, parcellation, dataset_specs)
            region.Name = name;
            region.Id = id;
            region.Parcellation = parcellation;
            
            % parse dataset_specs for this region
            % create a table with a row for each space
            Spaces = table;
            space_ids = string.empty;
            space_name = string.empty;
            space_urls = string.empty;
            space_volume_types = string.empty;
            space_map_types = string.empty;
            
            if ~isempty(dataset_specs)
                for i = 1:numel(dataset_specs)
                    if iscell(dataset_specs) && isfield(dataset_specs{i, 1}, "space_id")
                        space_ids(end +1) = dataset_specs{i, 1}.space_id;
                        space_urls(end +1) = dataset_specs{i, 1}.url;
                        space_name(end +1) = dataset_specs{i, 1}.name;
                        space_volume_types(end +1) = dataset_specs{i, 1}.volume_type;
                        space_map_types(end +1) = dataset_specs{i, 1}.map_type; 
                    elseif isfield(dataset_specs(i), "space_id")
                        space_ids(end +1) = dataset_specs(i).space_id;
                        space_urls(end +1) = dataset_specs(i).url;
                        space_name(end +1) = dataset_specs(i).name;
                        space_volume_types(end +1) = dataset_specs(i).volume_type;
                        space_map_types(end +1) = dataset_specs(i).map_type; 
                    end
                end
            end
            
            region.Spaces = table(space_ids.', space_name.', space_urls.', ...
                space_volume_types.', space_map_types.', 'VariableNames',{'Id','Name','URL','VolumeType', 'MapType'});
        end
        function children = getChildrenNames(obj)
            children = obj.Parcellation.getChildrenNames(obj.Name);
        end
        function pmap = probabilityMap(obj)
            if obj.Spaces == ""
                error("This region has no region map!");
            end
            nifti_data = webread(obj.Spaces);
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