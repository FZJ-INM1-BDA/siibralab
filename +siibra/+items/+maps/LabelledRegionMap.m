classdef LabelledRegionMap < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % kn
    
    properties
        Name string
        Regions (1, :) siibra.items.Region
        Space (1, :) siibra.items.Space
        LabelIndices (1,:) uint32 {mustBeFinite}
    end
    
    methods
        function obj = LabelledRegionMap(name, regions, space)
            obj.Name = name; 
            obj.Regions = regions;
            obj.Space = space;
        end
        function url = infoOrMapURL(obj, isInfo, regionIndex)
            if isInfo
                endpoint = "info";
            else
                endpoint = "map";
            end
            % /atlases/{atlas_id}/parcellations/{parcellation_id}/regions/{region_id}/regional_map/info?space_id={space_id}&map_type=LABELLED
            url = strcat("atlases/", obj.Regions(regionIndex).Parcellation.Atlas.Id, "/parcellations/", obj.Regions(regionIndex).Parcellation.Id,...
                "/regions/", obj.Regions(regionIndex).Name, "/regional_map/", endpoint, "?space_id=", obj.Space.Id, "&map_type=LABELLED");
        end
        function cachePath = maskCachePath(obj, compressed)
            cachePath = strcat("+siibra/cache/region_cache/", obj.Name, obj.Space.NormalizedName, "_mask.nii");
            if compressed
                cachePath = strcat(cachePath, ".gz");
            end
        end
        function url = regionUrl(obj, regionIndex)
            url = obj.infoOrMapURL(false, regionIndex);
            
        end
        function cachePath = regionsCachePath(obj, regionIndex)
            cachePath = strcat("+siibra/cache/region_cache/", obj.Regions(regionIndex).NormalizedName, obj.Space.NormalizedName, "_labelled.nii.gz");
        end
        function labelIndices = get.LabelIndices(obj)
            labelIndices = arrayfun(@(i) webread(siibra.internal.API.absoluteLink(obj.infoOrMapURL(true, i))).label, 1:numel(obj.Regions));
        end

        function nifti = fetch(obj)
            % first try mask cache
            if ~isfile(obj.maskCachePath(true))
                regionNiftis = siibra.items.NiftiImage.empty([0, numel(obj.Regions)]);
                for regionIndex = 1:numel(obj.Regions)
                    if ~isfile(obj.regionsCachePath(regionIndex))
                        nifti_data = webread(siibra.internal.API.absoluteLink(obj.regionUrl(regionIndex)));
                        file_handle = fopen(obj.regionsCachePath(regionIndex), "w");
                        assert(file_handle > 0, "invalid file handle for cached file " + obj.regionsCachePath(regionIndex));
                        fwrite(file_handle, nifti_data);
                        fclose(file_handle);
                    end

                  regionNiftis(regionIndex) = siibra.items.NiftiImage(obj.regionsCachePath(regionIndex));  
                  % assert that every region is in the same hemisphere and
                  % the niftis share the same affine matrix
                  assert(isequal(regionNiftis(regionIndex).Header.Transform, regionNiftis(1).Header.Transform), "Regions do not share the same transform!")
                end
                % create combined mask
                niftisAndLabelIndices.nifti = regionNiftis;
                niftisAndLabelIndices.labelIndex = obj.LabelIndices;
                maskData = arrayfun(@(niftiAndLabelIndex) niftiAndLabelIndex.nifti.loadData() == niftiAndLabelIndex.labelIndex, niftisAndLabelIndices, 'UniformOutput',false);
                % or data
                if false
                    combinedMaskData = any(cell2mat(maskData), 1);
                else
                    combinedMaskData = cell2mat(maskData);
                end
                header = regionNiftis(1).Header;
                header.Datatype = "uint8";
                niftiwrite(cast(combinedMaskData, "uint8"), obj.maskCachePath(false), header, 'Compressed',true)

            end
            nifti = siibra.items.NiftiImage(obj.maskCachePath(true));
        end
    end
        
end

