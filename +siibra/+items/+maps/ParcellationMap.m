classdef ParcellationMap < matlab.mixin.Heterogeneous & handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Region siibra.items.Region
        Space siibra.items.Space
        URL string
    end
    
    methods
        function obj = ParcellationMap(region, space, url)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Region = region;
            obj.Space = space;
            obj.URL = url;
        end
    end
    %methods(Abstract)
    %    getDataRelativeToTemplate(obj);
    %end
end

