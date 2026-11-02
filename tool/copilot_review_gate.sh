#!/usr/bin/env bash
# Copilot review gate. Usage:
#   copilot_review_gate.sh count-unresolved <threads.json>   (decision logic)
#   copilot_review_gate.sh review-state <reviews.json> <head-sha>
#   copilot_review_gate.sh page-info <threads.json>
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

# Reads a JSON array of PR reviews and the PR head sha; prints
# "current" if the latest Copilot review is for that commit, "stale" if the
# latest Copilot review is for an older commit, "none" if there is no review.
review_state() {
  jq -r --arg head "$2" '
    [.[] | select((.user.login // "") | startswith("copilot"))
         | select(.submitted_at != null)]
    | sort_by(.submitted_at) | last
    | if . == null then "none"
      elif .commit_id == $head then "current"
      else "stale" end' "$1"
}

# Reads one GraphQL reviewThreads page; prints "<hasNextPage> <endCursor>".
page_info() {
  jq -r '.data.repository.pullRequest.reviewThreads.pageInfo
         | "\(.hasNextPage) \(.endCursor // "")"' "$1"
}

fetch_state() {
  local repo="$1" pr="$2" head="$3" reviews state
  reviews="$(mktemp)"
  gh api "repos/$repo/pulls/$pr/reviews" --paginate |
    jq -s 'add // []' >"$reviews"
  state="$(review_state "$reviews" "$head")"
  rm -f "$reviews"
  echo "$state"
}

request_review() {
  echo "Requesting Copilot review"
  gh api -X POST "repos/$1/pulls/$2/requested_reviewers" \
    -f "reviewers[]=$COPILOT_REVIEWER[bot]" >/dev/null ||
    echo "::warning::Could not request Copilot review (is Copilot code review enabled?)"
}

count_all_unresolved() {
  local owner="$1" name="$2" pr="$3" total=0 cursor="" page info has c
  page="$(mktemp)"
  while :; do
    local cursor_args=()
    [ -z "$cursor" ] || cursor_args=(-f "cursor=$cursor")
    gh api graphql -F owner="$owner" -F name="$name" -F pr="$pr" \
      ${cursor_args[@]+"${cursor_args[@]}"} -f query='
      query($owner:String!,$name:String!,$pr:Int!,$cursor:String){
        repository(owner:$owner,name:$name){
          pullRequest(number:$pr){
            reviewThreads(first:100, after:$cursor){
              pageInfo{ hasNextPage endCursor }
              nodes{ isResolved comments(first:1){ nodes{ author{ login } } } }
            }
          }
        }
      }' >"$page"
    c="$(count_unresolved "$page")"
    total=$((total + c))
    info="$(page_info "$page")"
    has="${info%% *}"
    [ "$has" = "true" ] || break
    cursor="${info#* }"
  done
  rm -f "$page"
  echo "$total"
}

run() {
  local repo="$1" pr="$2" owner name n=0 head state
  owner="${repo%/*}"
  name="${repo#*/}"
  head="$(gh api "repos/$repo/pulls/$pr" --jq .head.sha)"

  state="$(fetch_state "$repo" "$pr" "$head")"
  if [ "$state" != "current" ]; then
    request_review "$repo" "$pr"
  fi

  until [ "$state" = "current" ]; do
    n=$((n + 1))
    if [ "$n" -gt "$POLL_ATTEMPTS" ]; then
      echo "::error::Timed out waiting for a Copilot review of $head"
      return 1
    fi
    echo "Waiting for Copilot review of $head ($n/$POLL_ATTEMPTS)"
    sleep "$POLL_INTERVAL"
    state="$(fetch_state "$repo" "$pr" "$head")"
  done

  local unresolved
  unresolved="$(count_all_unresolved "$owner" "$name" "$pr")"
  if [ "$unresolved" -gt 0 ]; then
    echo "::error::$unresolved unresolved Copilot review thread(s)"
    return 1
  fi
  echo "Copilot review gate passed"
}

case "${1:-}" in
  count-unresolved) count_unresolved "$2" ;;
  review-state) review_state "$2" "$3" ;;
  page-info) page_info "$2" ;;
  run) run "$2" "$3" ;;
  *) echo "usage: $0 count-unresolved <file> | run <owner/repo> <pr>" >&2; exit 2 ;;
esac
