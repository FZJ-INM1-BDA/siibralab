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
            dataset_specs = regionMapInfoJson.x_dataset_specs;
            if ~iscell(dataset_specs)
                dataset_specs = num2cell(dataset_specs);
            end
            datasetIndex = find( ...
                cell2mat( ...
                cellfun( ...
                @(dataset) ...
                isequal(dataset.x_type, 'minds/core/dataset/v1.0.0'), ...
                dataset_specs, ...
                'UniformOutput', false)));
            if isempty(datasetIndex)
                obj.Name = "Not available";
                obj.Description = "Not available";
                obj.DOI = string.empty;
            else
                obj.Name = regionMapInfoJson.x_dataset_specs{datasetIndex}.name;
                obj.Description = regionMapInfoJson.x_dataset_specs{datasetIndex}.description;
                obj.DOI = regionMapInfoJson.x_dataset_specs{datasetIndex}.urls.doi;
            end
        end
        
        function cachePath = get.CachePath(obj)
            filename = strcat(obj.Region.NormalizedName, obj.Space.NormalizedName, "_continuous.nii.gz");
            cachePath = siibra.internal.cache(filename, "region_cache");
        end
        function nifti = fetch(obj)
            if ~isfile(obj.CachePath)
                siibra.internal.API.doWebsaveWithLongTimeout( ...
                    obj.CachePath, ...
                    siibra.internal.API.regionMap(...
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

