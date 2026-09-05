# Security Policy

## Supported versions

BotOS is pre-release. No version is under a support or backport commitment yet.
This section will be replaced when the first release is cut.

## Reporting a vulnerability

**Please do not open a public issue for a security problem.**

Report it privately through GitHub's private vulnerability reporting on this
repository (Security -> Report a vulnerability). If that is unavailable to you,
contact the repository owner directly through their GitHub profile.

Please include:

- what the issue is, and the impact you believe it has
- the steps to reproduce it
- the commit or version you observed it on

Expect an acknowledgement within a few days. Please give us a reasonable window
to ship a fix before disclosing publicly.

## Handling secrets in this repository

- Real credentials belong in a local `.env`, which is gitignored. Only names
  and placeholders go in `.env.example`.
- `make verify` scans the working tree for common credential formats and fails
  the build on a match.
- If a secret does reach the repository, **rotate it first** — treat it as
  compromised the moment it is pushed. Scrubbing history is the follow-up, not
  the fix.
