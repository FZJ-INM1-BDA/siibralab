function parcellations = parcellations()
% List all available parcellations
    atlases = siibra.atlases();
    parcellations = [atlases.Parcellations];
        
end

