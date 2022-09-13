classdef ContinuousRegionMap < handle
    %ContinuousRegionMap The ContinuousRegionMap is a wrapper around a
    %cached nifti that holds for example the probabilities for a certain
    %region.
    
    properties
        Region (1, :) siibra.items.Region
        Space (1, :) siibra.items.Space
        URL string
        CachePath string
    end
    
    methods
        function obj = ContinuousRegionMap(region, space)
            obj.Region = region;
            obj.Space = space;
        end
        
        function cachePath = get.CachePath(obj)
            filename = strcat(obj.Region.NormalizedName, obj.Space.NormalizedName, "_continuous.nii.gz");
            cachePath = siibra.internal.cache(filename, "region_cache");
        end
        function nifti = fetch(obj)
            if ~isfile(obj.CachePath)
                siibra.internal.API.doWebsaveWithLongTimeout( ...
                    siibra.internal.API.regionMap(...
                    obj.CachePath, ...
                    obj.Region.Parcellation.Atlas.Id, ...
                    obj.Region.Parcellation.Id, ...
                    obj.Region.Name, ...
                    obj.Space.Id, ...
                    "map", ...
                    "CONTINUOUS"));
            end
            nifti = siibra.items.NiftiImage(obj.CachePath);
        end

        function size = mapSize(obj)
            nifti = obj.fetch();
            size = nifti.Header.ImageSize;
        end
        function data = getDataRelativeToTemplate(obj)
            template = obj.Space.loadTemplate;
            pmapNifti = obj.fetch();
            data = pmapNifti.getOverlayWarpedRelativeTo(template);
        end
    end
end

