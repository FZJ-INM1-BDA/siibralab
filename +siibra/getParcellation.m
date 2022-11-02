function parcellation = getParcellation(atlasName, parcellationName)
arguments
    atlasName (1, 1) string
    parcellationName (1, 1) string
end
% Get parcellation by atlas name and parcellation name
%   First the altas is selected and then all available parcellations for
%   the selected atlas are searched.
    atlas = siibra.getAtlas(atlasName);
    parcellation = atlas.getParcellation(parcellationName);
end

