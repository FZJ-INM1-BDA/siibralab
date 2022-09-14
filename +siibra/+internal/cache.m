function cacheFilePath = cache(filename, category)
%CACHE Computes the absolute path to the cached file
arguments
    filename string
    category string = ""
end
    [scriptFilePath, ~, ~] = fileparts(mfilename("fullpath"));
    cacheFilePath = fullfile(scriptFilePath, "..", "cache", category, filename);
end

