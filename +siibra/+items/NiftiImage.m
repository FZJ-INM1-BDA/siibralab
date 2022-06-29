classdef NiftiImage
    %NiftiImage Wrapper around a nifti file in memory
    %   Each instance holds the raw data and the corresponding header.
    %   This class exposes convenience methods to handle the warping
    %   of the voxel data to physical space.
    
    properties
        Data (:, :, :)
        Header (1, 1) 
    end
    
    methods
        function obj = NiftiImage(path)
            %NiftiImage Construct an instance of this class
            %   Reads the data from disk and stores the voxel volume in RAS
            %   orientation.
            header = niftiinfo(path);
            data = niftiread(path);
            
            % The permutation is necessary to align MATLAB indexing
            % with the RAS orientation.
            obj.Data = permute(data, [2, 1, 3]);
            obj.Header = header;
        end
        function normalized = normalizedData(obj)
            normalized = obj.Data;
            if isfloat(normalized)
                if max(normalized(:)) > 1
                    normalized = normalized ./ max(normalized(:));
                end

                normalized = normalized .* 256 ;
            end
            normalized = cast(normalized, 'uint8');
        end
        function outputView = getOutputView(obj)
            ownSize = size(obj.Data);
            transform = obj.Header.Transform;
            outputView = affineOutputView(ownSize, transform, 'BoundsStyle', 'followOutput');
        end
        function warpedImage = getWarpedImage(obj)
            outputView = obj.getOutputView();
            [warpedImage, ~] = imwarp(obj.normalizedData(), obj.Header.Transform, 'OutputView', outputView);
        end
    
        function overlay = getOverlayWarpedRelativeTo(obj, otherNiftiImage)
            referenceObject = otherNiftiImage.getOutputView();
            [overlay, ~] = imwarp(obj.normalizedData(), obj.Header.Transform, 'OutputView', referenceObject);
        end        
    end
end

