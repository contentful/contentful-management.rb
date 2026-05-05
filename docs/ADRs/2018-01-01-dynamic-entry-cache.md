# DynamicEntry Cache for Typed Field Access

## Status

Accepted

## Context

The CMA API returns entry fields as a generic hash (`fields: { title: { 'en-US': 'Hello' } }`). Without schema knowledge, callers must access fields with hash syntax. But content type schemas are available via the API, and many callers want typed, named accessors on entries (e.g., `entry.title` instead of `entry.fields[:title]['en-US']`).

Two approaches:
1. **Always use hash access** — simple but verbose, no IDE completion
2. **Pre-fetch schemas at client init and generate per-content-type classes** — convenient but requires an API call at startup and adds a caching layer

## Decision

`DynamicEntry` was introduced to support optional typed field access. At `Client` init, if `dynamic_entries: { space_id => env_id }` is specified, the client fetches all content types for each environment and generates `DynamicEntry` subclasses via `DynamicEntry.create(content_type, client)`. These are cached in `Client#dynamic_entry_cache` (a plain Ruby hash). `ResourceBuilder` checks this cache when deserializing entries and returns the typed subclass instead of the generic `Entry`.

Content type caching can be disabled with `disable_content_type_caching: true`. The cache can be refreshed at any time via `client.update_dynamic_entry_cache_for_environment!(env)`.

Source: commit archaeology — `DynamicEntry` appears in early versions alongside the `disable_content_type_caching` configuration option (commit `92f0d4c`).

## Consequences

- Callers using `dynamic_entries` get named field accessors and better IDE support
- Startup time increases by one `content_types.all` API call per configured environment
- If content type schemas change after client init, the cache becomes stale — callers must refresh or reinitialize the client
- Cache is stored per client instance, not globally; thread safety requires separate client instances per thread
