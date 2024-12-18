function overviewTable = spaceOverview()
    spaces = siibra.spaces();
    overviewTable = table([spaces.Name].', [spaces.AtlasName].', 'VariableNames', ["Space", "Atlas"]);
end

