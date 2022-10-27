function matchedIndex = fuzzyMatching(query, haystack)
arguments
    query (1, 1) string
    haystack (1, :) string
end

%FUZZY_MATCHING returns index into the haystack or raises Exception
    % If python is available use difflib to rank values in haystack based
    % on similarity. If python is not available check if the query is a
    % substring and return the first elementIndex for which this is true.

    lowerQuery = lower(query);
    lowerHaystack = lower(haystack);

    if any(strcmp(pyenv().Version, ["3.8", "3.9"]))
        difflib = py.importlib.import_module('difflib');
        matcher = arrayfun(@(hay) difflib.SequenceMatcher(a=lowerQuery, b=hay), lowerHaystack, 'UniformOutput', false);
        ratios = cellfun(@(m) m.ratio(), matcher);
        [maxRatio, matchedIndex] = max(ratios);
        if maxRatio < 0.3
            error ("Empty result for query " + query + ".  Closest match: ", haystack(matchedIndex));
        end
    else
        % no python available
        % build pattern
        words = split(lowerQuery, " ");
        pattern = wildcardPattern;
        for wordIndex = 1:numel(words)
            pattern = pattern + words(wordIndex) + wildcardPattern;
        end
        matchedIndices = find(contains(lowerHaystack, pattern));
        if isempty(matchedIndices)
            error ("Empty result for query " + query + " in " + sprintf("%s", haystack + ", "));
        end
        matchedIndex = matchedIndices(1);
    end
    
end

