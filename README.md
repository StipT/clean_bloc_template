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

## Config

Values come from `--dart-define-from-file=apps/app/config/<flavor>.json` and are read via `AppConfig`. Copy `apps/app/config/<flavor>.example.json` to `<flavor>.json` (gitignored). Any value shipped in the client is extractable; never put secrets in these files.

## Demo feature: posts

`apps/app/lib/features/posts` (data / domain / presentation) lists posts from
JSONPlaceholder (`BASE_URL` must be `https://jsonplaceholder.typicode.com`).
It shows the full pattern: `ApiClient` -> data source -> repository -> use
case -> `PostsBloc` -> `PostsPage`, with loading/error/empty states.

### Removing the demo feature

1. Delete `apps/app/lib/features/posts/` and `apps/app/test/features/posts/`.
2. In `apps/app/lib/injection.dart`, delete the block between
   `--- posts demo feature` and `--- end posts demo feature` (keep `AppConfig`
   and `ApiClient`).
3. In `apps/app/lib/app.dart`, replace the `postsBuilder` page with your own
   home page (and remove the posts imports).
4. Delete the posts assertions in `apps/app/test/app_test.dart` and
   `apps/app/test/injection_test.dart` (or point them at your feature).
5. If unused, drop `bloc_test`/`mocktail`/`http` only after your own tests stop
   needing them; set `BASE_URL` in `apps/app/config/*.json` to your API.
6. Run `melos bootstrap && melos analyze && melos run coverage:check`.
