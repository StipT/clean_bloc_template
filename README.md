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
