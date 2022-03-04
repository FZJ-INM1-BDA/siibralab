function spaces = viewSpaces()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlases = siibra.viewAtlases();
    spaces = siibra.items.Space.empty;
    for i = 1:numel(atlases)
        atlas = atlases(i);
        spaces = cat(2, spaces, atlas.Spaces);
    end
end

