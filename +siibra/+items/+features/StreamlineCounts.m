classdef StreamlineCounts
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parcellation (1, :) siibra.items.Parcellation
        Name (1, 1) string
        Cohort (1, 1) string
        Subject (1, 1) string
        Authors (1, :) string
        Description (1, 1) string
        % Citation (1, 1) string
        Matrix uint8
        FeatureId (1, 1) string
    end
    
    methods
        function obj = StreamlineCounts(parcellation, featureJson)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Parcellation = parcellation;
            obj.Name = featureJson.name;
            obj.Cohort = featureJson.cohort;
            obj.Subject = featureJson.subject;
            obj.Authors = featureJson.authors;
            obj.Description = featureJson.description;
            % obj.Citation = featureJson.citation;
            obj.FeatureId = featureJson.x_id;

        end
        function connectivityMatrix = get.Matrix(obj)
            featureIdNormalized = obj.FeatureId.replace("/", "-");
            matrixCachePath = siibra.internal.cache(featureIdNormalized + ".mat", "parcellation_features");
            if ~isfile(matrixCachePath)
                matrixJson = siibra.internal.API.doWebreadWithLongTimeout( ...
                    siibra.internal.API.parcellationFeature( ...
                    obj.Parcellation.Atlas.Id, ...
                    obj.Parcellation.Id, ...
                    obj.FeatureId) ...
                    );
                encodedMatrix = matrixJson.matrix.content;
                dim1 = matrixJson.matrix.x_height;
                dim2 = matrixJson.matrix.x_width;
                decodedMatrix = matlab.net.base64decode(encodedMatrix);
    
                % write decoded and compressed matrix to file
                compressedMatrixCachePath = siibra.internal.cache(featureIdNormalized + ".bin.gzip", "parcellation_features");
                f = fopen(compressedMatrixCachePath, "w");
                fwrite(f, decodedMatrix)
                fclose(f);
    
                % decompress file and read it again
                binaryMatrixCachePath = siibra.internal.cache(featureIdNormalized + ".bin", "parcellation_features");
                gunzip(compressedMatrixCachePath, siibra.internal.cache("", "parcellation_features"))
                f = fopen(binaryMatrixCachePath, "r");
                decompressedMatrix = fread(f, matrixJson.matrix.dtype);
                fclose(f);

                % delete intermediate files
                delete(compressedMatrixCachePath)
                delete(binaryMatrixCachePath)

                matrix = reshape(decompressedMatrix, dim1, dim2);
             
                connectivityMatrix = array2table(matrix);
                columnNameLengths = cellfun(@(n) strlength(n), matrixJson.columns);
                columnNamesToBeTrimmed = matrixJson.columns(columnNameLengths > 63);
                matrixJson.columns(columnNameLengths > 63) = cellfun(@(n) n(1:63), columnNamesToBeTrimmed, 'UniformOutput',false);
                connectivityMatrix.Properties.VariableNames = matrixJson.columns;
                connectivityMatrix.Properties.RowNames = matrixJson.columns;
                % cache matrix
                save(matrixCachePath, "connectivityMatrix");
            end
            connectivityMatrix = load(matrixCachePath, "connectivityMatrix").connectivityMatrix;
        end
    end
end

