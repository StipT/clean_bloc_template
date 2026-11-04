# 2. Clean Architecture, BLoC and get_it only in the composition root

Status: accepted

## Context
Layering must be enforceable and testable, and DI must not leak into business code.

## Decision
Each feature is split into `data` / `domain` / `presentation`; `domain` has no Flutter
imports. `get_it` (without injectable) is used only in `injection.dart`: data sources,
repositories and use cases are lazy singletons, Blocs are factories, and UI creates them via
`BlocProvider(create: (_) => getIt<...>())`. Errors use a hand-written sealed
`Result<T>` and sealed `Failure` in `core` (no dartz/fpdart).

## Consequences
Domain and data classes take dependencies by constructor and are trivial to test.
Rules are written down in `.github/copilot-instructions.md` for review.
