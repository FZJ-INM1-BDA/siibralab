function parcellations = viewParcellations()
% List all available parcellations
    atlases = siibra.viewAtlases();
    parcellations = [atlases.Parcellations];
        
end

