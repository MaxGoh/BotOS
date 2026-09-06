# AGDR-2026-09-06-004: Contributor-owned feasibility checks

**Date:** 2026-09-06
**Type:** chore
**Scope:** scripts, tests, Makefile, CI, contributor documentation
**Agent:** Codex
**Status:** Applied

## Decision

Add a portable credential-free isolation negative control and host prerequisite
inventory. Run the existing verification gate on Linux and macOS CI. Keep
provider and managed-workstation validation as explicit unpassed release gates.

## Rationale

The operator clarified that BotOS is open source: progress must not depend on
access to a personal host. Contributors need commands they can run independently
without sharing credentials or installing a speculative runtime.

## Alternatives Considered

A personal-host access requirement was rejected. Automatically provisioning an
unproven workstation stack would conflate setup success with security evidence.
No additional language toolchain or container dependency is necessary here.

## Verification

Three new behavior cases failed before the probe script existed, then passed:
actual same-UID access, invalid-mode rejection, and unvalidated host-gate status.
The regular verify suite discovers these cases without a second test runner.
Linux verification is recorded in the work log; macOS execution awaits CI.

## Consequences

No real provider traffic, secret access or runtime installation occurs. Inventory
returns status 2, never an integration pass. The approved prototype is unchanged.

## Related

- [Contributor checks](../validation/CONTRIBUTING.md)
- [Feasibility plan](../plans/feasibility.md)
