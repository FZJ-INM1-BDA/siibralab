classdef API
    % The API class holds all the api calls in one place
    
    properties (Constant=true)
        %Endpoint = "https://siibra-api-stable.apps.hbp.eu/v1_0/"
        %EndpointV2 = "https://siibra-api-stable.apps.hbp.eu/v2_0"
        EndpointV3 = "https://siibra-api-stable.apps.hbp.eu/v3_0/"
    end

    methods (Static)
        %function link = absoluteLink(relativeLink)
        %    link = siibra.internal.API.Endpoint + relativeLink;
        %end
        %function link = absoluteLinkV2(relativeLink)
        %    link = siibra.internal.API.EndpointV2 + relativeLink;
        %end
        function link = absoluteLinkV3(relativeLink)
            link = siibra.internal.API.EndpointV3 + relativeLink;
        end
        function result = doWebreadWithLongTimeout(absoluteLink)
            options = weboptions;
            options.Timeout = 30;
            result = webread( ...
                absoluteLink, ...
                options);
        end
        function result = doWebsaveWithLongTimeout(path, absoluteLink)
            options = weboptions;
            options.Timeout = 30;
            try
                result = websave( ...
                    path, ...
                    absoluteLink, ...
                    options);
            catch Exception
                delete(path)
                throw(Exception) 
            end
        end

        function parameterString = parametersToString(parameters)
            parameterString = "?" + strjoin(parameters, "&");
        end

        function items = collectItemsAcrossPages(absoluteLink, parameters)
            if nargin < 2
                parameters = [];
            end            
            
            first_result = siibra.internal.API.doWebreadWithLongTimeout(absoluteLink + ...
                siibra.internal.API.parametersToString([parameters, "page=1"]));
            items = first_result.items;
            page = first_result.page;
            pages = first_result.pages;
            while page < pages
                page = page + 1;
                next_result = siibra.internal.API.doWebreadWithLongTimeout(absoluteLink ...
                    + siibra.internal.API.parametersToString([parameters, "page=" + page]));
                items = [items; next_result.items];
            end

        end

        function atlasJsons = atlases()
            absoluteLink = siibra.internal.API.absoluteLinkV3("atlases"); 
            atlasJsons = siibra.internal.API.collectItemsAcrossPages( ...
                absoluteLink);
        end

        function spaceJson = space(spaceId)
            absoluteLink = siibra.internal.API.absoluteLinkV3("spaces/" + spaceId); 
            spaceJson = siibra.internal.API.doWebreadWithLongTimeout(absoluteLink);
        end

        function parcellationJson = parcellation(parcellationId)
            absoluteLink = siibra.internal.API.absoluteLinkV3("parcellations/" + parcellationId); 
            parcellationJson = siibra.internal.API.doWebreadWithLongTimeout(absoluteLink);
        end

        function regionsJson = regions(parcellationId)
            absoluteLink = siibra.internal.API.absoluteLinkV3("regions");
            parameters = "parcellation_id=" + parcellationId;
            regionsJson = siibra.internal.API.collectItemsAcrossPages( ...
                absoluteLink, parameters);
        end

        function absoluteLink = regionInfoForSpace(parcellationId, regionName, spaceId)
            relativeLink = "map/statistical_map.info.json" + ...
                            "?parcellation_id=" + parcellationId + ...
                            "&region_id=" + regionName + ... 
                            "&space_id=" + spaceId;
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
        end
        
        function absoluteLink = regionMap(parcellationId, regionName, spaceId)
            relativeLink = "map/statistical_map.nii.gz" + ...
                            "?parcellation_id=" + parcellationId + ...
                            "&space_id=" + spaceId + ...
                            "&region_id=" + regionName;
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
        end
        
        function absoluteLink = parcellationMap(spaceId, parcellationId, regionName)
            arguments
                spaceId string
                parcellationId string
                regionName string = string.empty
            end
            relativeLink = "map/labelled_map.nii.gz?parcellation_id=" + parcellationId + ...
                            "&space_id=" + spaceId;
            if ~isempty(regionName)
                relativeLink = relativeLink + "&region_id=" + regionName;
            end
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink); 
        end

        function absoluteLink = templateForParcellationMap(parcellationId, spaceId)
            arguments
                parcellationId string
                spaceId string
            end
            relativeLink = "map/resampled_template?parcellation_id=" + parcellationId + ...
                            "&space_id=" + spaceId;
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink); 
        end

        function features = featuresForRegion(region)
            relativeLink = "regions/" + region.Name + "/features";
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
            parameters = "parcellation_id=" + region.Parcellation.Id;
            features = siibra.internal.API.collectItemsAcrossPages(absoluteLink, parameters);
        end
        function absoluteLink = tabularFeature(region, featureId)
            relativeLink = "feature/Tabular/" + featureId + ...
                            "?parcellation_id=" + region.Parcellation.Id + ...
                            "&region_id=" + region.Name;
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
        end
        function features = regionalConnectivity(parcellation, type)
            relativeLink = "feature/RegionalConnectivity";
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
            parameters = ["parcellation_id=" + parcellation.Id, "type=" + type];
            features = siibra.internal.API.collectItemsAcrossPages(absoluteLink, parameters);
        end
        function absoluteLink = streamlineCountsForSubject(streamlineCounts, subject)
            relativeLink = "feature/RegionalConnectivity/" + streamlineCounts.FeatureId + ...
                "?parcellation_id=" + streamlineCounts.Parcellation.Id + ...
                "&type=StreamlineCounts";
            
            if ~isempty(subject)
                relativeLink = relativeLink + "&subject=" + subject;
            end
                
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
        end

        function downloadFeature(path, featureId)
            relativeLink = "feature/" + featureId + "/download";
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink);
            siibra.internal.API.doWebsaveWithLongTimeout(path, absoluteLink);
        end


    end
    
end

