classdef API
    % The API class holds all the api calls in one place
    
    properties (Constant=true)
        Endpoint = "https://siibra-api-stable.apps.hbp.eu/v1_0/"
        EndpointV2 = "https://siibra-api-stable.apps.hbp.eu/v2_0"
        EndpointV3 = "https://siibra-api-stable.apps.hbp.eu/v3_0"
    end

    methods (Static)
        function link = absoluteLink(relativeLink)
            link = siibra.internal.API.Endpoint + relativeLink;
        end
        function link = absoluteLinkV2(relativeLink)
            link = siibra.internal.API.EndpointV2 + relativeLink;
        end
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
            result = websave( ...
                path, ...
                absoluteLink, ...
                options);
        end
        function atlases = atlases()
            absoluteLink = siibra.internal.API.absoluteLink("atlases"); 
            atlases = siibra.internal.API.doWebreadWithLongTimeout( ...
                absoluteLink);
        end
        function absoluteLink = regionInfoForSpace(atlasId, parcellationId, regionName, spaceId)
            relativeLink = "atlases/" + atlasId + ...
                            "/parcellations/" + parcellationId + ...
                            "/regions/" + regionName + ...
                            "?space_id=" + spaceId;
            absoluteLink = siibra.internal.API.absoluteLink(relativeLink);
        end
        
        function absoluteLink = regionMap(parcellationId, regionName, spaceId)
            relativeLink = "/map/statistical_map.nii.gz" + ...
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
            relativeLink = "/map/labelled_map.nii.gz?parcellation_id=" + parcellationId + ...
                            "&space_id=" + spaceId;
            if ~isempty(regionName)
                relativeLink = relativeLink + "&region_id=" + regionName;
            end
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink); 
        end

        function absoluteLink = templateForParcellationMap(spaceId, parcellationId)
            arguments
                spaceId string
                parcellationId string
            end
            relativeLink = "/map/resampled_template?parcellation_id=" + parcellationId + ...
                            "&space_id=" + spaceId;
            absoluteLink = siibra.internal.API.absoluteLinkV3(relativeLink); 
        end

        function absoluteLink = featuresPageForParcellation(atlasId, parcellationId, page, size)
            relativeLink = "/atlases/" + atlasId + ...
                            "/parcellations/" + parcellationId + ...
                            "/features?page=" + page + ...
                            "&size=" + size;
            absoluteLink = siibra.internal.API.absoluteLinkV2(relativeLink);
        end
        function featureList = featuresForParcellation(atlasId, parcellationId)
            featureList = {};
            page = 1;
            size = 100;
            firstPage = siibra.internal.API.doWebreadWithLongTimeout( ...
                siibra.internal.API.featuresPageForParcellation( ...
                atlasId, ...
                parcellationId, ...
                page, ...
                size)...
            );
            totalElements = firstPage.total;
            featureList{1} = firstPage.items;
            processedElements = numel(firstPage.items);
            while processedElements < totalElements
                page = page + 1;
                nextPage = siibra.internal.API.doWebreadWithLongTimeout( ...
                    siibra.internal.API.featuresPageForParcellation( ...
                        atlasId, ...
                        parcellationId, ...
                        page, ...
                        size)...
                );
                featureList{page} = nextPage.items;
                processedElements = processedElements + numel(nextPage.items);
            end
            featureList = cat(1, featureList{:});
        end
        function absoluteLink = parcellationFeature(atlasId, parcellationId, featureId)
            % get specific feature by feature id.
            relativeLink = "/atlases/" + atlasId + ...
                            "/parcellations/" + parcellationId + ...
                            "/features/" + featureId;
            absoluteLink = siibra.internal.API.absoluteLinkV2(relativeLink);
        end
        function absoluteLink = featuresForRegion(atlasId, parcellationId, regionName)
            relativeLink = "/atlases/" +atlasId + ...
                            "/parcellations/" + parcellationId + ...
                            "/regions/" + regionName + "/features";
            absoluteLink = siibra.internal.API.absoluteLinkV2(relativeLink);
        end
        function absoluteLink = regionFeature(atlasId, parcellationId, regionName, featureId)
            relativeLink = "/atlases/" +atlasId + ...
                            "/parcellations/" + parcellationId + ...
                            "/regions/" + regionName + ...
                            "/features/" + featureId;
            absoluteLink = siibra.internal.API.absoluteLinkV2(relativeLink);
        end
    end
    
end

