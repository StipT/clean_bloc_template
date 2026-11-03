#!/usr/bin/env bash
# Tests the gate decision logic with fixtures.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
gate="$here/../copilot_review_gate.sh"
f="$(mktemp)"
trap 'rm -f "$f"' EXIT

thread() { # resolved author-login author-type
  printf '{"isResolved":%s,"comments":{"nodes":[{"author":{"login":"%s","__typename":"%s"}}]}}' "$1" "$2" "$3"
}
wrap() { printf '{"data":{"repository":{"pullRequest":{"reviewThreads":{"nodes":[%s]}}}}}' "$1" >"$f"; }
expect() {
  local got
  got="$("$gate" count-unresolved "$f")"
  [ "$got" = "$1" ] || { echo "FAIL $2: expected $1 got $got"; exit 1; }
  echo "ok $2"
}

wrap ""; expect 0 "no threads"
wrap "$(thread false copilot-pull-request-reviewer Bot)"; expect 1 "unresolved copilot"
wrap "$(thread true copilot-pull-request-reviewer Bot)"; expect 0 "resolved copilot"
wrap "$(thread false someone User)"; expect 0 "unresolved human ignored"
wrap "$(thread false copilot-review-helper User)"; expect 0 "similarly named human thread ignored"
wrap "$(thread false copilot-pull-request-reviewer User)"; expect 0 "non-bot with exact login ignored"
wrap "$(thread false copilot-pull-request-reviewer Bot),$(thread false copilot-pull-request-reviewer Bot),$(thread true copilot-pull-request-reviewer Bot)"; expect 2 "mixed"

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

# Failed and malformed GraphQL responses must not be interpreted as zero threads.
bin="$(mktemp -d)"
trap 'rm -f "$f"; rm -rf "$bin"' EXIT
cat >"$bin/gh" <<'EOF'
#!/usr/bin/env bash
if [[ "$*" == "api repos/o/r/pulls/1 --jq .head.sha" ]]; then
  echo head
elif [[ "$*" == "api repos/o/r/pulls/1/reviews --paginate" ]]; then
  echo '[{"user":{"login":"copilot-pull-request-reviewer","type":"Bot"},"commit_id":"head","submitted_at":"2026-01-01T00:00:00Z"}]'
elif [[ "$*" == *"api graphql"* ]]; then
  case "$GH_MOCK_MODE" in
    fail) exit 1 ;;
    malformed) echo '{"errors":[{"message":"no access"}]}' ;;
    resolve)
      count=0
      [[ ! -f "$GH_CALLS_FILE" ]] || count="$(cat "$GH_CALLS_FILE")"
      count=$((count + 1))
      echo "$count" >"$GH_CALLS_FILE"
      resolved=false
      [[ "$count" -lt 2 ]] || resolved=true
      printf '{"data":{"repository":{"pullRequest":{"reviewThreads":{"pageInfo":{"hasNextPage":false,"endCursor":null},"nodes":[{"isResolved":%s,"comments":{"nodes":[{"author":{"login":"copilot-pull-request-reviewer","__typename":"Bot"}}]}}]}}}}}\n' "$resolved"
      ;;
  esac
else
  echo "unexpected gh arguments: $*" >&2
  exit 2
fi
EOF
cat >"$bin/sleep" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$bin/gh" "$bin/sleep"

if PATH="$bin:$PATH" GH_MOCK_MODE=fail POLL_ATTEMPTS=1 "$gate" run o/r 1 >/dev/null 2>&1; then
  echo "FAIL failed GraphQL request must fail gate"; exit 1
fi
echo "ok failed GraphQL request fails gate"
if PATH="$bin:$PATH" GH_MOCK_MODE=malformed POLL_ATTEMPTS=1 "$gate" run o/r 1 >/dev/null 2>&1; then
  echo "FAIL malformed GraphQL response must fail gate"; exit 1
fi
echo "ok malformed GraphQL response fails gate"
calls="$f.calls"
PATH="$bin:$PATH" GH_MOCK_MODE=resolve GH_CALLS_FILE="$calls" \
  POLL_INTERVAL=0 POLL_ATTEMPTS=3 "$gate" run o/r 1 >/dev/null
[ "$(cat "$calls")" = 2 ] || { echo "FAIL gate should poll until thread resolution"; exit 1; }
echo "ok polls until Copilot thread is resolved"
