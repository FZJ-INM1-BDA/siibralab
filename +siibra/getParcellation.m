function parcellation = getParcellation(atlas_name, parcellation_name)
arguments
    atlas_name (1, 1) string
    parcellation_name (1, 1) string
end
% Get parcellation by atlas name and parcellation name
%   First the altas is selected and then all available parcellations for
%   the selected atlas are searched.
    atlas = siibra.getAtlas(atlas_name);
    parcellation = atlas.getParcellation(parcellation_name);
end

