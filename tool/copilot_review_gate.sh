#!/usr/bin/env bash
# Copilot review gate. Usage:
#   copilot_review_gate.sh count-unresolved <threads.json>   (decision logic)
#   copilot_review_gate.sh run <owner/repo> <pr-number>      (used by CI)
set -euo pipefail

COPILOT_REVIEWER='copilot-pull-request-reviewer'
POLL_INTERVAL="${POLL_INTERVAL:-30}"
POLL_ATTEMPTS="${POLL_ATTEMPTS:-20}" # ~10 min

# Reads GraphQL reviewThreads JSON; prints number of unresolved threads
# whose first comment was written by Copilot.
count_unresolved() {
  jq '[.data.repository.pullRequest.reviewThreads.nodes[]
       | select(.isResolved == false)
       | select((.comments.nodes[0].author.login // "") | startswith("copilot"))
      ] | length' "$1"
}

copilot_review_count() {
  gh api "repos/$1/pulls/$2/reviews" --paginate \
    --jq "[.[] | select(.user.login | startswith(\"copilot\"))] | length"
}

run() {
  local repo="$1" pr="$2" owner name n=0
  owner="${repo%/*}"
  name="${repo#*/}"

  if [ "$(copilot_review_count "$repo" "$pr")" = "0" ]; then
    echo "Requesting Copilot review"
    gh api -X POST "repos/$repo/pulls/$pr/requested_reviewers" \
      -f "reviewers[]=$COPILOT_REVIEWER[bot]" >/dev/null ||
      echo "::warning::Could not request Copilot review (is Copilot code review enabled?)"
  fi

  until [ "$(copilot_review_count "$repo" "$pr")" != "0" ]; do
    n=$((n + 1))
    if [ "$n" -gt "$POLL_ATTEMPTS" ]; then
      echo "::error::Timed out waiting for a Copilot review"
      return 1
    fi
    echo "Waiting for Copilot review ($n/$POLL_ATTEMPTS)"
    sleep "$POLL_INTERVAL"
  done

  local out
  out="$(mktemp)"
  gh api graphql -F owner="$owner" -F name="$name" -F pr="$pr" -f query='
    query($owner:String!,$name:String!,$pr:Int!){
      repository(owner:$owner,name:$name){
        pullRequest(number:$pr){
          reviewThreads(first:100){
            nodes{ isResolved comments(first:1){ nodes{ author{ login } } } }
          }
        }
      }
    }' >"$out"
  local unresolved
  unresolved="$(count_unresolved "$out")"
  rm -f "$out"
  if [ "$unresolved" -gt 0 ]; then
    echo "::error::$unresolved unresolved Copilot review thread(s)"
    return 1
  fi
  echo "Copilot review gate passed"
}

case "${1:-}" in
  count-unresolved) count_unresolved "$2" ;;
  run) run "$2" "$3" ;;
  *) echo "usage: $0 count-unresolved <file> | run <owner/repo> <pr>" >&2; exit 2 ;;
esac
