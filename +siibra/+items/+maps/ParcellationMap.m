classdef ParcellationMap < handle
    %ParcellationMap The ParcellationMap fetches the parcellation map for 
    % a given space. There can be more than one nifti in the case of
    % separate hemispheres.
    
    properties
        Parcellation siibra.items.Parcellation
        Space siibra.items.Space
        CachePath string
    end
    
    methods
        function obj = ParcellationMap(parcellation, space)
            obj.Parcellation = parcellation;
            obj.Space = space;
        end
        
        function cachePath = get.CachePath(obj)
            cachePath = siibra.internal.cache( ...
                strcat( obj.Parcellation.Name, "_", obj.Space.Name), ...
                "parcellation_maps");
        end

        function nifti = fetch(obj)
            if ~isfolder(obj.CachePath)
                siibra.iternal.API.doWebsaveWithLongTimeout( ...
                    obj.CachePath + ".zip", ...
                    siibra.internal.API.parcellationMap( ...
                        obj.Parcellation.Atlas.Id, ...
                        obj.Space.Id, ...
                        obj.Parcellation.Id) ...
                    )
                unzip(obj.CachePath + ".zip", obj.CachePath)
            end
            files = dir(obj.CachePath + "/*.nii.gz");
            nifti = arrayfun(@(file) siibra.items.NiftiImage( ...
                fullfile(obj.CachePath, file.name)), ...
                files);
        end
    end
end

