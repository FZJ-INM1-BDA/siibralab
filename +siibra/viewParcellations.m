function parcellations = viewParcellations()
%PARCELLATIONS Summary of this function goes here
%   Detailed explanation goes here
    atlases = siibra.viewAtlases();
    parcellations = siibra.items.Parcellation.empty;
    for i = 1:numel(atlases)
        atlas = atlases(i);
        parcellations = cat(2, parcellations, atlas.Parcellations);
    end
        
end

