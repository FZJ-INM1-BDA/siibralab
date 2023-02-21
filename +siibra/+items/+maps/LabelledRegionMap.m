classdef LabelledRegionMap < handle
    %LabelledRegionMap The LabelledRegionMap combines possibly multiple
    %regions the space and the label indices for each region.
    %   Based on this information the LabelledRegionMap creates a nifi
    %   containing the combined mask of all regions.
    
    properties
        Region (1, 1) % siibra.items.Region
        Space (1, :) siibra.items.Space
        LabelIndex (1,1) uint32 {mustBeFinite}
    end
    methods
        function obj = LabelledRegionMap(region, space)
            obj.Region = region;
            obj.Space = space;
        end
        function cachePath = maskCachePath(obj)
            filename = obj.Region.NormalizedName + obj.Space.NormalizedName + "_mask.nii.gz";
            cachePath = siibra.internal.cache(filename, "region_cache");
        end
        

        function nifti = fetch(obj)
            if ~isfile(obj.maskCachePath)
                siibra.internal.API.doWebsaveWithLongTimeout( ...
                    obj.maskCachePath, ...
                    siibra.internal.API.parcellationMap( ...
                        obj.Space.Id,...
                        obj.Region.Parcellation.Id,...
                        obj.Region.Name) ...
                    )

            end
            nifti = siibra.items.NiftiImage(obj.maskCachePath);
        end
    end
        
end

