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

review() { # login type commit submitted_at
  printf '{"user":{"login":"%s","type":"%s"},"commit_id":"%s","submitted_at":"%s"}' "$1" "$2" "$3" "$4"
}
expect_state() { # expected name head
  local got
  got="$("$gate" review-state "$f" "$3")"
  [ "$got" = "$1" ] || { echo "FAIL $2: expected $1 got $got"; exit 1; }
  echo "ok $2"
}
reviews() { printf '[%s]' "$1" >"$f"; }
bot=copilot-pull-request-reviewer

reviews ""; expect_state none "no reviews" aaa
reviews "$(review someone User aaa 2026-01-01T00:00:00Z)"; expect_state none "human review ignored" aaa
reviews "$(review copilot-review-helper User aaa 2026-01-01T00:00:00Z)"
expect_state none "similarly named human reviewer ignored" aaa
reviews "$(review $bot User aaa 2026-01-01T00:00:00Z)"
expect_state none "non-bot reviewer with exact login ignored" aaa
reviews "$(review $bot Bot aaa 2026-01-01T00:00:00Z)"; expect_state current "review of head" aaa
reviews "$(review $bot Bot old 2026-01-01T00:00:00Z)"; expect_state stale "review of older commit" aaa
reviews "$(review $bot Bot aaa 2026-01-01T00:00:00Z),$(review $bot Bot bbb 2026-01-02T00:00:00Z)"
expect_state stale "latest review is for older commit than head" aaa
reviews "$(review $bot Bot bbb 2026-01-02T00:00:00Z),$(review $bot Bot aaa 2026-01-01T00:00:00Z)"
expect_state current "latest by time wins regardless of order" bbb

page() { printf '{"data":{"repository":{"pullRequest":{"reviewThreads":{"pageInfo":{"hasNextPage":%s,"endCursor":%s},"nodes":[]}}}}}' "$1" "$2" >"$f"; }
page_expect() {
  local got
  got="$("$gate" page-info "$f")"
  [ "$got" = "$1" ] || { echo "FAIL $2: expected '$1' got '$got'"; exit 1; }
  echo "ok $2"
}
page true '"abc"'; page_expect "true abc" "more pages"
page false null; page_expect "false " "last page"
