function parcellation = parcellation(atlas_name,parcellation_name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    atlas = siibra.atlas(atlas_name);
    parcellation = atlas.parcellation(parcellation_name);
end

