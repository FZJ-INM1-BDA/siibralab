classdef Region < handle
    properties
        Name string
        NormalizedName string
        Parcellation (1, :) siibra.items.Parcellation
        LabelIndex (1, :) uint32
        ContinuousMaps (1, :) siibra.items.maps.ContinuousMap
        Spaces (1, :) siibra.items.Space
        Parent (1, 1) % Region
        Children (1, :) % Region
    end
    methods
        function region = Region(name, parcellation, labelIndex, dataset_specs)
            region.Name = name;
            region.Parcellation = parcellation;
            region.LabelIndex = labelIndex;

            continuousMaps = siibra.items.maps.ContinuousMap.empty;
            spaces = siibra.items.Space.empty;
            % parse dataset_specs for this region
            if ~isempty(dataset_specs)
                for i = 1:numel(dataset_specs)
                    if iscell(dataset_specs)
                        specs = dataset_specs{i};
                    else
                        specs = dataset_specs(i);
                    end
                    if isfield(specs, "space_id")
                        for spaceIndex = 1:numel(parcellation.Spaces)
                             space = parcellation.Spaces(spaceIndex);
                             if specs.space_id == space.Id
                                spaces(end + 1) = space;
                                if specs.map_type == "continuous"
                                    continuousMaps(end +1) = siibra.items.maps.ContinuousMap( ...
                                    region, ...
                                    space, ...
                                    specs.url);
                                end
                             end
                        end
                    end
                end
            end

            region.ContinuousMaps = continuousMaps;
            region.Spaces = spaces;
        end
        function normalizedRegionName = get.NormalizedName(obj)
            normalizedRegionName = strrep(obj.Name, " ", "");
            normalizedRegionName = strrep(normalizedRegionName, "/", "-");
        end
        function space = space(obj, spaceName)
            spaceNames = {obj.Spaces.Name};
            spaceIndex = siibra.internal.fuzzyMatching(spaceName, spaceNames);
            space = obj.Spaces(spaceIndex);
        end
        function children = get.Children(obj)
            children = obj.Parcellation.getChildRegions(obj.Name);
        end
        function parent = get.Parent(obj)
            parent = obj.Parcellation.getParentRegion(obj.Name);
        end
        function map = continuousMap(obj, spaceName)
            found_space = false;
            for i = 1:numel(obj.ContinuousMaps)
                if strcmp(obj.ContinuousMaps(i).Space.Name, spaceName)
                    found_space = true;
                    map = obj.ContinuousMaps(i);
                end
            end
            if ~found_space
                error("Could not find probability map for this space!");
            end
        end
        function mask = regionMask(obj, spaceName)
            found_space = false;
            for i = 1:numel(obj.Parcellation.ParcellationMaps)
                if strcmp(obj.Parcellation.ParcellationMaps(i).Space.Name, spaceName)
                    found_space = true;
                    cached_path = fullfile("+siibra", "cache", "region_cache",obj.NormalizedName + "_" + obj.Parcellation.ParcellationMaps(i).Space.NormalizedName + "_mask.nii.gz");
                    if ~isfile(cached_path)
                        parcellationMap = obj.Parcellation.ParcellationMaps(i);
                        labeledMap = parcellationMap.fetch(1); % todo how do I know in which hemisphere I am?
                        segmentation = labeledMap.loadData();
                        mask = cast(segmentation == obj.LabelIndex, "uint16");
                        maskHeader = labeledMap.Header;
                        maskHeader.Datatype = 'uint16';
                        [filePath, fileName, ~] = fileparts(cached_path);
                        fileNameWithoutExtension = fullfile(filePath, fileName);
                        niftiwrite(mask, fileNameWithoutExtension, maskHeader, "Compressed",true)
                    end
                    mask = siibra.items.NiftiImage(cached_path);
                end
            end
            if ~found_space
                error("Could not find labeled map for this space!");
            end
        end
    end
end