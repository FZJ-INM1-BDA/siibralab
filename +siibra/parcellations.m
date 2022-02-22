function parcellations = parcellations()
%PARCELLATIONS Summary of this function goes here
%   Detailed explanation goes here
    atlases = siibra.atlases();
    parcellations = siibra.core.Parcellation.empty;
    for i = 1:numel(atlases)
        atlas = atlases(i);
        parcellations = cat(2, parcellations, atlas.parcellations);
    end
        
end

