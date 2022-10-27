function overviewTable = spaceOverview()
    spaces = siibra.spaces();
    overviewTable = table([spaces.Name].', [spaces.AtlasName].', [spaces.VolumeType].', [spaces.Format].', 'VariableNames', ["Space", "Atlas", "VolumeType", "Format"]);
end

