# Flutter BLoC Template

Melos 7 pub workspace (`apps/app`). Flutter version is pinned in `.fvmrc`.

```sh
dart pub global activate melos
melos bootstrap
melos analyze
melos test
melos run coverage:check   # tests + 90% merged-lcov gate
```

## Flavors

`dev`, `staging`, `prod` (flutter_flavorizr config lives in `apps/app/pubspec.yaml`;
generated native config is committed). Each has its own app name, bundle/application
ID suffix (`.dev`, `.staging`, none for prod) and icon (dev/staging carry a banner).
Run from `apps/app` (copy `config/<flavor>.example.json` to `config/<flavor>.json` first):

```sh
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=config/staging.json
flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=config/prod.json

flutter build apk --flavor prod -t lib/main_prod.dart --dart-define-from-file=config/prod.json
flutter build ipa --flavor prod -t lib/main_prod.dart --dart-define-from-file=config/prod.json
```

All entrypoints call `bootstrap()` (`lib/bootstrap.dart`). To regenerate native config
after editing the `flavorizr:` block: `dart run flutter_flavorizr -f` (in `apps/app`).

Coverage exclusions (`tool/coverage_check.dart`): `*.g.dart`, generated l10n,
`main_*.dart`, `injection.dart`.

## Copilot review gate and repo setup

`.github/workflows/copilot-review-gate.yml` requests a Copilot review if none
exists, polls up to ~10 min, and fails while Copilot has unresolved review
threads (resolve them to pass). Copilot code review must be enabled for the
repo/org; expect some noisy comments. Layering rules for Copilot live in
`.github/copilot-instructions.md`.

Run `tool/setup_repo.sh [owner/repo]` (needs `gh` with admin rights; safe to
re-run; `--dry-run` prints the ruleset) to create the `main-protection` ruleset.

Manual fallback: Settings -> Rules -> Rulesets -> New branch ruleset targeting
the default branch; require a pull request, require status checks `lint`,
`test`, `copilot-review-gate`, and enable "Automatically request Copilot code
review". Tests: `tool/test/copilot_review_gate_test.sh`.

## Config

Values come from `--dart-define-from-file=apps/app/config/<flavor>.json` and are read via `AppConfig`. Copy `apps/app/config/<flavor>.example.json` to `<flavor>.json` (gitignored). Any value shipped in the client is extractable; never put secrets in these files.
