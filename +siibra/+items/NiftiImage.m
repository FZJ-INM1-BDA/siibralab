classdef NiftiImage < handle
    %NiftiImage Wrapper around a nifti file
    %   Each instance holds the path to the data and the corresponding header.
    %   This class exposes convenience methods to handle the warping
    %   of the voxel data to physical space.
    
    properties
        Header (1, 1) 
        FilePath 
        Size
    end
    
    methods
        function obj = NiftiImage(path)
            %NiftiImage Construct an instance of this class
            %   Reads the header from disk.
            obj.FilePath = path;
            obj.Header = niftiinfo(path);
        end
        function size = get.Size(obj)
            size = obj.Header.ImageSize; 
        end
        function data = loadData(obj)
            data = niftiread(obj.FilePath);
        end
        function normalized = normalizedData(obj)
            normalized = single(obj.loadData());
            minValue = min(normalized(:));
            maxValue = max(normalized(:));
            range = single(maxValue - minValue);
            normalized = (normalized - minValue) ./ range;
            normalized = normalized .* 254 + 1;
            normalized = cast(normalized, 'uint8');
        end
        function outputView = getOutputView(obj)
            ownSize = obj.Header.ImageSize;
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

