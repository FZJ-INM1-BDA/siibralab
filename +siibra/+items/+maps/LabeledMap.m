classdef LabeledMap < siibra.items.maps.ParcellationMap
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = LabeledMap(region, space, url)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj@siibra.items.maps.ParcellationMap(region, space, url);
        end
        
    end
end

