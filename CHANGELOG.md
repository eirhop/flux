# Changelog

All notable changes to this project are documented in this file.

## [0.1.0] - 2026-03-27

### Added

- Asset authoring DSL via `use Flux.Assets` and `@asset` declarations with compile-time metadata capture.
- Registry-backed public asset discovery APIs (`list_assets/0`, `list_assets/1`, `get_asset/1`).
- DAG-backed dependency graph inspection APIs (`upstream_assets/2`, `downstream_assets/2`, `dependency_graph/2`).
- Deterministic run planner with target normalization, deduplication, and stage grouping.
- Synchronous runtime runner with canonical output/error contracts.
- Storage facade with normalized public error contract for run retrieval/listing.
- Run events API with run-topic subscribe/unsubscribe and lifecycle notifications.
- Host app startup integration via configured asset modules, graph indexing, PubSub, and storage adapter configuration.
- Baseline CI workflow for compilation and test coverage of the public API surface.

### Changed

- Updated installation documentation to recommend pinning the initial public tag (`v0.1.0`) for git dependency usage.
- Hardened test environment restoration to isolate storage adapter config between tests and doctests.
