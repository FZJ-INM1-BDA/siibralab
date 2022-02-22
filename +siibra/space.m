function space = space(atlasName,spaceName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlas = siibra.atlas(atlasName);
    space = atlas.space(spaceName);
end

