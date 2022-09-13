function atlases = initAtlases(clear_cache)
arguments
    clear_cache (1, 1) logical
end
% Entrypoint for building atlases, parcellations, etc.
    cached_file_name = siibra.internal.cache("atlases.mat");
    if clear_cache || ~isfile(cached_file_name)
        disp("Fetching metadata from the siibra server...")
        atlases_json = siibra.internal.API.atlases();
        atlases = arrayfun(@(j) siibra.items.Atlas(j), atlases_json);
        save(cached_file_name, 'atlases');
    else
        load(cached_file_name, 'atlases');
    end
end