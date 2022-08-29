function matchedIndex = fuzzyMatching(query, haystack)
arguments
    query (1, 1) string
    haystack (1, :) string
end

%FUZZY_MATCHING Summary of this function goes here
%   Detailed explanation goes here
    % If python is available use difflib to rank values in haystack based
    % on similarity. If python is not available check if the query is a
    % substring and return the first elementIndex for which this is true.

    lowerQuery = lower(query);
    lowerHaystack = lower(haystack);

    if isempty(pyenv().Version)
        % no python available
        matchedIndices = find(contains(lowerHaystack, lowerQuery));
        if isempty(matchedIndices)
            error (strcat("Empty result for query ", query, " in ", sprintf("%s", haystack + ", ")));
        end
        matchedIndex = matchedIndices(1);
            
    else
        difflib = py.importlib.import_module('difflib');

        python_matched_names = difflib.get_close_matches(lowerQuery, cellstr(lowerHaystack), py.int(1), 0.3);
        matched_names = cellfun(@string,cell(python_matched_names),'UniformOutput',false);
        if isempty(matched_names)
            error (strcat("Empty result for query ", query, " in ", sprintf("%s", haystack + ", ")));
        end
        matchedIndex = find(ismember(lowerHaystack, matched_names{1}));

    end
    
end

