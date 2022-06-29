classdef ContinuousMap < siibra.items.maps.ParcellationMap
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % kn
    
    properties
    end
    
    methods
        function obj = ContinuousMap(region, space, url)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj@siibra.items.maps.ParcellationMap(region, space, url);
        end
        function nifti = loadNifti(obj)
            normalizedRegionName = strrep(obj.Region.Name, " ", "");
            normalizedRegionName = strrep(normalizedRegionName, "/", "-");
            normalizedSpaceName = strrep(obj.Space.Name, " ", "");
            cache_path = strcat("+siibra/cache/region_cache/", normalizedRegionName, normalizedSpaceName, ".nii.gz");
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
            nifti = obj.loadNifti();
            size = nifti.Header.ImageSize;
        end
        function data = getDataRelativeToTemplate(obj)
            template = obj.Space.loadTemplate;
            pmapNifti = obj.loadNifti();
            data = pmapNifti.getOverlayWarpedRelativeTo(template);
        end
    end
end

