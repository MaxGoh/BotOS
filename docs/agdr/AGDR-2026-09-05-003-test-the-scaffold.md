---
# AGDR-2026-09-05-003: Test the scaffold, and ship the verify skills

**Date:** 2026-09-05
**Type:** infra
**Scope:** `scripts/test.sh`, `tests/`, `scripts/verify.sh`, `Makefile`, `.claude/skills/`
**Agent:** claude-opus
**Status:** Applied

## Decision

The follow-up ticket to AGDR-2026-09-05-001 listed seven items. Five of them
depend on a product design that still has not reached this repository. Two do
not, and those two were done:

- **Dimension 4.** Added `scripts/test.sh` (a POSIX shell runner that globs
  `tests/test_*.sh`), `tests/lib.sh` (assertions plus a fixture builder), and
  three test files covering `scripts/verify.sh`, `scripts/bootstrap.sh`, and
  the `Makefile`/CI wiring — 39 cases. Replaced the `make test` failure stub
  with the real runner, and registered `check_tests` in `run_all()` in
  `scripts/verify.sh` so `make verify` remains the single gate.
- **Dimension 6.** Added `.claude/skills/verifying-changes/SKILL.md` and
  `.claude/skills/extending-the-verify-loop/SKILL.md`, plus `check_skills` in
  the gate, which fails a skill with no `SKILL.md`, no frontmatter `name` or
  `description`, or a `name` that does not match its directory.

A test's fixture is a scratch git repo built from the current working tree.
Each case breaks exactly one thing in it and asserts the gate reports it.

The remaining five items were **not** done, and no partial credit was taken
for them. See "Impact".

## Rationale

The scaffold was the only code in the repository, so it was the only thing
that could honestly be tested. That turns out to be the right target anyway:
`scripts/verify.sh` is the file every future change is judged by, and before
this change nothing proved its checks fired. The negative testing recorded in
`docs/mc-readiness-report.md` was done by hand in a scratch copy and thrown
away — a one-time observation, not a standing guarantee.

Testing the gate is documentation of existing behaviour, not invention, so it
was safe to do without the product design. The same is true of the two skills:
both describe a workflow that exists today and that was exercised in writing
them. A "how to run BotOS" skill was deliberately not written, because there
is nothing to run.

The suite is written in POSIX shell so the zero-dependency constraint carried
forward from AGDR-2026-09-05-001 still holds: no AGDR-justified dependency was
needed, because no dependency was added.

`scripts/verify.sh` now runs `shellcheck -s sh -x` rather than `-s sh`. The
new files are sourced libraries and their consumers, and without `-x`
shellcheck cannot follow `. tests/lib.sh` — it reported SC1091 on all three
test files and SC2154 on every variable they read from the library. Those are
info/warning level, which shellcheck still exits non-zero on, so the gate
would have gone red in CI (which ships shellcheck) while staying green on a
box without it. `-x` resolves it correctly rather than by suppression; one
genuine SC2034 in `tests/lib.sh` is suppressed inline with a reason.

Every case was **mutation-tested**: with a check commented out of `run_all()`,
the suite must fail. All nine checks, the shellcheck sub-path, and seven wiring
mutations were confirmed caught. One case initially passed for the wrong reason — the empty-`PATH`
bootstrap test stayed red when `make` was downgraded to optional, because
`git` was missing too — and was tightened to pin the required-tool set by name
and count.

## Alternatives Considered

- **Wait for the design and do nothing.** Rejected: it leaves the gate
  unproven and the skills unwritten, neither of which the design affects. The
  five blocked items are reported as blocked instead.
- **Guess a toolchain to give dimensions 4, 5 and 9 something to test.**
  Rejected outright. Picking, say, Node or Go to satisfy a scorecard would
  write a decision into the repository that the owner never made, and
  `bootstrap.sh` would then install a dependency nobody approved.
- **Run the suite as its own CI step.** Rejected: two entry points drift. The
  gate calls the suite, and CI calls the gate.
- **Exempt the test suite from `check_secrets`** so credential fixtures could
  be written literally. Rejected: an exemption list is exactly how a real leak
  gets through. The shapes are assembled at runtime by `secret_shape()`
  instead.

## Impact

- `make verify` now runs the suite; it is slower — about 19s on a box with
  shellcheck installed, since it spawns a fixture repo per case — and it
  remains the only command anyone needs to run.
- `shellcheck` is invoked with `-x`. It stays optional; a box without it gets
  a `note` and a shorter run, exactly as before.
- `make test` no longer exits 1 by design. Anything keyed off that failure
  should be updated.
- `scripts/test.sh` exports `BOTOS_SKIP_TESTS=1`. The gate and the suite call
  each other; that export is what bounds the recursion at depth one. Removing
  it hangs `make verify`. The cycle is documented in
  `DEPENDENCY-GRAPH.md`.
- `scripts/test.sh` is now a required file, so deleting it fails the gate.
- **Not addressed, still blocked on a product design:** `AGENTS.md`
  "What This Is" and "Architecture"; the application-module section of
  `DEPENDENCY-GRAPH.md`; dimension 5 (`bootstrap.sh` installs nothing because
  no toolchain has been chosen); a run-the-app skill; and dimension 9 (full
  runnability), which cannot exist before an app does.

## Related

- `AGDR-2026-09-05-001-agent-ready-foundation.md` — the scaffold this builds on.
- `../mc-readiness-report.md` — the refreshed scorecard.
