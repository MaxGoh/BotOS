# BotOS build entry point

Read this file at the start of a session, then read `../AGENTS.md` and the
approved design relevant to the work.

## Current state

- The repository foundation is **applied**: canonical `../AGENTS.md`, a
  relative `CLAUDE.md` symlink to it, repository conventions, append-only
  decision records, the `make verify` gate, and CI.
- The product design and visual prototype are approved and recorded here, in
  `design/`.
- No application runtime, installer, database schema, host manager, or live
  workstation integration has been implemented.
- A phased implementation plan has been requested and remains the next
  deliverable. The application stack and repository file map are not decided
  yet.

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
```

`make verify` runs `../scripts/verify.sh`, which checks the documentation
foundation only: required files, the `CLAUDE.md` symlink target, license
integrity, the approved prototype's SHA-256 against
[`design/approved/manifest.json`](design/approved/manifest.json), decision
record naming, shell syntax, committed secrets, `.env.example` placeholders,
relative Markdown links, and trailing whitespace.

There is **no application build or test command** at this stage; `make test`
exits non-zero rather than reporting a hollow success. Do not run Mission
Control commands here or claim they validate BotOS.

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

Run on 2026-09-06 when the foundation and approved design were applied:
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
