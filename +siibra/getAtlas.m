function atlas = getAtlas(atlasName)
arguments
    atlasName (1, 1) string
end
% Get atlas by name
%   The provided atlas name will be fuzzy matched against all available
%   atlas names.
    atlases = siibra.internal.initAtlases(false);
    atlas = atlases(siibra.internal.fuzzyMatching(atlasName, [atlases.Name]));
end


