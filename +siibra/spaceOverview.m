function overviewTable = spaceOverview()
    spaces = siibra.viewSpaces();
    overviewTable = table([spaces.Name].', [spaces.AtlasName].', [spaces.VolumeType].', [spaces.Format].', 'VariableNames', ["Space", "Atlas", "VolumeType", "Format"]);
end

