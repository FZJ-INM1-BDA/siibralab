function space = getSpace(atlasName, spaceName)
arguments
    atlasName (1, 1) string
    spaceName (1, 1) string
end
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlas = siibra.getAtlas(atlasName);
    space = atlas.getSpace(spaceName);
end

