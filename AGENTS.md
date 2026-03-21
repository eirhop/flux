# AGENTS.md

## Project overview

Flux is an Elixir library for defining and orchestrating business-oriented data assets.

The core idea is:

- developers write normal Elixir functions
- `Flux.Assets` captures asset metadata at compile time
- dependencies form a pipeline graph
- the runtime will later plan and execute assets deterministically
- documentation is a first-class part of the developer experience

This repository currently focuses on the **core Flux library**.

## What the agent should optimize for

When making changes in this repo, optimize for:

1. Clear public API design
2. Small, composable modules
3. Documentation-first developer experience
4. Predictable runtime behavior
5. Elixir-native design over framework-heavy abstractions

## Elixir coding instructions

Follow Elixir best practices and idiomatic Elixir style:

- Prefer small, focused modules and functions
- Prefer pure functions and explicit data flow where possible
- Use pattern matching and multiple function heads to express intent clearly
- Use structs for domain data and behaviours for boundaries
- Keep return shapes consistent; avoid APIs whose options radically change return types
- Use pipelines only when they improve readability
- Avoid unnecessary comments; prefer clear names and good docs
- Write `@moduledoc`, `@doc`, types, and examples for all public API
- Add doctests or executable examples when practical
- Keep macros minimal and justified; prefer functions unless compile-time behavior is required
- Use OTP abstractions only when state, supervision, concurrency, or process boundaries are actually needed
- Raise only for truly exceptional situations; otherwise return explicit values
- Keep side effects at the edges of the system
- Make code easy to test with ExUnit through deterministic, isolated units

## Flux-specific instructions

When working in this codebase:

- Preserve the business-first authoring experience for asset modules
- Do not push runtime orchestration logic into `Flux.Assets`
- Do not turn `Flux.Pipeline` into a mutable execution object
- Favor explicit asset references and dependency graphs over hidden magic
- Keep cross-module dependencies ergonomic but internally normalized
- Treat documentation as part of the product, not as an afterthought
- Prefer incremental architecture that supports the next milestone:
  - plan a target asset
  - resolve dependencies across modules
  - execute deterministically
  - expose docs and metadata cleanly

## Preferred change style

For new code:

- update or add typespecs for public functions
- write or improve moduledocs and docs
- add focused tests close to the changed behavior
- keep naming precise and boring
- avoid premature abstraction
- avoid introducing dependencies unless they clearly reduce complexity

## Priority order for decisions

When tradeoffs appear, prefer:

1. Correctness
2. Readability
3. Explicitness
4. Composability
5. Convenience

Choose the simpler design unless the more advanced design clearly solves a real problem already present in Flux.