classdef ContinuousMap
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % kn
    
    properties
        Region (1, :) siibra.items.Region
        Space (1, :) siibra.items.Space
        URL string
    end
    
    methods
        function obj = ContinuousMap(region, space, url)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Region = region;
            obj.Space = space;
            obj.URL = url;
            
        end
        function nifti = fetch(obj)
            cache_path = strcat("+siibra/cache/region_cache/", obj.Region.NormalizedName, obj.Space.NormalizedName, ".nii.gz");
            if ~isfile(cache_path)
                % set higher timeout
                options = weboptions;
                options.Timeout = 30;
                nifti_data = webread(obj.URL);
                file_handle = fopen(cache_path, "w");
                assert(file_handle > 0, "invalid file handle for cached file " + cache_path);
                fwrite(file_handle, nifti_data);
                fclose(file_handle);
            end
            nifti = siibra.items.NiftiImage(cache_path);
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

