classdef Space < handle
    
    properties
        ID
        Name
        TemplateURL
        Format
        VolumeType
        AtlasId
    end
    
    methods
        function space = Space(atlas_space_reference_json, atlas_id)
            space.AtlasId = atlas_id;
            space_json = webread(atlas_space_reference_json.links.self.href);
            space.ID = space_json.id;
            space.Name = space_json.name;
            space.Format = space_json.type;
            space.VolumeType = space_json.src_volume_type;
            space.TemplateURL = space_json.links.templates.href;
        end
        function template = getTemplate(obj)
            cached_path = strcat("+siibra/cache/template_cache/", obj.Name, ".nii");
            if isfile(cached_path)
                template = niftiread(cached_path);
            else
                options = weboptions;
                options.Timeout = 30;
                websave(cached_path, obj.TemplateURL, options);
                template = niftiread(cached_path);
            end
            

        end
    end
end

