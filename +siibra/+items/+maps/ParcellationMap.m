classdef ParcellationMap < matlab.mixin.Heterogeneous & handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        Atlas (1, :) siibra.items.Atlas
        Parcellation (1, :) siibra.items.Parcellation
        Space (1, :) siibra.items.Space
        URL string
    end
    
    methods
        function obj = ParcellationMap(atlas, parcellation, space)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Atlas = atlas;
            obj.Parcellation = parcellation;
            obj.Space = space;
        end

        function url = get.URL(obj)
            % /atlases/{atlas_id}/spaces/{space_id}/parcellation_maps?parcellation_id={parcellation_id}
            url = siibra.internal.API.absoluteLink("atlases/" + obj.Atlas.Id + "/spaces/" + obj.Space.Id + "/parcellation_maps?parcellation_id=" + obj.Parcellation.Id);
        end
        function nifti = fetch(obj, index)
            arguments
                obj;
                index(1,1) uint32 {mustBeFinite} = 1;
            end
            cached_path = "+siibra/cache/parcellation_maps/" + obj.Parcellation.Name + "_" + obj.Space.Name;
            if ~isfolder(cached_path)
                options = weboptions;
                options.Timeout = 30;
                websave(cached_path + ".zip", obj.URL, options);
                unzip(cached_path + ".zip", cached_path)
            end
            files = dir(cached_path + "/*.nii.gz");
            nifti = siibra.items.NiftiImage(cached_path + "/" + files(index).name);

        end
    end
end

