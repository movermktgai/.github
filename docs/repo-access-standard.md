# movermktgai Repo Access & Protection Standard

Last updated: 2026-09-23 (adds `app` repo_class)

## Model

Everyone on the team can open PRs against every repo. What differs is **whose approval unlocks the merge button** on the default branch. Gating is done by org-level rulesets keyed on the `site_stage` custom property, plus one universal safety-rail ruleset. Never limit merge by withholding push access.

Every repo must carry **three** classification properties:

| Property | Type | Values |
|---|---|---|
| `repo_class` | single_select | `site`, `tool`, `app` |
| `site_stage` | single_select | `production`, `launching`, `preview`, `in_progress`, `template`, `not_site`, `open_internal` |
| `repo_steward` | string | GitHub username of the accountable owner (e.g. `Noctivoro`, `princexiaooo`) |

## Enforcement — org rulesets (all scoped to the default branch)

| `site_stage` | Ruleset | Gate |
|---|---|---|
| `~ALL` (every repo) | All repositories default-branch safety rails (`20787773`) | no force-push / delete |
| `launching`, `production` | Production site pull request protection (`17349407`) | PR + 1 approval + **code-owner review** + required status check **"MMAI Production Governance"** |
| `not_site`, `template` | Internal tools and template maintainer review gate (`20673016`) | PR + 1 approval + **code-owner review** |
| `preview`, `in_progress` | Non-production site direct-write safety rails (`20530156`) | no force-push / delete only |
| `open_internal` | Open internal direct-write safety rails (`20673798`) | no force-push / delete only |

The PR-gated rulesets also enforce: stale-review dismissal, required review-thread resolution, and `require_extra_approval_for_unattributed_changes`.

## Team access

All three standard teams get `push` on every repo:

- `dev-team`
- `content-editors`
- `seo-editors`

Gating is done by rulesets, never by withholding push access. `push` only enables branch-pushing and PR-opening; it does not weaken merge protection.

## CODEOWNERS (load-bearing)

Repos gated by `require_code_owner_review` — `site_stage ∈ {not_site, template, launching, production}` — must carry `.github/CODEOWNERS` with:

```
* @Noctivoro
```

If the file is missing, the code-owner-review rule silently degrades to "any team approval unlocks merge". The onboarding script adds it for gated stages.

## Maintainer bypass

The `maintainers` team (currently only `Noctivoro`) is the bypass actor (`bypass_mode: always`) on the two PR-gated rulesets. Bypass covers the PR/approval requirement only — `non_fast_forward` still blocks force-push on protected branches.

## Onboarding a new repo

One command (requires `gh` with org admin):

```bash
./scripts/onboard-repo.sh <repo-name> <site|tool|app> <site_stage> <repo_steward>
```

Example:

```bash
./scripts/onboard-repo.sh mmai-tracking tool open_internal princexiaooo
./scripts/onboard-repo.sh falcon-moving site production Noctivoro
```

It sets all three properties, attaches the three teams at `push`, and commits `.github/CODEOWNERS` when the stage is PR-gated. The org rulesets pick the repo up automatically once `site_stage` is set.

`site_stage` values by class:

- `site`: `preview`, `in_progress` (direct-write) → `launching`, `production` (PR + status check)
- `tool`: `open_internal` (direct-write) → `not_site`, `template` (PR + code-owner review)
- `app`: `preview`, `in_progress` (direct-write) → `launching`, `production` (PR + status check; interactive web apps that plug into client sites — quote forms, embedded widgets — are not marketing sites and carry no sitemap/IndexNow/Searchlight contract)

## Caveats

- **On `site` repos in `preview`/`in_progress`, any team member can push directly** — intentional for client-site velocity. Review quality is cultural, not enforced. `launching`/`production` sites regain the PR + status-check gate.
- **CODEOWNERS is the load-bearing piece** on gated repos — verify the file exists after tagging, not just the ruleset.
- **Production sites** additionally require the `"MMAI Production Governance"` status check (integration_id `15368`), provided by the deploy workflow and driven by `/ops/production-site.json` + the `@movermktgai/deployment-manifest` package.
- The legacy `repo_class` property is still recorded (coarse class) but no ruleset keys on it — `site_stage` is what gates.
- Deploy/workflow secrets stay in GitHub Actions secrets or Keychain. Team `push` does not grant secret access, but anyone with `push` can read workflow files — keep production deploy workflows gated by environment protection where they exist.
