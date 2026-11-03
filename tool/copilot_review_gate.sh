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
       | select(.comments.nodes[0].author.login == "copilot-pull-request-reviewer")
       | select(.comments.nodes[0].author.__typename == "Bot")
      ] | length' "$1"
}

# Reads a JSON array of PR reviews and the PR head sha; prints
# "current" if the latest Copilot review is for that commit, "stale" if the
# latest Copilot review is for an older commit, "none" if there is no review.
review_state() {
  jq -r --arg head "$2" --arg reviewer "$COPILOT_REVIEWER" '
    [.[] | select(.user.login == $reviewer and .user.type == "Bot")
         | select(.submitted_at != null)]
    | sort_by(.submitted_at) | last
    | if . == null then "none"
      elif .commit_id == $head then "current"
      else "stale" end' "$1"
}

# Reads one GraphQL reviewThreads page; prints "<hasNextPage> <endCursor>".
page_info() {
  jq -er '
    .data.repository.pullRequest.reviewThreads.pageInfo as $page
    | if ($page.hasNextPage | type) != "boolean" then error("invalid hasNextPage")
      elif $page.hasNextPage and (($page.endCursor // "") == "") then
        error("missing endCursor")
      else "\($page.hasNextPage) \($page.endCursor // "")" end' "$1"
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
    if ! gh api graphql -F owner="$owner" -F name="$name" -F pr="$pr" \
      ${cursor_args[@]+"${cursor_args[@]}"} -f query='
      query($owner:String!,$name:String!,$pr:Int!,$cursor:String){
        repository(owner:$owner,name:$name){
          pullRequest(number:$pr){
            reviewThreads(first:100, after:$cursor){
              pageInfo{ hasNextPage endCursor }
              nodes{ isResolved comments(first:1){ nodes{ author{ login __typename } } } }
            }
          }
        }
      }' >"$page"; then
      rm -f "$page"
      echo "::error::Failed to fetch Copilot review threads" >&2
      return 1
    fi
    if ! c="$(count_unresolved "$page")" || [[ ! "$c" =~ ^[0-9]+$ ]]; then
      rm -f "$page"
      echo "::error::Failed to parse Copilot review threads" >&2
      return 1
    fi
    total=$((total + c))
    if ! info="$(page_info "$page")"; then
      rm -f "$page"
      echo "::error::Failed to parse Copilot review thread pagination" >&2
      return 1
    fi
    has="${info%% *}"
    [ "$has" = "true" ] || break
    cursor="${info#* }"
  done
  rm -f "$page"
  echo "$total"
}

run() {
  local repo="$1" pr="$2" owner name n=0 head state unresolved
  owner="${repo%/*}"
  name="${repo#*/}"
  head="$(gh api "repos/$repo/pulls/$pr" --jq .head.sha)"

  state="$(fetch_state "$repo" "$pr" "$head")"
  if [ "$state" != "current" ]; then
    request_review "$repo" "$pr"
  fi

  while [ "$n" -lt "$POLL_ATTEMPTS" ]; do
    if [ "$state" = "current" ]; then
      if ! unresolved="$(count_all_unresolved "$owner" "$name" "$pr")"; then
        echo "::error::Could not determine unresolved Copilot review threads"
        return 1
      fi
      if [[ ! "$unresolved" =~ ^[0-9]+$ ]]; then
        echo "::error::Invalid unresolved Copilot review thread count"
        return 1
      fi
      if [ "$unresolved" -eq 0 ]; then
        echo "Copilot review gate passed"
        return 0
      fi
      echo "Waiting for $unresolved unresolved Copilot review thread(s)"
    else
      echo "Waiting for Copilot review of $head"
    fi
    n=$((n + 1))
    [ "$n" -lt "$POLL_ATTEMPTS" ] || break
    sleep "$POLL_INTERVAL"
    if [ "$state" != "current" ]; then
      state="$(fetch_state "$repo" "$pr" "$head")"
    fi
  done

  if [ "$state" != "current" ]; then
    echo "::error::Timed out waiting for a Copilot review of $head"
  else
    echo "::error::Timed out waiting for $unresolved unresolved Copilot review thread(s)"
    return 1
  fi
  return 1
}

case "${1:-}" in
  count-unresolved) count_unresolved "$2" ;;
  review-state) review_state "$2" "$3" ;;
  page-info) page_info "$2" ;;
  run) run "$2" "$3" ;;
  *) echo "usage: $0 count-unresolved <file> | run <owner/repo> <pr>" >&2; exit 2 ;;
esac
