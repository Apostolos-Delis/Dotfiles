# Common Root Cause Patterns

When debugging, check these common patterns:

- **Off-by-one**: Array bounds, loop conditions, string slicing, pagination offsets
- **Null/undefined handling**: Missing null checks, optional chaining gaps, uninitialized variables
- **Race conditions**: Async operations completing out of order, shared mutable state, missing awaits
- **Stale cache**: Browser cache, build cache, memoized values, CDN cache, DNS cache
- **Wrong environment**: Dev vs test vs prod config, environment variables not set, wrong database
- **Dependency version mismatch**: Lock file out of sync, peer dependency conflicts, breaking changes in minor versions
- **String encoding**: UTF-8 vs ASCII, URL encoding, HTML entities, newline differences (CRLF vs LF)
- **Timezone issues**: UTC vs local time, daylight saving transitions, date-only comparisons ignoring time
- **Floating point**: Equality comparisons, currency calculations, rounding errors
- **Silent failures**: Swallowed exceptions, empty catch blocks, promises without error handlers
