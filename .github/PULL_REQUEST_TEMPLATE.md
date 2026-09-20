## Summary

<!-- What changed, and why? -->

## Affected surfaces

- [ ] CLI command or flag behavior
- [ ] Credential handling or authentication path
- [ ] Scheduled job, cron, or workflow
- [ ] External API integration
- [ ] Data model, migration, or stored state
- [ ] Documentation or repository operations only

## Validation

<!-- List the exact commands you ran and their results. -->

- [ ] Tests or lint for the changed surface
- [ ] `git diff --check`
- [ ] Bounded dry run of any command that can mutate production

## Evidence

<!-- Command output, redacted logs, or before/after assertions.
     Never include secrets, tokens, or client data. -->

## Risk

- Can this mutate production? Yes / No
- New credential or secret names: None / List names only
- Rollback approach:

## Final checks

- [ ] No secrets, tokens, credential bundles, or client data are included.
- [ ] Secrets are never printed, logged, or included in error output.
- [ ] Retries and timeouts are bounded.
- [ ] Maintainer approval obtained before merge or deployment.
