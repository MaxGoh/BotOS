# AGDR-2026-09-06-003: Import approved architecture and begin feasibility

**Date:** 2026-09-06
**Type:** design
**Scope:** docs/design, docs/plans, docs/validation, experiments, AGENTS.md, docs/BUILD.md
**Agent:** Codex
**Status:** Applied to working tree; feasibility unresolved

## Decision

Import the operator-approved technical architecture and phased implementation
plan. Start evidence collection before committing to provider, private-takeover
and managed-host mechanisms. Preserve the approved prototype unchanged.

## Rationale

The operator approved the consolidated technical review and then authorized
proceeding. The foundation previously described the stack and plan as undecided.
The imported documents preserve the distinction between an approved requirement
and a mechanism that has passed an actual test.

## Alternatives Considered

Starting application implementation before proving the credential and takeover
boundaries would bake unresolved assumptions into the runtime. Substituting Xvfb
for the approved display candidate would not test the required composition.

## Verification

Baseline at 89283bd56a6014ec88aed42cf018f5f6c214a26b: `make verify` passed 12
checks and 3 test files with zero failures. This covers the foundation only.

Generated the experimental login schema from installed Codex CLI 0.153.4.
The external-token branch requires `accessToken` and is marked internal-use-only.
No login, inference, credential-file inspection or paid provider request occurred.

The local host inventory lacks the runtime, VM device and display components
needed for the assembled workstation tests. Gate results distinguish blocked
experiments from the failed external-token candidate. Final working-tree gate
results are recorded in the validation handoff.

## Consequences

No production dependencies, public APIs or runtime code are introduced. No
provider or private-takeover gate is passed. Actual supported-host execution and
supported provider-path validation remain required.

## Related

- [Technical architecture](../design/technical-design.md)
- [Phased plan](../plans/implementation-roadmap.md)
- [Feasibility plan](../plans/feasibility.md)
