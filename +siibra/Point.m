classdef Point
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Space siibra.items.Space
        Position (1, 3) double
    end
    
    methods
        function obj = Point(position, space)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Position = position;
            obj.Space = space;
        end
    end
end

