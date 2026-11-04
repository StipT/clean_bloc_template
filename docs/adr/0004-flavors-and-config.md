# 4. Flavors and config via --dart-define-from-file

Status: accepted

## Context
Apps need dev/staging/prod builds and environment values without committing secrets.

## Decision
Flavors `dev`, `staging`, `prod` via `flutter_flavorizr` with one entrypoint each
(`main_<flavor>.dart`). Config is passed with `--dart-define-from-file=config/<flavor>.json`
and read through typed `AppConfig` (`String.fromEnvironment`). Real JSON files are
gitignored; `*.example.json` are committed. CI injects values from Codemagic variable groups.

## Consequences
Anything shipped in the client is extractable, so config must never hold secrets.
