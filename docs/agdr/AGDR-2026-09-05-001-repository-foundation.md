# AGDR-2026-09-05-001: Establish the BotOS repository foundation

**Date:** 2026-09-05
**Type:** chore
**Scope:** Root instructions and docs/
**Agent:** Codex
**Status:** Applied to local foundation; destination repository pending confirmation

## Decision

Create canonical AGENTS.md instructions, a relative CLAUDE.md symlink to AGENTS.md, append-only decision records, a build entry point, repository conventions, and an as-built dependency record. Include the operator-approved product design and standalone prototype with screenshots and verification provenance.

## Rationale

The operator requested BotOS conventions modeled on Mission Control before implementation planning continues. BotOS is a separate product. Its application stack, infrastructure implementation, and license have not been selected, so the foundation does not prescribe or scaffold them.

## Verification

Validate the symlink target, Markdown local links, manifest hash for the unchanged approved HTML, and decision-record naming before handoff. Prototype evidence records 12 parent browser checks and JavaScript syntax validation from the approved-design session. No application tests exist at this stage.

## Consequences

Agents have one instruction source and an append-only record of decisions. The repository has no production routes or runtime dependencies. The design's illustrative data remains documentation-only. Remote repository creation and publishing follow the operator's confirmed destination and active harness contract.

## Related

- ../BUILD.md
- ../design/product-design.md
- ../design/approved/manifest.json
