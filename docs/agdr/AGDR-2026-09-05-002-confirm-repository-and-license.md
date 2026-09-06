# AGDR-2026-09-05-002: Confirm repository and license

**Date:** 2026-09-05
**Type:** docs
**Scope:** Repository foundation
**Agent:** Codex
**Status:** Applied to local checkout of MaxGoh/BotOS

## Decision

Apply the prepared foundation to the operator-selected MaxGoh/BotOS repository. Preserve its existing MIT LICENSE unchanged. This supersedes the destination and license uncertainty recorded in AGDR-2026-09-05-001 and the historical approved product design.

## Rationale

The operator selected https://github.com/maxgoh/botos. Its main branch at 93e7ebc4edf5ed3047f8879f6b4322a181c456d6 contains only LICENSE. No application code or agent instructions need migration.

## Verification

Check the original license against HEAD, the relative CLAUDE.md symlink, local Markdown links, agDR names, and approved HTML hash. No application runtime exists to build or test.

## Consequences

The foundation is prepared in the target repository checkout. Publication remains the harness's responsibility; this session's declared publishing repository is Mission Control. Preserve the approved design and its provenance while arranging a target-bound publication.
