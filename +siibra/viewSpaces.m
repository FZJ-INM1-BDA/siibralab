function spaces = viewSpaces()
% List all available spaces
    atlases = siibra.viewAtlases();
    spaces = [atlases.Spaces];
end

