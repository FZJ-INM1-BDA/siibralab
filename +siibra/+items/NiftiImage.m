classdef NiftiImage
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data (:, :, :)
        Header (1, 1) 
    end
    
    methods
        function obj = NiftiImage(path)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
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

