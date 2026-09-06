---
name: extending-the-verify-loop
description: Use when adding a check to the BotOS gate, adding a test, or wiring a new toolchain into make verify - keeps one definition of the gate for local and CI, and requires proving a new check actually fires.
---

# Extending the verify loop

The gate lives in one place: `scripts/verify.sh`, run by `make verify`, run by
CI. Adding a parallel command — a second workflow step, a lint script CI calls
directly — is how local and CI drift apart. Extend the one definition instead.

## Add a check

1. Write a `check_<name>` function in `scripts/verify.sh`. Call `start` once
   with a human-readable label, then `fail` once per problem found. Do not
   `exit`: the gate reports every failure in a single run rather than stopping
   at the first.
2. Register it in `run_all()`. That is the only registration; local and CI
   both pick it up.
3. Keep it cheap and specific. A check that fires on things that are fine is a
   check people learn to ignore — `check_secrets` uses deliberately narrow
   patterns for exactly this reason.
4. Use `tracked_files` / `tracked_matching` to enumerate files. They cover
   tracked *and* new untracked files while honouring `.gitignore`, so the gate
   sees work that has not been committed yet.

## Prove it fires

A check that has never failed is a check nobody knows works. Every check in
the gate has a matching case in `tests/test_verify.sh`:

```sh
it "fails on <the thing>"
fx=$(fixture_new)          # scratch git repo holding a copy of this tree
# ... break exactly one thing in $fx ...
run_verify "$fx"
assert_fails "$last_status" "<label>"
assert_contains "$last_output" "<the message your check prints>" "<label>"
```

Add both directions when the check has a legitimate "this is fine" case — see
the placeholder-forms case next to the populated-value case for `.env.example`.

Then confirm the test is not vacuous: comment your check out of `run_all()`,
run `make test`, and watch the new case fail. Put it back. A case that passes
with the check disabled is testing nothing.

## Add a test file

Name it `tests/test_<area>.sh`, make it executable, start it with:

```sh
#!/bin/sh
set -eu
. "$REPO_ROOT/tests/lib.sh"
```

and end it with `finish`. `scripts/test.sh` discovers it by glob — there is no
list to update. Helpers available: `it`, `fixture_new`, `edit_file`, `run_in`,
`run_verify`, `assert_ok`, `assert_fails`, `assert_contains`,
`assert_not_contains`. Assertions record a failure and continue, so one broken
case does not hide the rest.

Run the file directly while iterating:

```bash
REPO_ROOT=$(pwd) BOTOS_SKIP_TESTS=1 sh tests/test_verify.sh
```

Both variables are required — `scripts/test.sh` normally exports them.

## Wiring in a new toolchain

Adding a runtime dependency or a language toolchain **requires human approval
and an AGDR** (`docs/agdr/`). Once approved:

- add the install step to `scripts/bootstrap.sh` so `make bootstrap` stays the
  single command a newcomer runs;
- add a `check_<lang>_*` function to `scripts/verify.sh` and register it in
  `run_all()` — not a new CI step;
- guard it with `command -v` and print a `note` when the tool is absent, the
  way `check_shell_syntax` treats `shellcheck`, so a partial box still gets a
  useful run;
- point the new suite at `scripts/test.sh` rather than teaching `make verify`
  about a second runner.

## Related

- `../verifying-changes/SKILL.md` — running the gate and reading its output.
- `../../../AGENTS.md` — the full contract, including guardrails.
