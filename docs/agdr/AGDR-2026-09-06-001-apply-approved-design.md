# AGDR-2026-09-06-001: Apply the approved design and the CLAUDE.md symlink

**Date:** 2026-09-06
**Type:** docs
**Scope:** Root instructions, `docs/`, `scripts/verify.sh`
**Agent:** claude-opus (Mission Control agent box)
**Status:** Applied — supersedes the product-definition gap recorded in
AGDR-2026-09-05-001-agent-ready-foundation and completes the destination
transfer proposed in AGDR-2026-09-05-002-confirm-repository-and-license

## Decision

Integrate the prepared BotOS repository foundation and the operator-approved
product design into `MaxGoh/BotOS`, on top of the merged scaffold rather than
replacing it.

- Replaced the regular file `CLAUDE.md` with a real relative symlink to
  `AGENTS.md`.
- Merged the prepared BotOS instructions into `AGENTS.md`: the real product
  definition, session workflow, append-only decision-record rules, the
  approved design's security and access requirements, and the directory map —
  keeping the scaffold's `make verify` gate, license guardrail, secrets rules,
  and shell conventions.
- Added `docs/BUILD.md`, `docs/conventions.md`, `docs/design/product-design.md`
  and `docs/design/approved/` (prototype, two screenshots, `manifest.json`,
  `verification.json`, `README.md`).
- Merged the prepared dependency record into `docs/DEPENDENCY-GRAPH.md` and
  the prepared agDR template and README into the existing ones.
- Added the two prepared records,
  `AGDR-2026-09-05-001-repository-foundation.md` and
  `AGDR-2026-09-05-002-confirm-repository-and-license.md`, alongside the
  existing `AGDR-2026-09-05-001-agent-ready-foundation.md`. Two records share
  the `2026-09-05-001` sequence because they were written independently on two
  boxes; neither was overwritten.
- Updated `README.md` to link the design, prototype, screenshots, BUILD, and
  conventions.
- Added four checks to `scripts/verify.sh`: `check_claude_symlink`,
  `check_approved_design`, `check_agdr_naming`, and the new required files.

## Rationale

The previous run produced a generic scaffold and a regular-file `CLAUDE.md`
because the approved design was not reachable from that box. The design
existed and was approved; the correction is to apply it rather than to leave
the agent contract product-shaped and unfilled. A symlink — not a pointer file
— is what keeps one instruction source from silently diverging.

## Alternatives Considered

- **Overwrite the merged scaffold with the prepared tree.** Rejected: it would
  discard working CI, the verify loop, `CONTRIBUTING.md`, `SECURITY.md`, and
  the existing decision record.
- **Rewrite the earlier record's "no design available" statement.** Rejected:
  records are append-only. The correction is stated here instead, and the
  generated readiness report — which is not a record — carries a dated
  correction note pointing at this file.

## Verification

Run on this box on 2026-09-06. Distinguish these from the historical evidence
in `docs/design/approved/verification.json`, which records 12 parent browser
checks from the original approved-design session and was **not** re-run here.

| Check | Result |
|---|---|
| Archive SHA-256 vs the ticket's expected value | `ff7bfdf2…dedbd6`, matched |
| Archive paths confined to `botos/`, single symlink `CLAUDE.md -> AGENTS.md` | 24 entries, confirmed; no archive script executed |
| `sha256sum docs/design/approved/prototype.html` vs `manifest.json` | `7e581c9b…0bf144`, matched; 125231 bytes as recorded |
| Prototype inline JavaScript, `node --check` (node v22.23.2) | passed, 1 inline block |
| `LICENSE` vs the merged scaffold's copy | byte-identical, unmodified |
| `readlink CLAUDE.md` | `AGENTS.md` |
| `make verify` | **PASS — 10 checks, 0 failures** |
| New checks negative-tested in a scratch copy | each fires: regular-file `CLAUDE.md`, wrong symlink target, mutated prototype, misnamed record |
| File modes and whitespace in the applied diff | all 644, LF endings, no trailing whitespace |

No application runtime exists, so nothing was built or run. `shellcheck` is
not installed on this box; that check reported itself as skipped.

## Consequences

Agents resolve one instruction source through the symlink, and the agent
contract now states what BotOS actually is. The approved snapshot is immutable
under the gate: changing `prototype.html` fails `make verify`, so a future
approved revision must be added as a new version with its own manifest.

The repository still has no product implementation, application stack, or
build target, and this change adds none. The phased implementation plan
remains the next deliverable.

PR #2 was open and unmerged when this change was prepared; it was inspected
read-only. It extends `scripts/verify.sh`, `AGENTS.md`, `README.md`, and
`docs/DEPENDENCY-GRAPH.md` too, so a textual merge conflict on those files is
expected. This change adds `check_*` functions and registers them in
`run_all()`, matching the extension pattern PR #2 documents.

## Related

- `AGDR-2026-09-05-001-agent-ready-foundation.md`
- `AGDR-2026-09-05-001-repository-foundation.md`
- `AGDR-2026-09-05-002-confirm-repository-and-license.md`
- `../BUILD.md`
- `../design/product-design.md`
- `../design/approved/manifest.json`
