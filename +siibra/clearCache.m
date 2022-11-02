function clearCache()
%CLEARCACHE Clears the cache
    rmdir(siibra.internal.cache(""), "s")
end

