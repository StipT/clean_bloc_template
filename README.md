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

## Codemagic

`codemagic.yaml` defines four workflows. Each runs `melos bootstrap`, `melos run analyze` and
`melos run test` before building. Flutter version comes from `.fvmrc` (`flutter: fvm`).

| Workflow | Trigger | Output |
| --- | --- | --- |
| `android-staging` | push to `develop` | Firebase App Distribution |
| `ios-staging` | push to `develop` | TestFlight (internal testing only) |
| `android-prod` | tag `v*` | Google Play (`production`, submitted as draft) |
| `ios-prod` | tag `v*` | App Store Connect (upload only) |

Build number = latest store build + 1 (Google Play / App Store Connect); version name comes
from `apps/app/pubspec.yaml`. `android-staging` falls back to Codemagic's build number until
the staging package exists on Google Play.

Setup (nothing secret is committed; all values are entered in the Codemagic UI):

1. Add the repo as an application and let Codemagic detect `codemagic.yaml`.
2. Variable groups (mark values *Secret*):
   - `staging_config` / `prod_config`: `APP_CONFIG_JSON` = full contents of the flavor's
     `config/<flavor>.json` (see Config; client-shipped values are not secret).
   - `google_play`: `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS` (service account JSON).
   - `firebase`: `FIREBASE_SERVICE_ACCOUNT` (service account JSON).
3. Team integrations / code signing identities:
   - Developer Portal: App Store Connect API key named `codemagic` (App Manager role).
   - Android keystores named `staging_keystore` and `prod_keystore`.
   - iOS signing is fetched via the API key; `bundle_identifier` is set per workflow.
4. Replace placeholders in `codemagic.yaml`: `FIREBASE_ANDROID_APP_ID`, the
   `APP_STORE_APPLE_ID` values, the Firebase tester group (`testers`), and the
   bundle/package IDs if you renamed them.
5. Create the app records in Google Play and App Store Connect (upload the first build manually).
6. Release: push to `develop` for staging; `git tag v1.2.3 && git push --tags` for prod.

Android release builds sign with the Codemagic keystore only when `CI=true`
(`apps/app/android/app/build.gradle.kts`); locally they still use debug keys.

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
