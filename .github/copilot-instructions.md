# Copilot review instructions

Clean Architecture with BLoC; layers per feature: `data` -> `domain` <- `presentation`.

- `domain` is pure Dart: no Flutter, no `data` or `presentation` imports, no JSON/DTO types.
- `data` implements domain repository interfaces and maps DTOs to domain entities; it never imports `presentation`.
- `presentation` (widgets, BLoCs/Cubits) depends on domain only; never call data sources or repositories' implementations directly.
- Dependencies are wired via `injection.dart` (get_it/injectable); no service locator calls inside domain.
- BLoC states/events are immutable; no `BuildContext` inside BLoCs.
- User-facing strings go through l10n. New code needs tests; coverage must stay >= 90%.
- Flag only real issues (bugs, layering violations, missing tests), not style that `dart format`/analyzer enforce.
