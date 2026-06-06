# Security Policy

Report vulnerabilities privately to Mover Marketing AI maintainers. Do not open public issues or pull requests with exploit details, secrets, webhook URLs, credentials, tokens, or private customer data.

When reporting, include:

- Summary of the issue.
- Affected repository, route, workflow, dependency, or configuration.
- Safe reproduction steps that use placeholders instead of real secrets.
- Impact and recommended fix, if known.

Runtime secrets belong in approved secret stores such as GitHub Actions secrets, hosting provider secrets, macOS Keychain, or another approved credentials manager. Never commit real secret values to repositories, docs, issues, pull requests, comments, or commit history.
