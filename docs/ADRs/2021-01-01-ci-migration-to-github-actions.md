# CI/CD Migration: Travis CI → CircleCI → GitHub Actions + Devcontainers

## Status

Accepted

## Context

The repo has undergone two CI vendor migrations:

1. **Travis CI → CircleCI** (commit `6b3b482`, ~2021): Travis CI moved toward a paid model for open-source projects. CircleCI was the Contentful team standard at the time.

2. **CircleCI → GitHub Actions + devcontainers** (commit `8940acd`, DX-822, March 2026): CircleCI caused 401 errors for forked-repo PRs, preventing external contributors from running CI. The DX team (Ethan Ozelius, confirmed in Slack `#prd-alpine-chat`, 2026-03-31) migrated all SDK repos to GitHub Actions simultaneously. The devcontainer workflow was introduced to ensure local development and CI use identical environments.

## Decision

All CI now runs via `.github/workflows/ci.yml`. The workflow uses the devcontainer Dockerfile (`ARG RUBY_VERSION=3.4` default) to run `bundle _2.3.26_ exec rake rspec_rubocop` across Ruby 3.2, 3.3, and 3.4. The CI matrix uses the same container that developers use locally, eliminating "works on my machine" divergence.

Bundler is pinned at `2.3.26` in the devcontainer Dockerfile (`gem install bundler:2.3.26`) and all `bundle` invocations use `bundle _2.3.26_`.

## Consequences

- Fork PRs can run CI without CircleCI credentials — unblocks external contributors
- Local dev and CI use identical environments (same Dockerfile, same Bundler pin)
- External contributors need Docker to use the devcontainer locally
- CircleCI config was deleted with no rollback path
- Source: DX-822, commit `8940acd`, Slack `#prd-alpine-chat` (2026-03-31)
