function space = getSpace(atlasName, spaceName)
arguments
    atlasName (1, 1) string
    spaceName (1, 1) string
end
% Get space by atlas and space name
%   First, the atlas is selected and then all spaces of the atlas are
%   searched.
    atlas = siibra.getAtlas(atlasName);
    space = atlas.getSpace(spaceName);
end

