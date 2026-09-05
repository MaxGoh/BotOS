# BotOS — Agent Instructions

This file is the contract for any automated agent (and any human) working in
this repository. Read it before your first edit. `CLAUDE.md` points here so
that Claude, Codex, and Gemini harnesses all resolve to one source of truth.

## What This Is

BotOS is a greenfield project owned by Max Goh, licensed MIT.

**The product definition is not yet recorded in this repository.** This commit
establishes the *foundation* only — the instructions, decision log, verify
loop, and CI that later product work is expected to land on top of. No
application code exists yet, and none should be inferred from this scaffold.

Before writing product code, record what BotOS is in an AGDR (see
`docs/agdr/`) and replace this section. Do not guess the product shape from
the repository name.

## Architecture

There is no application code yet, so there is no dependency graph to draw.
`docs/DEPENDENCY-GRAPH.md` holds the directory map and is the file to update
as soon as the first module lands.

## Key Commands

Every command below is implemented in pure POSIX shell plus `make`. The repo
has **zero runtime and zero build dependencies** today, and the verify loop is
designed to keep working as real dependencies arrive.

```bash
make help       # list every target
make bootstrap  # check the local toolchain; install nothing yet
make verify     # the full gate — run this before you hand work back
make check      # alias for verify
make test       # no test suite yet; fails loudly rather than passing silently
```

`make verify` is the single gate. CI runs exactly that target, so a green
`make verify` locally means a green CI run — keep it that way.

### Growing the verify loop

When you add a language toolchain, extend `scripts/verify.sh` rather than
adding a parallel command. Each check is a `check_*` shell function registered
in `run_all`; add yours there so it runs locally and in CI from one definition.
When a real test suite exists, replace the `test` target's failure stub with
the actual runner and add it to `run_all`.

## Conventions

- **Branching:** work on a branch; `main` is protected by review.
- **Commits:** imperative subject line, present tense.
- **Decision records:** any non-obvious or hard-to-reverse decision gets an
  AGDR in `docs/agdr/`, copied from `AGDR-0000-template.md`. Cheap to write,
  expensive to reconstruct later.
- **Docs live with the code.** If a change makes a document wrong, fix the
  document in the same change.
- **Shell:** POSIX `sh` where practical; every script starts with `set -eu`.

## Guardrails & Safety

- **Never modify or relicense `LICENSE`.** BotOS is MIT, copyright Max Goh.
  Any licensing change requires the owner's explicit approval.
- **Requires human approval:** adding a runtime dependency or a new language
  toolchain; changing the public API once one exists; anything touching
  credentials, billing, or deployment; force-pushing or rewriting history.
- **Never commit secrets.** Real values go in a local `.env`, which is
  gitignored. Only variable *names* and placeholder values belong in
  `.env.example`. If you find a committed secret, stop and report it — rotate
  first, then scrub.
- **No demo, mock, or stub data on a production path.** A stub used to make a
  test pass must be visibly named as one and confined to test code.
- **Do not claim work is verified without running `make verify`** and reading
  its output. Report failures with the output attached.
- **Foundation-only scope:** this scaffold deliberately contains no product
  implementation. Do not add speculative application code to "complete" it.

## Secrets & Env Config

See `.env.example` for the documented contract. No environment variables are
consumed by code yet; the file exists so the first one has an obvious home.
