# 1. Melos 7 pub workspace with local packages

Status: accepted

## Context
The template needs shared code (core, network, design system, l10n, navigation) separated from the app.

## Decision
Use a Dart pub workspace managed by Melos 7: `apps/app` plus `packages/core`, `network`,
`design_system`, `l10n`, `navigation`. Features live in `apps/app/lib/features/*`.
Flutter is pinned in `.fvmrc`, read by GitHub Actions and Codemagic.

## Consequences
One `melos bootstrap` sets everything up; scripts (`analyze`, `test`, `coverage:check`)
run across packages. Features stay inside the app until they need extraction.
