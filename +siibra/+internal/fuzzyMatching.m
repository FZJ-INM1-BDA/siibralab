function matchedIndex = fuzzyMatching(query, haystack)
arguments
    query (1, 1) string
    haystack (1, :) string
end

%FUZZY_MATCHING returns index into the haystack or raises Exception
    % Check if the words of the query occur in the given order 
    % and return the first elementIndex for which this is true.

    lowerQuery = lower(query);
    lowerHaystack = lower(haystack);

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

    if ~strcmp(query, haystack(matchedIndex))
        display("Resolved query '" + query + "' to: " + haystack(matchedIndex));
    end
    
end

