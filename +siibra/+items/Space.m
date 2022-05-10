classdef Space < handle
    
    properties
        Id (1, 1) string
        Name (1, 1) string
        TemplateURL (1, 1) string
        Format (1, 1) string
        VolumeType (1, 1) string
        AtlasId (1, 1) string
        Template (1, 1) %siibra.items.NiftiImage
    end
    
    methods
        function space = Space(atlas_space_reference_json, atlas_id)
            space.AtlasId = atlas_id;
            space_json = webread(atlas_space_reference_json.links.self.href);
            space.Id = space_json.id;
            space.Name = space_json.name;
            space.Format = space_json.type;
            space.VolumeType = space_json.src_volume_type;
            space.TemplateURL = space_json.links.templates.href;
        end
        function niftiImage = get.Template(obj)
            cached_path = strcat("+siibra/cache/template_cache/", obj.Name, ".nii");
            if ~isfile(cached_path)
                options = weboptions;
                options.Timeout = 30;
                websave(cached_path, obj.TemplateURL, options);
            end
            niftiImage = siibra.items.NiftiImage(cached_path);
        end
        function viewer = visualize(obj, region)
            % Combine the probability map of the region with
            % its corresponding template.
            
            pmap = region.probabilityMap(obj.Name);
            templateImage = obj.Template.getWarpedImage();
            pmap_overlay = pmap.Map;
           
            % to rgb
            pmapRGB = cat(4, pmap_overlay, zeros(size(pmap_overlay)), zeros(size(pmap_overlay)));
            templateRGB = cat(4, templateImage, templateImage, templateImage);

            % mix both layer
            viewer = orthosliceViewer(pmapRGB .*0.5 + templateRGB);
        end
    end
end