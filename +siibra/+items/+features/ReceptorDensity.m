classdef ReceptorDensity
    %REZEPTORDENSITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Region siibra.items.Region
        FeatureId string
        Description string
        Name string
        DOI string
        Fingerprints string
    end
    
    methods
        function obj = ReceptorDensity(region, receptorJson)
            obj.Region = region;
            obj.FeatureId = receptorJson.x_id;
            obj.Description = receptorJson.metadata.description;
            obj.Name = receptorJson.metadata.fullName;
            obj.DOI = receptorJson.urls.doi;
        end
        
        function fingerprints = get.Fingerprints(obj)
            fingerprintJson = siibra.internal.API.doWebreadWithLongTimeout( ...
                siibra.internal.API.regionFeature( ...
                obj.Region.Parcellation.Atlas.Id, ...
                obj.Region.Parcellation.Id, ...
                obj.Region.Name, ...
                obj.FeatureId));
            fingerprintStruct = fingerprintJson.data.fingerprints;
            receptors = fieldnames(fingerprintStruct);
            means = arrayfun(@(i) fingerprintStruct.(receptors{i}).mean, 1:numel(receptors));
            stds = arrayfun(@(i) fingerprintStruct.(receptors{i}).std, 1:numel(receptors));
            fingerprints = table(means.', stds.', 'VariableNames', ["Mean fmol/mg", "Std fmol/mg"], 'RowNames', receptors);
        end
    end
end

