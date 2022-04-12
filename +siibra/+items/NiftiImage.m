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
                data = data .* 256 ;
            end
            obj.Data = cast(data, 'uint8');
            obj.Header = header;

            if ~obj.Header.Transform.isTranslation
                error("NiftiImage does support translation only!");
            end
        end
        function offset = offsetRelativeTo(obj, otherNiftiImage)
            from_this_voxel_to_other_voxel = inv(otherNiftiImage.Header.Transform.T) * obj.Header.Transform.T;
            % fix floating point issues
            from_this_voxel_to_other_voxel(4, 4) = 1;
            from_this_voxel_to_other_voxel = affine3d(from_this_voxel_to_other_voxel);
           
            offset = cast(from_this_voxel_to_other_voxel.transformPointsForward([0, 0, 0]), 'double');
        end
        function overlay = getOverlayRelativeTo(obj, otherNiftiImage)
            % Get overlay relative to given nifti image
            %   returned overlay has the same shape as the input nifti.

            % Currently the nifti images support
            % translation matrices only
            offset = obj.offsetRelativeTo(otherNiftiImage);
            obj_start = max(-offset, 1);
            other_start = max(offset, 1);
            obj_end = min((size(obj.Data) - obj_start), (size(otherNiftiImage.Data)-other_start)) + 1;
            obj_start = cast(obj_start, 'uint32');
            obj_end = cast(obj_end, 'uint32');
            other_start = cast(other_start, 'uint32');
            obj_cutout = obj.Data(obj_start(1):obj_end(1), obj_start(2):obj_end(2), obj_start(3):obj_end(3));
            overlay = zeros(size(otherNiftiImage.Data), class(obj_cutout));
            obj_cutout_size = obj_end - obj_start + 1;
            
            overlay( ...
                other_start(1):obj_cutout_size(1), ...
                other_start(2):obj_cutout_size(2), ...
                other_start(3):obj_cutout_size(3)) = obj_cutout;
        end
        
    end
end

