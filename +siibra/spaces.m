function spaces = spaces()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlases = siibra.atlases();
    spaces = siibra.core.Space.empty;
    for i = 1:numel(atlases)
        atlas = atlases(i);
        spaces = cat(2, spaces, atlas.spaces);
    end
end

