# Agent-Readiness Report — BotOS

**Last evaluated:** 2026-09-05 UTC
**Overall level:** Not ready

## Summary

Before this change the repository contained one file, `LICENSE`. All nine
dimensions scored `absent` and the level was **Not ready**.

The foundation scaffold moved five dimensions to `present` and two to
`partial`. The level remains **Not ready**, and that is the honest result: the
rollup requires no dimension to be `absent`, and dimensions 6 (skills) and 9
(full runnability) cannot be satisfied until BotOS has application code. **The remaining gaps are bounded by the repository being
greenfield, not by the quality of the scaffold.**

## Dimension scorecard

| # | Dimension | Score | Notes |
|---|-----------|-------|-------|
| 1 | Agent instructions | present | `AGENTS.md` covers architecture, commands, conventions, guardrails; `CLAUDE.md` is a relative symlink to it so harnesses share one source of truth. |
| 2 | Decision records | present | `docs/agdr/` with `README.md` (when/how), `AGDR-0000-template.md`, and a first real record for this change. |
| 3 | Codebase orientation | present | `docs/DEPENDENCY-GRAPH.md` maps every directory. The module-edge section is deliberately empty — there is no application code to draw — and is marked TODO for the first module. |
| 4 | Build / test / verify loop | partial | `make verify` is real, enforced in CI, and was negative-tested. But there is no build step and no test suite: `make test` fails loudly rather than passing vacuously. Upgrades to `present` when a real suite lands. |
| 5 | Setup / bootstrap contract | partial | `make bootstrap` checks the toolchain and exits non-zero when a required tool is missing, but installs nothing because there is nothing to install. It becomes a real contract when a stack is chosen. |
| 6 | Skills | absent | No `.claude/skills/`. Skills encode real workflows; authoring them for a product that does not exist yet would be invention, not documentation. Flagged for a human. |
| 7 | Guardrails & safety | present | `AGENTS.md` "Guardrails & Safety" names what needs approval, what must never be committed, and the MIT-license guardrail — which `verify.sh` now mechanically enforces. |
| 8 | Secrets & env config | present | `.env.example` documents the names-and-placeholders contract; `.gitignore` excludes `.env`; `verify.sh` fails on a populated value or a credential-shaped string in any tracked file. No env vars are referenced in code, because there is no code. |
| 9 | Full runnability | absent | There is no application to run, so no full-app run command can exist. Not a scaffold defect — a precondition that only product code can satisfy. Needs live verification once it does. |

Tally: 5 present, 2 partial, 2 absent.

## Remediated (working tree, uncommitted)

- `AGENTS.md` — agent/contributor contract; seeds dimensions 1, 3, and 7.
- `CLAUDE.md` — pointer to `AGENTS.md`, avoiding two contracts that drift apart.
- `README.md` — human entry point: quick start, layout, dependency stance.
- `CONTRIBUTING.md` — the short version of the contract, plus rejection criteria.
- `SECURITY.md` — private vulnerability reporting and secret-handling policy.
- `docs/agdr/README.md` — when and how to write a decision record.
- `docs/agdr/AGDR-0000-template.md` — the template.
- `docs/agdr/AGDR-2026-09-05-001-agent-ready-foundation.md` — this change's record.
- `docs/DEPENDENCY-GRAPH.md` — directory map and dependency-edge stub.
- `Makefile` — `help`, `bootstrap`, `verify`, `check`, `test`, `clean`.
- `scripts/verify.sh` — the single gate; seven checks, extensible via `run_all`.
- `scripts/bootstrap.sh` — toolchain check.
- `.github/workflows/ci.yml` — runs `make verify` and nothing else.
- `.github/PULL_REQUEST_TEMPLATE.md` — requires evidence, not assertion.
- `.github/ISSUE_TEMPLATE/{bug_report,feature_request,config}.{md,yml}` — intake.
- `.env.example` — env contract, names and placeholders only.
- `.gitignore` — excludes `.env` while keeping `.env.example` tracked.
- `.editorconfig`, `.gitattributes` — consistent whitespace and LF endings.

`LICENSE` was not modified, and is now protected by a check.

## Verification performed

Not merely written — exercised:

- `make verify` passes: 7 checks, 0 failures.
- `make bootstrap` passes and reports the toolchain.
- Every check was **negative-tested** in a scratch copy: a missing required
  file, a relicensed `LICENSE`, altered copyright attribution, a shell syntax
  error, a non-executable script, trailing whitespace, a broken relative
  markdown link, a populated `.env.example` value, and three credential shapes
  (AWS key, PEM private key, GitHub token). All eleven were caught; an
  unmodified control copy still passed.
- `shellcheck -s sh` is clean on both scripts. This caught a real defect —
  SC2016 in `scripts/bootstrap.sh` — that would have failed CI, because
  GitHub's `ubuntu-latest` ships shellcheck while this box did not. It was
  fixed, and the shellcheck path was then confirmed to fail the gate on a
  genuine violation (SC3014).

## Flagged for human (not auto-fixed)

- **Dimension 6 (skills)** — a repo skill must encode a workflow that really
  exists. Author `.claude/skills/` once BotOS has a stack and a run loop.
- **Dimension 5 (setup contract)** — `bootstrap.sh` installs nothing because
  there is nothing to install. Extend it when a toolchain is chosen.
- **Dimension 9 (full runnability)** — needs live verification; blocked on
  application code existing at all.
- **Dimension 4** — `make test` deliberately exits non-zero. Replace the stub
  with a real runner and register it in `run_all` in `scripts/verify.sh`.
- **Product definition** — *Corrected 2026-09-06.* The approved product
  design was not reachable from the box that produced this report, so
  `AGENTS.md` and `docs/DEPENDENCY-GRAPH.md` were left product-shaped and
  unfilled. The design was in fact already approved; it has since been
  transferred into `docs/design/` and both files now carry the real product
  definition. See `docs/agdr/AGDR-2026-09-06-001-apply-approved-design.md`.
  The scores below predate that change and have not been re-evaluated.

No suspected committed secrets were found.

## Published

- `docs/mc-readiness-report.md` — this report.
- `docs/mc-readiness.json` — machine-readable scorecard, same date and level.
- `README.md` — marker-bounded readiness badge inserted after the H1.

## Deferred

- Live infra + full-runnability confirmation — run the infra/verify skill once
  BotOS has an application to boot.

## Machine-readable output

- `docs/mc-readiness.json` — structured scorecard with the same evaluation date and level.
