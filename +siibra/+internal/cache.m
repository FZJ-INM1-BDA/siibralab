function cacheFilePath = cache(filename, category)
% Computes the absolute path to the cached file
%   The cache resides relative the the library directory.
%   This is useful as this way, multiple projects are able to
%   make use of the same cache.
arguments
    filename string
    category string = ""
end
    [scriptFilePath, ~, ~] = fileparts(mfilename("fullpath"));
    cacheFilePath = fullfile(scriptFilePath, "..", "cache", category, filename);
end

