# AGDR-2026-09-06-005: Full-release OpenSpec implementation change

**Date:** 2026-09-06
**Type:** design
**Scope:** openspec, docs/BUILD.md, docs/DEPENDENCY-GRAPH.md
**Agent:** Codex
**Status:** Applied specification; implementation pending

## Decision

Create `openspec/changes/implement-full-release` with proposal, design, capability
deltas and a dependency-ordered implementation checklist. Cover the full selected
release rather than only the first core slice. Core work starts in parallel with
feasibility; unsafe integrations remain gated on actual evidence.

## Rationale

The operator requested an OpenSpec for the complete release plan. Prior artifacts
separated brainstorming, roadmap and experiments but lacked one structured change
with requirements, scenarios, task ownership and acceptance gates.

## Alternatives Considered

A dashboard-only specification would omit most release requirements. Treating all
feasibility gates as prerequisites for basic agent CRUD would unnecessarily stop
independent development. Creating production stubs would obscure missing behavior.

## Verification

OpenSpec 1.12.0 strict validation checks the change structure. Local structural
review checks requirement/scenario coverage, capability/task mappings and links.
`make verify` checks the repository; none of these certify application behavior.
All future implementation checkboxes remain unchecked.

## Consequences

No application code or production dependency is added. Node/npm is used only for
the optional pinned OpenSpec authoring validator. Existing prototype and MIT
license remain unchanged. The harness owns publication.

## Related

- [Proposal](../../openspec/changes/implement-full-release/proposal.md)
- [Tasks](../../openspec/changes/implement-full-release/tasks.md)
- [Approved technical design](../design/technical-design.md)
