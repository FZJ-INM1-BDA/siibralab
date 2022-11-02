function atlases = initAtlases(clearCache)
arguments
    clearCache (1, 1) logical
end
% Entrypoint for building atlases, parcellations, etc.
    cachedFileName = siibra.internal.cache("atlases.mat");
    if clearCache || ~isfile(cachedFileName)
        disp("Fetching metadata from the siibra server...")
        atlasesJson = siibra.internal.API.atlases();
        atlases = arrayfun(@(j) siibra.items.Atlas(j), atlasesJson);
        save(cachedFileName, 'atlases');
    else
        load(cachedFileName, 'atlases');
    end
end