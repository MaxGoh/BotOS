---
name: verifying-changes
description: Use before handing back any change in this repository - runs the make verify gate, explains what each failure means, and covers the recursion guard that lets the test suite run the gate against itself.
---

# Verifying a change in BotOS

`make verify` is the only gate. CI runs exactly that target and nothing else,
so a green run locally is a green run in CI. Do not hand work back on the
strength of "it looks right" — run it and read the output.

## The loop

```bash
make bootstrap   # once per box: confirms git and make are present
make verify      # the gate: static checks, then the test suite
```

`make check` is an alias for `verify`. `make test` runs only the suite, which
is useful while iterating; it is not a substitute for the gate.

Expect a run to end with:

```
----------------------------------------
PASS  12 checks, 0 failures
```

A failing run prints `FAIL  <what went wrong>` under the check that caught it
and exits non-zero. Every message names the file.

## Reading the failures

| Message | What to do |
|---------|------------|
| `missing required file: X` | Restore `X`. The foundation files are load-bearing; if one is genuinely obsolete, remove it from `check_required_files` in the same change and say why. |
| `LICENSE is no longer the MIT License` / `copyright line was altered` | Revert it. Relicensing needs the owner's explicit approval — see the guardrails in `AGENTS.md`. |
| `CLAUDE.md is not a symlink` / `expected the relative target AGENTS.md` | Restore it with `ln -sf AGENTS.md CLAUDE.md`. A copy is how the two instruction files silently diverge. |
| `expected AGDR-YYYY-MM-DD-NNN-short-title.md` | Rename the record. A misnamed record does not sort into the log. Increment `NNN` for that day rather than reusing a number. |
| `approved snapshots are immutable` / `no prototypeSha256 recorded` | Do not edit an approved prototype in place. Restore the bytes and add a new approved version instead. |
| `shell syntax error` / `not executable` / `missing shebang` | Fix the script. Every `*.sh` needs `#!/bin/sh`, `set -eu`, and the executable bit (`chmod +x`). |
| `looks like it contains a credential` | Stop. Rotate the credential first, then scrub it — a commit is not needed for it to be leaked. Never silence this by adding an exemption. |
| `.env.example: 'X' has a populated value` | Replace the value with `<placeholder>`. Only names and placeholders belong in that file. |
| `link target does not exist` | Fix the relative link. Docs that point at nothing are worse than missing docs. |
| `trailing whitespace` | Strip it. `sed -i 's/[[:space:]]*$//' <file>` on GNU sed. |
| `frontmatter is missing 'name'` etc. | A skill under `.claude/skills/` needs `name` and `description` frontmatter, and `name` must equal its directory name, or no harness will load it. |
| `test suite failed` | Scroll up: the suite prints the failing case, the assertion, and the captured output indented under `|`. |

## Writing a credential into a test on purpose

`check_secrets` scans every tracked file, including the test suite. Assemble
credential-shaped strings at runtime instead of writing them literally — see
`secret_shape()` in `tests/test_verify.sh`. Adding a file to the scanner's
exemption list to quiet it would blind the check to a real leak.

## The recursion guard

The suite runs `scripts/verify.sh` inside scratch copies of the repo, and the
gate runs the suite. `scripts/test.sh` exports `BOTOS_SKIP_TESTS=1` so those
nested gate runs skip `check_tests` instead of recursing forever. Two
consequences worth knowing:

- A nested run prints `note  nested verify run; suite skipped` — that is
  expected, not a skipped check you need to chase.
- To exercise the wiring itself, tests set `BOTOS_SKIP_TESTS=0` and stub
  `scripts/test.sh` with a fixed exit status. Never unset the guard while
  running the real suite.

## Before you say it passes

- You ran `make verify` in this working tree, after your last edit.
- You read the final line, not just the absence of an error.
- Any document your change made wrong is fixed in the same change.
- A non-obvious or hard-to-reverse decision has an AGDR in `docs/agdr/`.
