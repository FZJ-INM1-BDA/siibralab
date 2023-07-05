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
                replace(obj.Parcellation.Name, " ", "") + "_" + obj.Space.Name + ".nii.gz", ...
                "parcellation_maps");
        end

        function nifti = fetch(obj)
            if ~isfile(obj.CachePath)
                siibra.internal.API.doWebsaveWithLongTimeout( ...
                    obj.CachePath, ...
                    siibra.internal.API.parcellationMap( ...
                        obj.Space.Id, ...
                        obj.Parcellation.Id) ...
                    )
            end
            nifti = siibra.items.NiftiImage(obj.CachePath);
        end
    end
end

