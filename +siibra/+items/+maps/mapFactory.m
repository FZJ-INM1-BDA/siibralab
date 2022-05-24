function map = mapFactory(region, space, url, type)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if type == "continuous"
    map = siibra.items.maps.ContinuousMap(region, space, url);
elseif type == "labeled" || type== "labelled"
    map = siibra.items.maps.LabeledMap(region, space, url);
else
    error("unknown map type");
end

