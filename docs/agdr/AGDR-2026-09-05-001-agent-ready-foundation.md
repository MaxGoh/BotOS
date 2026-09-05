---
# AGDR-2026-09-05-001: Establish the agent-ready repository foundation

**Date:** 2026-09-05
**Type:** infra
**Scope:** repository root, `docs/`, `scripts/`, `.github/`
**Agent:** claude-opus
**Status:** Applied

## Decision

Added the agent-readiness scaffold to a repository that previously contained
only `LICENSE`:

- `AGENTS.md` — the agent/contributor contract (commands, conventions,
  guardrails). `CLAUDE.md` is a pointer to it so every harness resolves to one
  source of truth rather than drifting copies.
- `docs/agdr/` — this decision log, with `README.md` (when and how to write
  one) and `AGDR-0000-template.md`.
- `docs/DEPENDENCY-GRAPH.md` — directory map, with the module graph left
  explicitly empty because no application code exists.
- `Makefile` — `help`, `bootstrap`, `verify`, `check`, `test`, `clean`.
- `scripts/verify.sh` — the single gate: required files, MIT license
  integrity, shell syntax + executable bit + shebang, `shellcheck` when
  available, credential scanning, `.env.example` hygiene, relative markdown
  link resolution, trailing whitespace.
- `scripts/bootstrap.sh` — toolchain check that installs nothing today.
- `.github/workflows/ci.yml` — runs `make verify`, nothing else.
- `.env.example`, `.gitignore`, `.editorconfig`, `.gitattributes`,
  `CONTRIBUTING.md`, `SECURITY.md`, PR and issue templates.

`LICENSE` was not modified. `verify.sh` now asserts that, so an accidental
relicensing fails the build.

## Rationale

The repository was empty, so an agent landing here had no commands to run, no
guardrails, and no way to tell whether its work was correct. The foundation
supplies those before any product code arrives, when it is cheapest to do.

Three constraints shaped it:

1. **No runtime dependencies.** The scaffold is `make` plus POSIX shell, both
   already present in any developer toolchain. Nothing to install means
   nothing to keep current, and it leaves the language choice genuinely open.
2. **CI runs the developer's command.** `ci.yml` invokes `make verify` and
   nothing else, so the gate cannot drift from what people run locally.
3. **No product speculation.** The product definition was not available, and
   inventing one would have written a fiction that later work had to unpick.
   Product-shaped sections are marked as unfilled rather than guessed.

The verify loop was tested by breaking each check in a scratch copy and
confirming it failed — a gate that cannot fail is decoration.

## Alternatives Considered

- **A language-specific scaffold** (`package.json`, `pyproject.toml`, …).
  Rejected: it would presuppose a stack nobody has chosen and add
  dependencies, against the foundation-only constraint.
- **`CLAUDE.md` and `AGENTS.md` as separate full documents.** Rejected: two
  copies of the same contract diverge. One pointer file avoids it.
- **A pre-commit hook framework.** Rejected: a runtime dependency, and it
  duplicates what `make verify` already does.
- **Lint-only CI with no local equivalent.** Rejected for the drift it invites.

## Impact

- `make verify` is now the contract for "is this change acceptable". New checks
  belong in `run_all` in `scripts/verify.sh`, so local and CI stay identical.
- The `test` target intentionally **fails** rather than passing vacuously; the
  first test suite replaces it.
- `.env.example` is enforced as names-and-placeholders only.
- Markdown links are checked, so moving a doc without updating references fails.

## Related

- `AGENTS.md` — the contract this record establishes.
- `docs/mc-readiness-report.md` — the readiness scorecard for this scaffold.
- Dimensions left for a human: setup contract beyond a toolchain check
  (`scripts/bootstrap.sh`), repo skills (`.claude/skills/`), and full
  runnability — all blocked on the product definition.
