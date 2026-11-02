# Contributing

## Setup

```sh
dart pub global activate melos
melos bootstrap
```

The Flutter version is pinned in `.fvmrc`.

## Before opening a PR

```sh
dart format .
melos run format:check
melos analyze
melos run coverage:check   # tests + 90% coverage gate
```

CI (`.github/workflows/pr.yml`) runs the same checks; `lint`, `test` and
`copilot-review-gate` must pass. Resolve all Copilot review threads.

## Architecture rules

Per feature: `data` -> `domain` <- `presentation`. `domain` is pure Dart (no Flutter,
no data/presentation imports). `get_it` is used only in `apps/app/lib/injection.dart`.
BLoC states/events are immutable; user-facing strings go through l10n. Full rules:
`.github/copilot-instructions.md`. Rationale: `docs/adr/`.

## Pull requests

Keep PRs focused, add tests for new code, and fill in the PR template.
Releases: push to `develop` for staging; tag `v*` for prod (see README, Codemagic).
