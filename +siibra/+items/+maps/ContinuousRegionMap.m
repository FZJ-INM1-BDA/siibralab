classdef ContinuousRegionMap < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % 
    
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
        
        function url = get.URL(obj)
            % /atlases/{atlas_id}/parcellations/{parcellation_id}/regions/{region_id}/regional_map/info
            url = strcat("atlases/", obj.Region.Parcellation.Atlas.Id, "/parcellations/", obj.Region.Parcellation.Id,...
                    "/regions/", obj.Region.Name, "/regional_map/map?space_id=", obj.Space.Id);
        end
        function cachePath = get.CachePath(obj)
            filename = strcat(obj.Region.NormalizedName, obj.Space.NormalizedName, "_continuous.nii.gz");
            cachePath = siibra.internal.cache(filename, "region_cache");
        end
        function nifti = fetch(obj)
            if ~isfile(obj.CachePath)
                % set higher timeout
                options = weboptions;
                options.Timeout = 30;
                nifti_data = webread(siibra.internal.API.absoluteLink(obj.URL));
                file_handle = fopen(obj.CachePath, "w");
                assert(file_handle > 0, "invalid file handle for cached file " + obj.CachePath);
                fwrite(file_handle, nifti_data);
                fclose(file_handle);
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

