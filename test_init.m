siibra = Siibra();
human_atlas = siibra.atlases(1);
parcellation = human_atlas.Parcellations(1);
plot(parcellation.Graph, 'Layout','force')
region = parcellation.getRegion("Ch 123 (Basal Forebrain) left");
spaces = region.SpacesToUrl.keys;