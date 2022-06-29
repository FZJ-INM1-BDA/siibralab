classdef ProbabilityMap < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % kn
    
    properties
        Region siibra.items.Region
        Space siibra.items.Space
        URL
        continuousMap
        labeledMap
        Nifti siibra.items.NiftiImage
        Size
        Type
    end
    
    methods
        function obj = ProbabilityMap(region, space, url, type)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Region = region;
            obj.Space = space;
            obj.URL = url;
            obj.Type = type;
        end
        function nifti = get.Nifti(obj)
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

        function size = get.Size(obj)
            size = obj.Nifti.Header.ImageSize;
        end
        function data = getDataRelativeToTemplate(obj)
            template = obj.Space.Template;
            pmapNifti = obj.Nifti;
            data = pmapNifti.getOverlayWarpedRelativeTo(template);
        end
        function data = get.continuousMap(obj)
            assert(strcmp(obj.Type, "continuous"), "Cannot convert to continuous map!");
            data = obj.getDataRelativeToTemplate();
        end
        function data = get.labeledMap(obj)
            data = obj.getDataRelativeToTemplate() > 0.0;
        end
    end
end

