#!/usr/bin/env bash
# Idempotently creates/updates the "main-protection" ruleset: required checks
# lint, test, copilot-review-gate and Copilot auto-review.
# Usage: tool/setup_repo.sh [owner/repo] [--dry-run]
set -euo pipefail

REPO=""
DRY_RUN=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    *) REPO="$a" ;;
  esac
done
RULESET_NAME="main-protection"

payload() {
  cat <<JSON
{
  "name": "$RULESET_NAME",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false } },
    { "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          { "context": "lint" }, { "context": "test" }, { "context": "copilot-review-gate" } ] } },
    { "type": "copilot_code_review",
      "parameters": { "review_on_push": true, "review_draft_pull_requests": false } }
  ]
}
JSON
}

if [ "$DRY_RUN" = 1 ]; then
  echo "Would apply ruleset ${REPO:+to $REPO}:"
  payload
  exit 0
fi

REPO="${REPO:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
id="$(gh api "repos/$REPO/rulesets" --jq ".[] | select(.name==\"$RULESET_NAME\") | .id" | head -n1)"
if [ -n "$id" ]; then
  echo "Updating ruleset $id on $REPO"
  payload | gh api -X PUT "repos/$REPO/rulesets/$id" --input - >/dev/null
else
  echo "Creating ruleset on $REPO"
  payload | gh api -X POST "repos/$REPO/rulesets" --input - >/dev/null
fi
echo "Done"
