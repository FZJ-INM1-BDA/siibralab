classdef LabelledRegionMap < handle
    %LabelledRegionMap The LabelledRegionMap combines possibly multiple
    %regions the space and the label indices for each region.
    %   Based on this information the LabelledRegionMap creates a nifi
    %   containing the combined mask of all regions.
    
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
        function cachePath = maskCachePath(obj, compressed)
            filename = obj.Name + obj.Space.NormalizedName + "_mask.nii";
            if compressed
                filename = filename + ".gz";
            end
            cachePath = siibra.internal.cache(filename, "region_cache");
        end

        function cachePath = regionsCachePath(obj, regionIndex)
            filename = obj.Regions(regionIndex).NormalizedName + obj.Space.NormalizedName + "_labelled.nii.gz";
            cachePath = siibra.internal.cache(filename, "region_cache");
        end
        
        function labelIndices = get.LabelIndices(obj)

            labelIndices = arrayfun(@(i) ...
                siibra.internal.API.doWebreadWithLongTimeout(...
                    siibra.internal.API.regionMap(...
                    obj.Regions(i).Parcellation.Atlas.Id,...
                    obj.Regions(i).Parcellation.Id,...
                    obj.Regions(i).Name,...
                    obj.Space.Id,...
                    "info",...
                    "LABELLED") ...
                ).label, ...
                1:numel(obj.Regions));
        end

        function nifti = fetch(obj)
            if ~isfile(obj.maskCachePath(true))
                regionNiftis = siibra.items.NiftiImage.empty([0, numel(obj.Regions)]);
                for regionIndex = 1:numel(obj.Regions)
                    if ~isfile(obj.regionsCachePath(regionIndex))
                        siibra.internal.API.doWebsaveWithLongTimeout( ...
                            obj.regionsCachePath(regionIndex), ...
                            siibra.internal.API.regionMap( ...
                                obj.Regions(regionIndex).Parcellation.Atlas.Id,...
                                obj.Regions(regionIndex).Parcellation.Id,...
                                obj.Regions(regionIndex).Name,...
                                obj.Space.Id,...
                                "map",...
                                "LABELLED") ...
                            )
                    end
                  regionNiftis(regionIndex) = siibra.items.NiftiImage(obj.regionsCachePath(regionIndex));  
                  % assert that the niftis share the same affine matrix
                  assert(isequal(regionNiftis(regionIndex).Header.Transform, regionNiftis(1).Header.Transform), "Regions do not share the same transform!")
                end
                % create combined mask
                maskData = arrayfun(@(i) regionNiftis(i).loadData() == obj.LabelIndices(i), 1:numel(regionNiftis), 'UniformOutput',false);
                maskData = reshape(maskData, 1, 1, 1, []);
                
                combinedMaskData = any(cell2mat(maskData), 4);
                header = regionNiftis(1).Header;
                header.Datatype = "uint8";
                niftiwrite(cast(combinedMaskData, "uint8"), obj.maskCachePath(false), header, 'Compressed',true)

            end
            nifti = siibra.items.NiftiImage(obj.maskCachePath(true));
        end
    end
        
end

