function parcellation = getParcellation(atlas_name,parcellation_name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlas = siibra.getAtlas(atlas_name);
    parcellation = atlas.getParcellation(parcellation_name);
end

