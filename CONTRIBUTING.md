# Contributing

This is a private, proprietary internal tooling repository. Work through
reviewed pull requests and validate changes before asking for review.

## Working agreement

- Do not commit secrets, API keys, tokens, OAuth credentials, webhook URLs,
  deploy hooks, `.env` values, or any client-private data.
- Do not push directly to `main` when this repository requires a pull request.
  Work from a branch.
- Keep the public surface small. Internal tools should not grow endpoints,
  elevated credentials, or destructive commands without a stated reason.
- Prefer deterministic, event-driven behavior over polling and timing guesses.
- Document operational commands in the README or `docs/`, not only in code
  comments.

## Setup

See the README for install and run instructions.

## Before you open a pull request

Run whatever checks this repository defines (lint, typecheck, tests, or a build).
If it has none, say so in the pull request rather than implying validation
happened.

## Pull request content

Describe what changed, why, and how you verified it. Include exact commands and
results. Never include credentials, secrets, tokens, or client data.

## Commit messages

Use an imperative summary: `fix: bound retry window on webhook poller`, not
`updates`.

## Review

Internal-tool repositories require a code-owner review before merge.
