classdef Space < handle
    
    properties
        Id (1, 1) string
        Name (1, 1) string
        NormalizedName (1, 1) string
        AtlasName(1, 1) string
    end
    
    methods
        function space = Space(spaceJson, atlasName)
            space.AtlasName = atlasName;
            space.Id = spaceJson.x_id;
            space.Name = spaceJson.fullName;

        end
        function normalizedName = get.NormalizedName(obj)
            normalizedName = strrep(obj.Name, " ", "");
        end
        function niftiImage = loadTemplateResampledForParcellation(obj, parcellation)
            cachedPath = siibra.internal.cache(obj.Name + ".nii.gz", "template_cache");
            if ~isfile(cachedPath)
                try
                    siibra.internal.API.doWebsaveWithLongTimeout( ...
                        cachedPath, ...
                        siibra.internal.API.templateForParcellationMap(parcellation.Id, obj.Id) ...
                    );
                catch Exception
                    error("Space has no template for given parcellation!")
                end
            end
            niftiImage = siibra.items.NiftiImage(cachedPath);
        end
        
    end
end