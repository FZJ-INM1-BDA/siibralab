classdef ContinuousRegionMap < handle
    %ContinuousRegionMap The ContinuousRegionMap is a wrapper around a
    %cached nifti that holds for example the probabilities for a certain
    %region.
    
    properties
        Region (1, :) siibra.items.Region
        Space (1, :) siibra.items.Space
        Name string
        Description string
        DOI (1, :) string
        CachePath string
    end
    
    methods
        function obj = ContinuousRegionMap(region, space)
            obj.Region = region;
            obj.Space = space;
            regionMapInfoJson = siibra.internal.API.doWebreadWithLongTimeout( ...
                siibra.internal.API.regionInfoForSpace( ...
                    obj.Region.Parcellation.Atlas.Id, ...
                    obj.Region.Parcellation.Id, ...
                    obj.Region.Name, ...
                    obj.Space.Id ...
                    ) ...
                );
            if ~regionMapInfoJson.hasRegionalMap
                error('StatisticalMap:NotFound', "Region " + region.Name + " has no statistical map!")
            end
            datasetSpecs = regionMapInfoJson.x_dataset_specs;
            if ~iscell(datasetSpecs)
                datasetSpecs = num2cell(datasetSpecs);
            end
            datasetIndex = find( ...
                cell2mat( ...
                cellfun( ...
                @(dataset) ...
                isequal(dataset.x_type, 'minds/core/dataset/v1.0.0'), ...
                datasetSpecs, ...
                'UniformOutput', false)));
            if isempty(datasetIndex)
                obj.Name = "Not available";
                obj.Description = "Not available";
                obj.DOI = string.empty;
            else
                obj.Name = datasetSpecs{datasetIndex}.name;
                obj.Description = datasetSpecs{datasetIndex}.description;
                obj.DOI = datasetSpecs{datasetIndex}.urls.doi;
            end
        end
        
        function cachePath = get.CachePath(obj)
            filename = obj.Region.NormalizedName + obj.Space.NormalizedName + "_continuous.nii.gz";
            cachePath = siibra.internal.cache(filename, "region_cache");
        end
        function nifti = fetch(obj)
            if ~isfile(obj.CachePath)
                siibra.internal.API.doWebsaveWithLongTimeout( ...
                    obj.CachePath, ...
                    siibra.internal.API.regionMap(...
                    obj.Region.Parcellation.Id, ...
                    obj.Region.Name, ...
                    obj.Space.Id));
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

