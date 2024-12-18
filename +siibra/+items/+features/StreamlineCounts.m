classdef StreamlineCounts
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parcellation (1, :) siibra.items.Parcellation
        Name (1, 1) string
        Cohort (1, 1) string
        Subjects (1, :) string
        Description (1, 1) string
        FeatureId (1, 1) string
    end
    
    methods
        function obj = StreamlineCounts(parcellation, featureJson)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Parcellation = parcellation;
            obj.Name = featureJson.name;
            obj.Cohort = featureJson.cohort;
            obj.Subjects = featureJson.subjects;
            obj.Description = featureJson.description;
            obj.FeatureId = featureJson.id;

        end
        function connectivityMatrix = connectivityMatrixForSubject(obj, subject)
            response = siibra.internal.API.doWebreadWithLongTimeout( ...
                siibra.internal.API.streamlineCountsForSubject( ...
                obj, subject ...
                ) ...
            );
            matrixStruct = getfield(response.matrices, "x" + subject);
            connectivityMatrix = array2table(matrixStruct.data, "VariableNames", {matrixStruct.columns.name}, 'RowNames', {matrixStruct.index.name});
        end
        function connectivityMatrix = averagedConnectivityMatrix(obj)
            % leaving the subject field empty gives us the averaged matrix
            response = siibra.internal.API.doWebreadWithLongTimeout( ...
                siibra.internal.API.streamlineCountsForSubject( ...
                obj, string.empty ...
                ) ...
            );
            matrixStruct = response.matrices.x_average;
            connectivityMatrix = array2table(matrixStruct.data, "VariableNames", {matrixStruct.columns.name}, 'RowNames', {matrixStruct.index.name});
        end
    end
end

