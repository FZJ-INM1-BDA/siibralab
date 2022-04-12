classdef NiftiImage
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data (:, :, :) uint8
        Header (1, 1) 
    end
    
    methods
        function obj = NiftiImage(path)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            header = niftiinfo(path);
            data = niftiread(path);
            if isfloat(data)
                if max(data(:)) > 1
                    data = data ./ max(data(:));
                end
                data = cast(data .* 256, 'uint8') ;
            end
            obj.Data = data;
            obj.Header = header;

            if ~obj.Header.Transform.isTranslation
                error "NiftiImage does support translation only!";
            end
        end
        function offset = offsetRelativeTo(obj, otherNiftiImage)
            from_this_voxel_to_other_voxel = inv(otherNiftiImage.Header.Transform.T) * obj.Header.Transform.T;
            % fix floating point issues
            from_this_voxel_to_other_voxel(4, 4) = 1;
            from_this_voxel_to_other_voxel = affine3d(from_this_voxel_to_other_voxel);
           
            offset = cast(from_this_voxel_to_other_voxel.transformPointsForward([0, 0, 0]), 'double');
        end
        
    end
end

