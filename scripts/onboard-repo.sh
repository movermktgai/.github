#!/usr/bin/env bash
# Onboard a repo into the movermktgai access standard.
# Usage: ./scripts/onboard-repo.sh <repo-name> <site|tool> <site_stage> <repo_steward>
#
# - Tags repo_class, site_stage, and repo_steward custom properties
#   (org rulesets key off site_stage)
# - Attaches dev-team, content-editors, seo-editors at push
# - Adds .github/CODEOWNERS (* @Noctivoro) for PR-gated stages:
#     not_site, template          -> Internal tools and template maintainer review gate
#     launching, production       -> Production site pull request protection
#   Direct-write stages (open_internal, preview, in_progress) need no CODEOWNERS.
set -euo pipefail

ORG="movermktgai"
TEAMS=(dev-team content-editors seo-editors)
CODEOWNERS_BODY='* @Noctivoro'

SITE_STAGES=(preview in_progress launching production)
TOOL_STAGES=(not_site template open_internal)
CODEOWNERS_STAGES=(not_site template launching production)

if [[ $# -ne 4 ]]; then
  echo "usage: $0 <repo-name> <site|tool> <site_stage> <repo_steward>" >&2
  echo "  site_stage (site):  ${SITE_STAGES[*]}" >&2
  echo "  site_stage (tool):  ${TOOL_STAGES[*]}" >&2
  echo "  repo_steward:       GitHub username of the accountable owner" >&2
  exit 2
fi

REPO="$1"
CLASS="$2"
STAGE="$3"
STEWARD="$4"

if [[ "$CLASS" != "site" && "$CLASS" != "tool" ]]; then
  echo "error: repo_class must be 'site' or 'tool'" >&2
  exit 2
fi

if [[ "$CLASS" == "site" ]]; then
  valid="${SITE_STAGES[*]}"
else
  valid="${TOOL_STAGES[*]}"
fi
if [[ " $valid " != *" $STAGE "* ]]; then
  echo "error: site_stage '$STAGE' not valid for repo_class '$CLASS' (valid: $valid)" >&2
  exit 2
fi

echo "==> tagging $REPO (repo_class=$CLASS, site_stage=$STAGE, repo_steward=$STEWARD)"
gh api -X PATCH "repos/$ORG/$REPO/properties/values" \
  -f "properties[][property_name]=repo_class" -f "properties[][value]=$CLASS" \
  -f "properties[][property_name]=site_stage" -f "properties[][value]=$STAGE" \
  -f "properties[][property_name]=repo_steward" -f "properties[][value]=$STEWARD" --silent

for team in "${TEAMS[@]}"; do
  echo "==> attaching $team (push) to $REPO"
  gh api -X PUT "orgs/$ORG/teams/$team/repos/$ORG/$REPO" -f permission=push --silent
done

need_codeowners=0
for s in "${CODEOWNERS_STAGES[@]}"; do
  [[ "$s" == "$STAGE" ]] && need_codeowners=1
done

if [[ $need_codeowners -eq 1 ]]; then
  if gh api "repos/$ORG/$REPO/contents/.github/CODEOWNERS" --silent 2>/dev/null; then
    echo "==> .github/CODEOWNERS already present in $REPO — verify it contains '* @Noctivoro'"
  else
    echo "==> committing .github/CODEOWNERS (* @Noctivoro) to $REPO"
    gh api -X PUT "repos/$ORG/$REPO/contents/.github/CODEOWNERS" \
      -f message="chore: add CODEOWNERS — code-owner review required on main" \
      -f content="$(printf '%s\n' "$CODEOWNERS_BODY" | base64)" \
      -f branch=main --jq '.content.path'
  fi
else
  echo "==> site_stage=$STAGE is direct-write — no CODEOWNERS required"
fi

echo "==> done. Rulesets apply automatically via site_stage=$STAGE."
