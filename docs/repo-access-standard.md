# movermktgai Repo Access & Protection Standard

Last updated: 2026-08-05 (supersedes the old "everyone pull-only" standard)

## Model

Everyone on the team can open PRs against every repo. What differs is **whose approval unlocks the merge button** on the default branch. Gating is done by org-level rulesets keyed on a repository custom property — never by limiting push access.

| | `repo_class=site` | `repo_class=tool` |
|---|---|---|
| Repos | Client sites + agency-owned sites (mmai-website, localmovershq, movingcompanyhq, mmai-client-site-template) | Internal tools/infra (searchlight, mmai-ads, mmai-forms, mmai-calendar-booking, mmai-deployment-manifest, mmai-technical-seo-audit-agent, mover-marketing-video, .github) |
| Team access | `push` via dev-team / content-editors / seo-editors | same |
| Merge to main | PR + 1 approval — any team member can approve | PR + approval from CODEOWNERS (`@Noctivoro`) |
| Direct push / force-push / delete main | blocked | blocked |
| Maintainer (Noctivoro) | bypass | bypass |

## Enforcement

Two org-level rulesets do all the work. They key off the `repo_class` custom property, so tagging a repo is sufficient — no ruleset edits per repo.

- **Production site pull request protection** (org ruleset `17349407`) → `repo_class=tool`: PR required, 1 approving review, code-owner review, stale-review dismissal, thread resolution, no force-push/delete.
- **Non-production site direct-write safety rails** (org ruleset `17988933`) → `repo_class=site`: no force-push/delete only.
- Tool repos carry `.github/CODEOWNERS` containing `* @Noctivoro`.

## Onboarding a new repo

One command (requires `gh` with org admin):

```bash
./scripts/onboard-repo.sh <repo-name> <site|tool>
```

It tags `repo_class`, attaches the three standard teams at `push`, and for `tool` repos commits `.github/CODEOWNERS` if missing. The org rulesets pick the repo up automatically once tagged.

## Caveats

- **Team members must not approve their own PRs' gatekeepers away**: on `site` repos any team member can approve+merge — that's intentional for client-site velocity. Review quality is cultural, not enforced.
- **CODEOWNERS on tool repos is the load-bearing piece**: if a tool repo loses `.github/CODEOWNERS`, any team approval unlocks merge. The onboarding script checks for it; `require_code_owner_review` silently degrades without the file.
- The old `site_stage` property is still present but no longer gates anything.
- Deploy/workflow secrets stay in GitHub Actions secrets or Keychain; team `push` access does not grant secret access, but anyone with `push` can read workflow files — keep production deploy workflows gated by environment protection rules where they exist.
