function spaces = viewSpaces()
% List all available spaces
    atlases = siibra.atlases();
    spaces = [atlases.Spaces];
end

