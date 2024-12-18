classdef ReceptorDensity
    %REZEPTORDENSITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Region siibra.items.Region
        Id string
        Description string
        Name string
        Fingerprint string
        Unit string
    end
    
    methods
        function obj = ReceptorDensity(region, receptorJson)
            obj.Region = region;
            obj.Id = receptorJson.id;
            obj.Description = receptorJson.description;
            obj.Name = receptorJson.name;
            obj.Unit = "fmol/mg";
        end
        
        function fingerprints = get.Fingerprint(obj)
            fingerprintJson = siibra.internal.API.doWebreadWithLongTimeout( ...
                siibra.internal.API.tabularFeature( ...
                obj.Region, ...
                obj.Id));
            data = fingerprintJson.data.data;
            column_names = fingerprintJson.data.columns;
            row_names = fingerprintJson.data.index;
            fingerprints = array2table(data, 'VariableNames', column_names, 'RowNames', row_names );
        end
    end
end

