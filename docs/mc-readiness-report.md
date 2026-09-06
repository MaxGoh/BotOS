# Agent-Readiness Report — BotOS

**Last evaluated:** 2026-09-05 UTC
**Reconciled:** 2026-09-06 UTC — against the approved product design, which
reached the repository on `main` after this evaluation was scored. Scores were
not re-derived by a fresh evaluation run; the notes below say which statements
the design closed.
**Overall level:** Not ready

## Summary

The previous evaluation scored 5 present, 2 partial, 2 absent. This one scores
**7 present, 1 partial, 1 absent**: dimension 4 (build/test/verify) rose from
partial to present, and dimension 6 (skills) from absent to present.

The level is still **Not ready**, and that is still the honest result. The
rollup requires no dimension to be `absent`, and dimension 9 (full
runnability) cannot be met by a repository with no application in it.

**The remaining blockers are not foundation defects — the repository is
greenfield.** This evaluation flagged a missing product design as the common
cause behind dimensions 1, 3, 5 and 9. That cause has since been removed: the
approved design landed on `main` (see
[`AGDR-2026-09-06-001`](agdr/AGDR-2026-09-06-001-apply-approved-design.md)),
and `AGENTS.md` and `docs/DEPENDENCY-GRAPH.md` now carry the real product
definition. What is left is implementation, not documentation: dimension 5
cannot install a toolchain nobody has chosen, dimension 3's module-edge
section stays empty until modules exist, and dimension 9 cannot document how
to run an application that has not been built. The approved design records
requirements, not a stack.

## Dimension scorecard

| # | Dimension | Score | Notes |
|---|-----------|-------|-------|
| 1 | Agent instructions | present | `AGENTS.md` covers commands, tests, conventions and guardrails; `CLAUDE.md` points to it so harnesses share one source of truth. Its Product and Architecture sections were unfilled when this was scored; the approved design has since landed and both now carry the real definition. |
| 2 | Decision records | present | `docs/agdr/` holds a when/how guide, a template, and one real record per substantive change so far. Append-only; reversals supersede rather than delete. |
| 3 | Codebase orientation | present | Directory map covers every path that exists, and the foundation's own dependency edges are now drawn — including the verify↔test cycle and the guard that bounds it. The application-module section stays empty because there are no modules. |
| 4 | Build / test / verify loop | present | Was partial. `scripts/test.sh` runs 46 cases across `tests/test_{verify,bootstrap,make}.sh`; `make test` is a real runner and `check_tests` is registered in `run_all()`, so `make verify` remains the single gate CI runs. No build step, because there is nothing to compile. |
| 5 | Setup / bootstrap contract | partial | `make bootstrap` checks the toolchain, names what is missing, and exits non-zero — behaviour now pinned by tests rather than asserted. It still installs nothing, because no toolchain has been chosen. Becomes a real contract when one is. |
| 6 | Skills | present | Was absent. `.claude/skills/verifying-changes/` and `.claude/skills/extending-the-verify-loop/` encode workflows that exist today and were exercised in writing them. `check_skills` fails the gate on a missing `SKILL.md`, missing `name`/`description` frontmatter, or a name that does not match its directory. |
| 7 | Guardrails & safety | present | `AGENTS.md` names what needs approval and what must never be committed; the MIT-license guardrail and the secret patterns are mechanically enforced by the gate, and both enforcement paths are now covered by tests. A "no vacuous tests" guardrail was added. |
| 8 | Secrets & env config | present | `.env.example` documents the names-and-placeholders contract; `.gitignore` excludes `.env`; the gate fails on a populated value or a credential-shaped string in any tracked file. Both the failing and the accepted placeholder forms are tested. |
| 9 | Full runnability (preconditions) | absent | No application exists, so no full-app run command can exist and no live run can be confirmed. A "how to run BotOS" skill was deliberately not written for the same reason. Blocked on product code existing at all. |

Tally: 7 present, 1 partial, 1 absent.

## Remediated (working tree, uncommitted)

Authored by this change:

- `scripts/test.sh` — suite runner; globs `tests/test_*.sh`, fails an empty suite.
- `tests/lib.sh` — assertions, plus a fixture builder that clones the working
  tree into a scratch git repo so checks are exercised against a real layout.
- `tests/test_verify.sh` — 30 cases; every gate check, each proved to fire,
  including the optional shellcheck lint path.
- `tests/test_bootstrap.sh` — 5 cases; the setup contract's success and
  failure paths, with the required-tool set pinned by name and count.
- `tests/test_make.sh` — 11 cases; `Makefile` targets and the CI wiring.
- `.claude/skills/verifying-changes/SKILL.md` — run the gate, read the failures.
- `.claude/skills/extending-the-verify-loop/SKILL.md` — add a check, a test, or
  a toolchain, without splitting the gate in two.
- `scripts/verify.sh` — added `check_tests` and `check_skills`, registered both
  in `run_all()`, added `scripts/test.sh` to the required-file set.
- `Makefile` — `make test` now runs the suite instead of exiting 1 by design.
- `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `docs/DEPENDENCY-GRAPH.md` —
  updated in the same change, per the docs-live-with-the-code rule.
- `docs/agdr/AGDR-2026-09-05-003-test-the-scaffold.md` — the decision record,
  including what was deliberately not done and why. (Numbered `002` when it was
  written; renumbered to `003` when it merged with `main`, whose own `002` for
  that day had already been published.)

`LICENSE` was not modified, and remains protected by a check.

## Verification performed

Not merely written — exercised:

- `make verify` passes: **12 checks, 0 failures**, which includes the suite.
- `make test` passes: **3 test files, 46 cases, 0 failures**.
  (Scored at 9 checks / 39 cases; `main` then merged in three further checks —
  `check_claude_symlink`, `check_agdr_naming`, `check_approved_design` — and
  seven cases were written to cover them, plus the fixture-symlink guard.)
- `make bootstrap` passes and reports the toolchain.
- **Mutation-tested, which is the claim that matters.** Each of the twelve
  checks was removed from `run_all()` in a scratch copy in turn; the suite
  failed every time. The three checks that arrived from `main` were mutation-
  tested the same way when their cases were written. The optional shellcheck sub-path was stubbed out separately and
  was also caught. Seven further mutations were injected into the wiring — `make
  test` not calling the runner, `check` no longer aliasing `verify`, bootstrap
  always exiting 0, bootstrap dropping the `.env` hint, the runner passing on
  an empty suite, CI no longer running `make verify`, and `make` downgraded
  from required to optional — and all seven were caught.
- One case initially passed for the wrong reason: the empty-`PATH` bootstrap
  test stayed red when `make` was made optional, because `git` was missing in
  that run too. It was tightened to assert each required tool by name and to
  pin the count. Re-running the mutation then caught it. A test that passes for
  the wrong reason is the failure mode this whole exercise exists to prevent.
- **CI-only lint failure, found and fixed before shipping.** CI runs on
  `ubuntu-latest`, which ships shellcheck; this box did not. Installing it and
  running the gate the way CI would showed the new files failing on SC1091 and
  SC2154 — shellcheck cannot follow `. tests/lib.sh` without `-x`, so the
  library's variables looked undefined. The gate now passes `-x`. This is the
  second time this class of drift has bitten the repository, which is why the
  lint path now has a test of its own.
- The recursion between the gate and the suite was checked in both directions:
  `BOTOS_SKIP_TESTS=1` bounds it at depth one, and tests set it to `0` against
  a stubbed runner to prove the gate really does fail when the suite fails.

## Flagged for human (not auto-fixed)

- **Product definition (dim 1)** — ~~`AGENTS.md` Product and Architecture are
  unfilled.~~ **Resolved 2026-09-06.** The approved design was not reachable
  from the box that produced this report, so both sections were left unfilled.
  The design was in fact already approved; it has since been transferred into
  `docs/design/` and both files now carry the real product definition. See
  [`AGDR-2026-09-06-001`](agdr/AGDR-2026-09-06-001-apply-approved-design.md).
- **Application module edges (dim 3)** — the module-edge section of
  `docs/DEPENDENCY-GRAPH.md` stays empty until modules exist.
- **Setup contract (dim 5)** — `bootstrap.sh` installs nothing because no
  toolchain has been chosen. Choosing one needs an AGDR, since the repository's
  zero-dependency stance is a recorded decision, and the approved design
  records requirements rather than a stack.
- **Full runnability (dim 9)** — needs a documented run command and live
  verification. Blocked on application code.
- **A run-the-app skill (dim 6)** — the two skills that could honestly be
  written were. A third, covering the run loop, waits on dim 9.

No suspected committed secrets were found.

## Published

- `docs/mc-readiness-report.md` — this report.
- `docs/mc-readiness.json` — machine-readable scorecard, same date and level.
- `README.md` — marker-bounded readiness badge refreshed in place.

## Deferred

- Live infra + full-runnability confirmation — run the infra/verify skill once
  BotOS has an application to boot.

## Machine-readable output

- `docs/mc-readiness.json` — structured scorecard with the same evaluation date and level.
