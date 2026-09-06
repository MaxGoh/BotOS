---
# AGDR-2026-09-06-002: Reconcile the test-suite branch with the approved design

**Date:** 2026-09-06
**Type:** docs
**Scope:** `AGENTS.md`, `README.md`, `docs/`, `scripts/verify.sh`, `tests/`, `.claude/skills/`
**Agent:** claude-opus
**Status:** Applied

## Decision

Resolve the merge between this branch and `main`, taking `main` as
authoritative wherever the two disagreed about the product, and this branch as
authoritative wherever they disagreed about the gate.

The branch and `main` were written against different views of the world. The
branch (AGDR-2026-09-05-003) recorded that no approved product design had
reached the repository and deliberately left the product-shaped sections of
`AGENTS.md` and `docs/DEPENDENCY-GRAPH.md` unfilled. `main` then landed the
approved design (AGDR-2026-09-06-001) and filled exactly those sections. The
design was available all along; the branch's box could not reach it. Six files
conflicted:

- **`AGENTS.md`** — took `main`'s Product and Architecture sections, and its
  Session workflow, Decision records, Security and access, and Implementation
  sections. Kept the branch's "Growing the verify loop" guidance, which
  describes a suite that now exists, over `main`'s "when a real test suite
  exists" placeholder. Kept both guardrail bullets. Extended the directory map
  with `tests/` and `.claude/skills/`.
- **`README.md`** — took `main`'s product description and status block, adding
  the foundation's test suite and skills to it. Kept the branch's layout rows.
- **`docs/DEPENDENCY-GRAPH.md`** — kept `main`'s Mermaid diagram and its
  component and surface tables, and extended the diagram with the suite, the
  skills, and the verify↔test cycle the branch documented.
- **`scripts/verify.sh`** — union of both required-file lists. Both sides' new
  checks survived the automatic merge; only the list conflicted.
- **`docs/mc-readiness.json`, `docs/mc-readiness-report.md`** — kept the
  branch's newer scorecard (7 present, 1 partial, 1 absent) and marked the
  dimension 1 gap resolved rather than re-scoring. Level stays **Not ready**,
  because dimension 9 is still absent.

Two things the merge broke, fixed here rather than left:

- **`tests/lib.sh` used `cp -p`, which dereferences symlinks.** `main` made
  `CLAUDE.md` a real symlink and added `check_claude_symlink`. Every fixture
  therefore held a regular file, and the check failed in every case. Changed to
  `cp -Pp`, and added a case that asserts the fixture's `CLAUDE.md` is still a
  symlink, so the next regression names itself.
- **`main` added three checks with no test cases**, breaking the property this
  branch exists to establish. Added seven cases covering
  `check_claude_symlink`, `check_agdr_naming`, and `check_approved_design`.

`AGDR-2026-09-05-002-test-the-scaffold.md` was renumbered to `-003-`. `main`
had already published its own `-002-` for that day. Records are append-only
once merged; this one had not merged, so renumbering it before it lands is what
keeps the published sequence intact.

## Rationale

`main` is the shared history and its product definition is sourced from an
approved design, so it wins on product. This branch is the only side that has
a working test suite, so it wins on the gate. Neither side is wrong about its
own subject; the conflict is only that each was written without the other.

The alternative — resolving by taking one side wholesale — would have thrown
away either the approved product definition or the 46-case suite. Taking the
branch's "the product is still unrecorded" text would have been actively
false: the design is in `docs/design/` in this same tree.

The three uncovered checks could have been left as `main` shipped them. That
was rejected: `AGENTS.md` states that every check in the gate has a case that
fails when the check is removed from `run_all()`. A merge that leaves three
checks uncovered makes the instructions untrue for the next agent that reads
them.

The readiness scores were not re-derived. A fresh evaluation is a separate
piece of work; silently restating old scores as new ones would be the same
error this branch's earlier record warned about. Both readiness files now say
which statements were reconciled and which were scored.

## Alternatives Considered

- **Rerun `mission-control:mc-readiness` to regenerate both files.** Rejected
  for this change: the task was to resolve conflicts, and a fresh evaluation
  would change scores under cover of a merge. Worth doing as its own change.
- **Leave the AGDR numbering collision.** Rejected. `docs/agdr/README.md` says
  to increment the sequence for the day; two `-002-` records for 2026-09-05
  break the ordering the log depends on. (`main` already carries two `-001-`
  records for that day. Those are published, so they stay; correcting them
  would be rewriting history.)
- **Suppress `check_claude_symlink` in fixtures.** Rejected. The check would
  then be untested exactly where it matters, and the fixture would stop being
  a faithful copy of the tree.

## Verification

- `make verify`: **PASS, 12 checks, 0 failures**, which includes the suite.
- `make test`: **PASS, 3 test files, 46 cases, 0 failures**.
- Repeated with `shellcheck` v0.10.0 on `PATH`, matching CI's
  `ubuntu-latest` image: green, with the lint case exercised rather than
  noted. This was checked because the same CI-only drift has bitten the
  repository twice.
- `check_claude_symlink`, `check_agdr_naming`, and `check_approved_design`
  were each commented out of `run_all()` in a scratch copy in turn; the suite
  failed every time, naming the new cases.
- Reverting `cp -Pp` to `cp -p` fails the new fixture case with
  "CLAUDE.md was dereferenced by fixture_new", so that guard is not vacuous.
- No conflict markers remain: `grep -rn '^<<<<<<<\|^>>>>>>>'` over the tree is
  empty.
- `LICENSE` unmodified; the approved prototype's bytes unmodified, and its
  hash still matches its manifest.

## Impact

- The gate is 12 checks, not 9. Documents quoting the old count were updated:
  `docs/BUILD.md`, `docs/mc-readiness-report.md`, `docs/mc-readiness.json`,
  and `.claude/skills/verifying-changes/SKILL.md`, whose failure table now
  covers the three merged-in checks.
- `tests/lib.sh` fixtures preserve symlinks. Any future check that inspects
  file type will now see what the real tree has.
- `AGDR-2026-09-05-002-test-the-scaffold.md` no longer exists under that name.
  Nothing outside the readiness files referenced it; those were updated.
- **Still open, unchanged by this merge:** dimension 5 (`bootstrap.sh`
  installs nothing, because no toolchain has been chosen), dimension 3's
  application-module edges, and dimension 9 (full runnability). These are
  blocked on implementation, not on the design — the approved design records
  requirements, not a stack. Choosing one still needs its own AGDR.

## Related

- `AGDR-2026-09-05-003-test-the-scaffold.md` — the branch being merged.
- `AGDR-2026-09-06-001-apply-approved-design.md` — the `main` change that
  supplied the product definition.
- `../mc-readiness-report.md` — the reconciled scorecard.
