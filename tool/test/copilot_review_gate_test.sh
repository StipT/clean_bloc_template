#!/usr/bin/env bash
# Tests the gate decision logic with fixtures.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
gate="$here/../copilot_review_gate.sh"
f="$(mktemp)"
trap 'rm -f "$f"' EXIT

thread() { # resolved author
  printf '{"isResolved":%s,"comments":{"nodes":[{"author":{"login":"%s"}}]}}' "$1" "$2"
}
wrap() { printf '{"data":{"repository":{"pullRequest":{"reviewThreads":{"nodes":[%s]}}}}}' "$1" >"$f"; }
expect() {
  local got
  got="$("$gate" count-unresolved "$f")"
  [ "$got" = "$1" ] || { echo "FAIL $2: expected $1 got $got"; exit 1; }
  echo "ok $2"
}

wrap ""; expect 0 "no threads"
wrap "$(thread false copilot-pull-request-reviewer)"; expect 1 "unresolved copilot"
wrap "$(thread true copilot-pull-request-reviewer)"; expect 0 "resolved copilot"
wrap "$(thread false someone)"; expect 0 "unresolved human ignored"
wrap "$(thread false copilot-pull-request-reviewer),$(thread false copilot-pull-request-reviewer),$(thread true copilot-pull-request-reviewer)"; expect 2 "mixed"
