# BotOS — Agent Instructions

This file is the contract for any automated agent (and any human) working in
this repository. Read it before your first edit, then read
[`docs/BUILD.md`](docs/BUILD.md) for the current state and the next work.

This file is the canonical agent-instructions source. `CLAUDE.md` is a
relative symlink to `AGENTS.md`, so Claude, Codex, and Gemini harnesses all
resolve to one document. Edit this file; never create a separate Claude copy.

## Product

BotOS is a self-hosted, single-user platform for persistent digital workers.
Each agent has its own identity, instructions, memory, application
credentials, and dedicated Linux workstation. Users teach through conversation
and supervised work, then approve reusable procedure versions. Read
[`docs/design/product-design.md`](docs/design/product-design.md) for the
approved requirements.

BotOS is owned by Max Goh and licensed MIT. It is a separate product from
Mission Control; borrow Mission Control's documentation practices, not its
services, deployment assumptions, or product-specific policy defaults.

**State of the repository.** It contains the approved product design, an
illustrative prototype, and this foundation. No application runtime,
installer, database schema, host manager, or live workstation integration
exists yet. Do not describe the prototype as production software or as a live
workstation integration, and do not add speculative application code to
"complete" the foundation. The approved [technical architecture](docs/design/technical-design.md) and
[implementation plan](docs/plans/implementation-roadmap.md) now guide feasibility
work; candidate mechanisms are not yet proven.

## Architecture

There is no application code yet, so there is no runtime dependency graph to
draw. [`docs/DEPENDENCY-GRAPH.md`](docs/DEPENDENCY-GRAPH.md) holds the
directory map and the foundation's edges, and is the file to update as soon as
the first module lands. Architecture proposals belong in design documents
until they are implemented; label proposals as proposals.

## Session workflow

1. Read `docs/BUILD.md` and the approved design relevant to the task.
2. Inspect the working tree and any narrower `AGENTS.md` instructions before
   editing.
3. Make the smallest complete change within the user's authorized scope.
   Preserve unrelated work.
4. Keep task statuses current as each step finishes. Distinguish completed
   work, proposed work, and blocked work.
5. Run the checks documented for the change — `make verify` at minimum. Report
   observed results and any limitations; a process exiting successfully does
   not prove the requested outcome.
6. Follow the active session's publishing contract. When a harness owns
   commits, pushes, and PRs, leave publication to that harness.

## Key Commands

Every command below is implemented in pure POSIX shell plus `make`. The repo
has **zero runtime and zero build dependencies** today, and the verify loop is
designed to keep working as real dependencies arrive.

```bash
make help       # list every target
make bootstrap  # check the local toolchain; install nothing yet
make verify     # the full gate — run this before you hand work back
make check      # alias for verify
make test       # the test suite on its own (verify runs it too)
```

`make verify` is the single gate. CI runs exactly that target, so a green
`make verify` locally means a green CI run — keep it that way. These checks
cover the foundation itself — the docs, the scripts, and the gate; there is no
application build or application test command yet. Do not run Mission Control
commands here or claim they validate BotOS.

## Tests

`scripts/test.sh` runs every `tests/test_*.sh`, and `make verify` runs
`scripts/test.sh`. There is one gate, not two.

The suite tests the scaffold itself, because the scaffold is the only code
here: it builds a scratch git repo from the current working tree, breaks
exactly one thing in it, and asserts that `scripts/verify.sh` reports it.
Every check in the gate has a case that fails when the check is removed from
`run_all` — that property was mutation-tested, and it is the property to
preserve when you add a check.

### Growing the verify loop

When you add a language toolchain, extend `scripts/verify.sh` rather than
adding a parallel command. Each check is a `check_*` shell function registered
in `run_all`; add yours there so it runs locally and in CI from one definition.
Then add a case to `tests/test_verify.sh` and confirm it fails with your check
commented out of `run_all` — a check nobody has seen fail is a check nobody
knows works. Add real checks alongside the first implementation; never create
placeholder build or test targets that report success without doing work.

The suite runs the gate, and the gate runs the suite. `scripts/test.sh`
exports `BOTOS_SKIP_TESTS=1` so the nested gate runs inside fixtures skip
`check_tests` instead of recursing. Leave that guard alone.

The `.claude/skills/` directory carries the two workflows above in loadable
form: `verifying-changes` (run the gate, read the failures) and
`extending-the-verify-loop` (add a check, a test, or a toolchain). A skill
needs `name` and `description` frontmatter and its `name` must match its
directory, which `make verify` enforces.

## Decision records

For each logical code, configuration, architecture, or substantive design
change, add one new record under [`docs/agdr/`](docs/agdr/README.md) using
[`docs/agdr/AGDR-0000-template.md`](docs/agdr/AGDR-0000-template.md).

Name records `AGDR-YYYY-MM-DD-NNN-short-title.md`, incrementing the
three-digit sequence for that day. Records are **append-only**: correct or
supersede an earlier decision in a new record, never by rewriting the earlier
one. Record the decision, reason, scope, verification, and consequences.
Small typo-only documentation corrections do not need a decision record.

## Conventions

- **Branching:** work on a branch; `main` is protected by review.
- **Commits:** imperative subject line, present tense.
- **Docs live with the code.** If a change makes a document wrong, fix the
  document in the same change.
- **Shell:** POSIX `sh` where practical; every script starts with `set -eu`.
- Fuller detail lives in [`docs/conventions.md`](docs/conventions.md).

## Dependencies and build contract

When services, packages, runtime dependencies, or web routes change, update
`docs/DEPENDENCY-GRAPH.md` in the same change. Keep its diagram and affected
tables consistent with implemented software.

When setup, build, test, migration, or installation behavior changes, update
`docs/BUILD.md` and `docs/conventions.md`. Document exact commands,
prerequisites, and expected results.

## Guardrails & Safety

- **Never modify or relicense `LICENSE`.** BotOS is MIT, copyright Max Goh.
  Any licensing change requires the owner's explicit approval.
- **Requires human approval:** adding a runtime dependency or a new language
  toolchain; choosing the application stack; changing the public API once one
  exists; anything touching credentials, billing, or deployment;
  force-pushing or rewriting history.
- **Never commit secrets.** Real values go in a local `.env`, which is
  gitignored. Only variable *names* and placeholder values belong in
  `.env.example`. Keep secrets out of source control, prompts, logs,
  screenshots, fixtures, and prototype data. If you find a committed secret,
  stop and report it — rotate first, then scrub.
- **No demo, mock, or stub data on a production path.** Tests and dev-only
  design artifacts may use fixtures; a stub used to make a test pass must be
  visibly named as one and confined to test code.
- **Do not claim work is verified without running `make verify`** and reading
  its output. Report failures with the output attached.
- **Foundation-only scope:** this repository deliberately contains no product
  implementation. Do not add speculative application code to "complete" it.
- **No vacuous tests.** A test that passes with the thing it tests removed is
  worse than no test. Prove a new case fails before you keep it.

## Security and access

These are product requirements from the approved design. They constrain the
implementation when it starts; none of them is implemented today.

- Enforce action permissions outside model instructions. Procedure approval
  activates instructions; it does not grant action authority.
- Isolate agents' application accounts, saved context, and workstations.
  Reusing a model connection does not share those resources.
- Helpers receive explicit handoff context and use their own permissions. They
  do not gain desktop or SSH access to another agent's workstation.
- Human takeover pauses agent actions. Private takeover also stops agent
  observation and capture, including workstation overview thumbnails. Teaching
  observation requires explicit opt-in; handback is explicit.
- If the allowed and forbidden actions cannot be separated by enforceable
  controls, stop automation before that boundary and request human takeover.
- Reconcile uncertain external side effects before retrying. Record failure
  separately from whether a child process has actually exited.
- Do not weaken sandboxing or grant privileges to work around a failure
  without an explicit, reviewed security decision.

## Implementation and documentation

Prefer standard tools and existing code before adding dependencies or
abstractions.

The approved prototype under `docs/design/approved/` is a design reference.
Preserve approved snapshots and their provenance; create a new version for
future approved changes rather than overwriting an existing one. Do not copy
its illustrative state into production features.

Write human-facing documentation in plain language. State problems, decisions,
and evidence directly. Use the skills and tools available in the active
environment; do not assume Mission Control-only plugins or services are
installed for every contributor.

## Secrets & Env Config

See `.env.example` for the documented contract. No environment variables are
consumed by code yet; the file exists so the first one has an obvious home.

## Directory map

- [`docs/BUILD.md`](docs/BUILD.md): current state and next work
- [`docs/conventions.md`](docs/conventions.md): repository and development
  conventions
- [`docs/DEPENDENCY-GRAPH.md`](docs/DEPENDENCY-GRAPH.md): directory map and
  implemented dependencies
- [`docs/agdr/`](docs/agdr/README.md): append-only decision records
- [`docs/design/product-design.md`](docs/design/product-design.md): approved
  product requirements
- [`docs/design/approved/`](docs/design/approved/README.md): approved
  prototype, screenshots, and verification evidence
- `scripts/`: `bootstrap.sh` (toolchain check), `verify.sh` (the gate), and
  `test.sh` (the suite runner the gate calls)
- `tests/`: the shell test suite that exercises the gate against scratch
  fixtures
- `.claude/skills/`: loadable agent workflows for running and extending the
  gate
- `.github/`: CI workflow, PR template, issue templates

Add application directories after the implementation architecture is decided.
