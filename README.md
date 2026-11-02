# Flutter BLoC Template

Melos 7 pub workspace (`apps/app`). Flutter version is pinned in `.fvmrc`.

```sh
dart pub global activate melos
melos bootstrap
melos analyze
melos test
melos run coverage:check   # tests + 90% merged-lcov gate
cd apps/app && flutter run -t lib/main_dev.dart
```

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
