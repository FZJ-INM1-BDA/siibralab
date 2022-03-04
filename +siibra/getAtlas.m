function atlas = getAtlas(atlas_name)
arguments
    atlas_name (1, 1) string
end
% Construct atlas by name
%   Detailed explanation goes here
    atlases = siibra.internal.initAtlases(false);
    atlas = atlases(siibra.internal.fuzzyMatching(atlas_name, [atlases.Name]));
end


