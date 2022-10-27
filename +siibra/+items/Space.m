classdef Space < handle
    
    properties
        Id (1, 1) string
        Name (1, 1) string
        NormalizedName (1, 1) string
        TemplateURL (1, 1) string
        Format (1, 1) string
        VolumeType (1, 1) string
        AtlasName(1, 1) string
    end
    
    methods
        function space = Space(atlasSpaceReferenceJson, atlasName)
            space.AtlasName = atlasName;
            spaceJson = webread(atlasSpaceReferenceJson.links.self.href);
            space.Id = spaceJson.id;
            space.Name = spaceJson.name;
            space.Format = spaceJson.type;
            space.VolumeType = spaceJson.src_volume_type;
            space.TemplateURL = spaceJson.links.templates.href;
        end
        function normalizedName = get.NormalizedName(obj)
            normalizedName = strrep(obj.Name, " ", "");
        end
        function niftiImage = loadTemplate(obj)
            cachedPath = siibra.internal.cache(strcat(obj.Name, ".nii"), "template_cache");
            if ~isfile(cachedPath)
                options = weboptions;
                options.Timeout = 30;
                websave(cachedPath, obj.TemplateURL, options);
            end
            niftiImage = siibra.items.NiftiImage(cachedPath);
        end
    end
end