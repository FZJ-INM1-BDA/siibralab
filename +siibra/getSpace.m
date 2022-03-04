function space = getSpace(atlasName,spaceName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlas = siibra.getAtlas(atlasName);
    space = atlas.getSpace(spaceName);
end

