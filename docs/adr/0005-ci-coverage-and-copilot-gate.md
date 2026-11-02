# 5. CI: coverage gate, Copilot review gate and ruleset

Status: accepted

## Context
Quality bars should be enforced automatically on every PR.

## Decision
GitHub Actions runs `lint` then `test` (`melos run coverage:check`, >= 90% on the merged
lcov report; exclusions listed in `tool/coverage_check.dart`). A separate
`copilot-review-gate` check requests a Copilot review and fails while Copilot has
unresolved threads. `tool/setup_repo.sh` creates the `main-protection` ruleset requiring
all three checks and enabling Copilot auto-review; init calls it, and a manual fallback is documented.

## Consequences
Copilot review must be enabled for the repo/org and can be noisy. Releases are handled
separately by Codemagic (push to `develop` = staging, tag `v*` = prod).
