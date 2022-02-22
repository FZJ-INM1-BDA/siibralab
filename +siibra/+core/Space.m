classdef Space < handle
    
    properties
        id
        name
        templateURL
        format
        volumeType
        atlasId
    end
    
    methods
        function space = Space(atlas_space_reference_json, atlas_id)
            space.atlasId = atlas_id;
            space_json = webread(atlas_space_reference_json.links.self.href);
            space.id = space_json.id;
            space.name = space_json.name;
            space.format = space_json.type;
            space.volumeType = space_json.src_volume_type;
            space.templateURL = space_json.links.templates.href;
        end
        function template = getTemplate(obj)
            cached_path = strcat("+siibra/cache/template_cache/", obj.name, ".nii");
            if isfile(cached_path)
                template = niftiread(cached_path);
            else
                options = weboptions;
                options.Timeout = 30;
                websave(cached_path, obj.templateURL, options);
                template = niftiread(cached_path);
                
            end
            template = cast(template, "uint16");
        end
    end
end

