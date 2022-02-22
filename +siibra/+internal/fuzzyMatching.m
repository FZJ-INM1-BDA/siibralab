function matchedIndex = fuzzyMatching(query, haystack)
%FUZZY_MATCHING Summary of this function goes here
%   Detailed explanation goes here
    difflib = py.importlib.import_module('difflib');

    lowerQuery = lower(query);
    lowerHaystack = lower(haystack);
    
    python_matched_names = difflib.get_close_matches(lowerQuery, lowerHaystack, py.int(1), 0.3);
    matched_names = cellfun(@char,cell(python_matched_names),'UniformOutput',false);
    if isempty(matched_names)
        error ("Cannot find atlas for query " + query);
    end
    matchedIndex = find(ismember(lowerHaystack, matched_names{1}));
end

