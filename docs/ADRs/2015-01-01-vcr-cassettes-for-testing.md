# VCR Cassettes for Testing

## Status

Accepted

## Context

The SDK makes real HTTP calls to `api.contentful.com`. Testing against the live API requires valid credentials, creates content side-effects, and produces flaky, slow tests. Options:

1. **Live API calls** — needs real credentials, slow, side-effects
2. **Manual stubs** (WebMock alone) — verbose, must hand-craft response bodies
3. **VCR cassettes** — record real interactions once, replay deterministically offline

## Decision

`vcr` (with `webmock` as the HTTP adapter) was adopted from the initial commit. Cassette YAML files live in `spec/fixtures/vcr_cassettes/`. Tests record against the real CMA API once; subsequent runs replay from cassettes.

An additional security measure was added in commit `1a975bc` (v3.6.0): VCR is configured to redact CMA tokens from cassettes before they are committed, preventing accidental credential exposure.

## Consequences

- Tests are fast, deterministic, run offline — CI needs no API credentials
- When the CMA changes a response format, cassettes for that resource must be re-recorded
- New endpoint tests require a one-time recording step with a valid management token
- Cassettes can go stale silently if API response shapes change without re-recording
