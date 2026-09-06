# AGDR-2026-09-06-006: Integrate the prepared full-release plan into this repository

**Date:** 2026-09-06
**Type:** process
**Scope:** openspec, docs, experiments, scripts/feasibility.sh, tests/test_feasibility.sh, Makefile, .github/workflows/ci.yml
**Agent:** Claude
**Status:** Applied to the working tree; publication owned by the harness

## Decision

Apply the prepared full-release change set — the OpenSpec change
`implement-full-release`, the technical design and roadmap, the provider and
managed-host experiment records, the contributor feasibility probe with its
test, the two-OS CI matrix, and decision records 003–005 — onto the current
`main` commit `89283bd` without modification. Add this record for the
integration itself, per the append-only convention.

## Rationale

The change was authored against this exact base commit in a separate session.
Every one of the 44 files applied cleanly: the six modified files are purely
additive against the current content and none of the 38 new paths collided
with existing work, so there was nothing to reconcile. Rewriting or resequencing
the prepared records would have contradicted the append-only rule and lost the
provenance of the work that produced them.

## Alternatives Considered

Re-deriving the plan locally was rejected — the operator asked for integration
of prepared work, not a fresh design. Renumbering the incoming records was
unnecessary: existing 2026-09-06 records stop at 002, so 003–005 do not clash.
Checking off completed-looking tasks was rejected; no application code exists.

## Verification

Observed in this session on Linux x86_64:

- `make verify` — PASS, 12 checks and 4 test files, 0 failures.
- `make feasibility` — the same-UID reader reached the marker, confirming that
  file modes plus an empty environment are not isolation. This is a negative
  control, not a privacy certification.
- `make feasibility-host` — exits 2 by design; `limactl`, `kubectl` and an
  accessible `/dev/kvm` are all absent here.
- `git diff --check` — clean.
- `OPENSPEC_TELEMETRY=0 npx --yes @fission-ai/openspec@1.12.0 validate
  implement-full-release --strict` — "Change 'implement-full-release' is valid".
- All 54 implementation checkboxes in `tasks.md` remain unchecked; zero checked.

Not observed: the macOS CI job is configured but has not run, and the G1/G2/G3
hardware and provider gates remain unpassed. No provider request was executed
and no workstation was installed.

## Consequences

The repository still contains no application runtime; this change is
specification, documentation, and contributor-side checks only. `LICENSE` and
the approved prototype under `docs/design/approved/` are byte-identical to
`main`. `CLAUDE.md` remains a relative symlink to `AGENTS.md`. Node and npm are
needed only for the optional pinned OpenSpec authoring validator, which is not
part of `make verify`.

## Related

- [AGDR-2026-09-06-003](AGDR-2026-09-06-003-technical-feasibility.md)
- [AGDR-2026-09-06-004](AGDR-2026-09-06-004-contributor-feasibility.md)
- [AGDR-2026-09-06-005](AGDR-2026-09-06-005-full-release-openspec.md)
- [Tasks](../../openspec/changes/implement-full-release/tasks.md)
