# Factory Mixin Architecture

## Status

Accepted

## Context

The Contentful Management API exposes a large, hierarchical resource model: Organizations → Spaces → Environments → ContentTypes/Entries/Assets, each with CRUD operations and lifecycle verbs (publish, archive). A naive approach of directly implementing HTTP calls in every resource class would lead to massive duplication. The library needed to:

1. Provide scoped access (factory per resource type holds `space_id`, `environment_id`)
2. Share generic CRUD across all resource types with minimal repetition
3. Stay extensible: adding a new CMA resource type should require minimal boilerplate
4. Remain idiomatic Ruby

## Decision

Two patterns were established at initial commit (January 2015):

**Factory mixin pattern:** A `ClientAssociationMethodsFactory` module provides generic `all`, `find`, `create` methods. Per-resource factories (e.g., `ClientEntryMethodsFactory`) include this module and hold scope identifiers. The `associated_class` method derives the resource class from the factory's own class name via naming convention, eliminating the need to declare it explicitly.

**Resource mixin pattern:** A `Resource` module + a set of capability mixins (`Publisher`, `Archiver`, `SystemProperties`, `EnvironmentAware`, `Fields`, etc.) compose resource behavior. Each resource class (`Entry`, `Asset`, etc.) includes only the mixins relevant to it.

This maps cleanly to Ruby's module/mixin system and allows fine-grained capability assignment.

## Consequences

- New resources require: one resource class module + one client factory module (optionally space/environment factory modules) + an entry in `ResourceBuilder::DEFAULT_RESOURCE_MAPPING`
- The `associated_class` naming-convention magic is clever but brittle — the factory class name must match the resource class name precisely (e.g., `ClientEntryMethodsFactory` → `Contentful::Management::Entry`)
- Factory instances are lightweight scope containers; the `Client` is the singleton holding config and HTTP state
- Context not found for why this pattern was chosen over a simpler flat API or a registry approach — likely an inherited convention from sibling SDKs
