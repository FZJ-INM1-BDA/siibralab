function atlases = initAtlases(clear_cache)
    cached_file_name = '+siibra/cache/atlases.mat';
    if clear_cache || ~isfile(cached_file_name)
        apiEndpoint = "https://siibra-api-latest.apps-dev.hbp.eu/v1_0/";
        atlases_json = webread(apiEndpoint + "atlases");
        atlases = siibra.core.Atlas.empty;
        for atlas_row = 1:numel(atlases_json)
            atlas = siibra.core.Atlas(atlases_json(atlas_row));
            atlases(end + 1) = atlas;
        end
        save(cached_file_name, 'atlases');
    else
        load(cached_file_name, 'atlases');
    end
end