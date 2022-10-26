function overviewTable = atlasOverview()
%ATLASOVERVIEW Creates an overview table of the atlases
atlases = siibra.viewAtlases();
overviewTable = table([atlases.Name].', [cellfun(@numel, {atlases.Parcellations})].', [cellfun(@numel, {atlases.Spaces})].', 'VariableNames', ["Atlas", "Number of Parcellations", "Number of Spaces"]);
end

