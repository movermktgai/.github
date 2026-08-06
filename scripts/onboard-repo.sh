#!/usr/bin/env bash
# Onboard a repo into the movermktgai access standard.
# Usage: ./scripts/onboard-repo.sh <repo-name> <site|tool>
#
# - Tags the repo with the repo_class custom property (org rulesets key off it)
# - Attaches dev-team, content-editors, seo-editors at push permission
# - For tool repos: ensures .github/CODEOWNERS requires @Noctivoro
set -euo pipefail

ORG="movermktgai"
TEAMS=(dev-team content-editors seo-editors)
CODEOWNERS_BODY='* @Noctivoro'

if [[ $# -ne 2 ]] || [[ "$2" != "site" && "$2" != "tool" ]]; then
  echo "usage: $0 <repo-name> <site|tool>" >&2
  exit 2
fi

REPO="$1"
CLASS="$2"

echo "==> tagging $REPO as repo_class=$CLASS"
gh api -X PATCH "repos/$ORG/$REPO/properties/values" \
  -f "properties[][property_name]=repo_class" \
  -f "properties[][value]=$CLASS" --silent

for team in "${TEAMS[@]}"; do
  echo "==> attaching $team (push) to $REPO"
  gh api -X PUT "orgs/$ORG/teams/$team/repos/$ORG/$REPO" \
    -f permission=push --silent
done

if [[ "$CLASS" == "tool" ]]; then
  if gh api "repos/$ORG/$REPO/contents/.github/CODEOWNERS" --silent 2>/dev/null; then
    echo "==> .github/CODEOWNERS already present in $REPO — verify it contains '* @Noctivoro'"
  else
    echo "==> committing .github/CODEOWNERS to $REPO"
    gh api -X PUT "repos/$ORG/$REPO/contents/.github/CODEOWNERS" \
      -f message="chore: add CODEOWNERS — maintainer review required on main" \
      -f content="$(printf '%s\n' "$CODEOWNERS_BODY" | base64)" \
      -f branch=main --jq '.content.path'
  fi
fi

echo "==> done. Org rulesets now apply automatically ($CLASS class)."
