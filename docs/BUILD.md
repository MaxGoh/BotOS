# BotOS build entry point

Read this file at the start of a session, then read `../AGENTS.md` and the
approved design relevant to the work.

## Current state

- The repository foundation is **applied**: canonical `../AGENTS.md`, a
  relative `CLAUDE.md` symlink to it, repository conventions, append-only
  decision records, the `make verify` gate, the shell test suite behind it,
  the repo skills under `../.claude/skills/`, and CI.
- The product design and visual prototype are approved and recorded here, in
  `design/`.
- No application runtime, installer, database schema, host manager, or live
  workstation integration has been implemented.
- The [technical architecture](design/technical-design.md) and
  [phased implementation plan](plans/implementation-roadmap.md) are approved.
  The Go core, PostgreSQL and React/TypeScript/Vite stack is selected;
  infrastructure and integration candidates still require feasibility evidence.
  Execute the [feasibility plan](plans/feasibility.md) before dependent runtime work.

## Full-release implementation

Use the [OpenSpec proposal](../openspec/changes/implement-full-release/proposal.md),
[design](../openspec/changes/implement-full-release/design.md) and
[task checklist](../openspec/changes/implement-full-release/tasks.md). Start group A
(core/persistent dashboard) while group B validates provider and workstation
mechanisms. Feasibility gates block their dependent integrations, not unrelated
core development. All application tasks remain unchecked.

## Orientation

Read [the product design](design/product-design.md), [the prototype
record](design/approved/README.md), and [repository
conventions](conventions.md). Keep approved product decisions separate from
proposed engineering choices.

The first planning phase must establish workstation isolation, model adapters,
action-permission enforcement, private takeover, durable run recovery, local
macOS/Linux installation, and a testable first vertical slice. The approved
design is general-purpose; example workflows do not narrow the product to
grocery ordering or a single business domain.

## Available checks

```bash
make bootstrap   # check the local toolchain; installs nothing
make verify      # the gate — CI runs exactly this target
make test        # the test suite on its own, while iterating
```

`make verify` runs `../scripts/verify.sh`, which checks the foundation itself:
required files, the `CLAUDE.md` symlink target, license integrity, the
approved prototype's SHA-256 against
[`design/approved/manifest.json`](design/approved/manifest.json), decision
record naming, shell syntax, committed secrets, `.env.example` placeholders,
relative Markdown links, trailing whitespace, skill frontmatter, and last the
test suite.

The suite is `../scripts/test.sh`, which the gate calls, so `make verify` stays
the single command. It tests the foundation, because the foundation is the only
code here: each case builds a scratch git repo from the working tree, breaks
exactly one thing, and asserts the gate reports it.

There is still **no application build or run command** at this stage. Do not
run Mission Control commands here or claim they validate BotOS.

The approved prototype is a self-contained HTML design artifact and can be
opened directly in a browser. It is immutable under the gate: changing its
bytes fails `make verify`. A future approved revision is added as a new
version with its own manifest, never by overwriting this one.

When implementation begins, add exact setup, build, test, and local-run
commands here with their prerequisites and expected results. Extend
`../scripts/verify.sh` and register the new check in `run_all()` rather than
adding a parallel command. Include installation and recovery verification
alongside runtime work.

### Verification recorded for the foundation

Run on 2026-09-06, after the test suite and skills were merged with the
approved design: `make verify` passed **12 checks, 0 failures**, which includes
`make test` at **3 test files, 46 cases, 0 failures**. The run was repeated
with `shellcheck` v0.10.0 on `PATH`, the way CI runs on `ubuntu-latest`, and
was green there too, with the lint case exercised rather than noted. Each of
the twelve checks was mutation-tested — removed from `run_all()` in a scratch
copy in turn — and the suite failed every time.

Recorded earlier on 2026-09-06, when the foundation and approved design were
applied:
`make verify` passed 10 checks with 0 failures, the prototype hash matched its
manifest, its inline JavaScript passed `node --check`, and `LICENSE` was
confirmed unmodified. Each new check was negative-tested. Full evidence is in
[`agdr/AGDR-2026-09-06-001-apply-approved-design.md`](agdr/AGDR-2026-09-06-001-apply-approved-design.md).

This is separate from the historical prototype evidence in
[`design/approved/verification.json`](design/approved/verification.json) — 12
parent browser checks and JavaScript syntax validation from the original
approved-design session. Those browser checks were **not** re-run here, and
they cover the design prototype, not a BotOS runtime.

## Publication

Follow the active operator and harness instructions. Preserve the working tree
for harness publication where applicable. The repository uses the existing MIT
license in `../LICENSE`.

## Contributor feasibility checks

Run `make bootstrap` and `make verify` from a clone with Git, POSIX shell and
make. CI runs the same gate on Ubuntu 24.04 and macOS 14. No model account,
provider secret, container runtime or access to the maintainer’s machine is
required for these checks. The macOS CI job is configured, not yet observed
in this session.

`make feasibility` runs an actual same-UID reader against a temporary controlled
marker with an empty environment. Successful execution demonstrates why that
approach is insufficient isolation; it does not certify private takeover. The
same probe runs in the regular test suite. Temporary data is removed on exit.

`make feasibility-host` inventories Lima, kubectl and host virtualization
prerequisites without installing or starting anything. It deliberately returns
status 2 because inventory alone cannot pass G1/G2/G3. Missing prerequisites
are printed individually. See [the contributor guide](validation/CONTRIBUTING.md)
for the separate integration evidence requirements.
