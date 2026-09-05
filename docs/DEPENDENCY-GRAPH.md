# Codebase Orientation

Where things live and what depends on what. Update this file in the same change
that adds or moves a top-level directory — an orientation doc that lags the tree
is worse than none.

## Directory map

| Path | Purpose |
|------|---------|
| `docs/` | Project documentation |
| `docs/agdr/` | Agent Decision Records (append-only; see `docs/agdr/README.md`) |
| `scripts/` | `bootstrap.sh` (toolchain check), `verify.sh` (the gate), `test.sh` (suite runner) |
| `tests/` | `lib.sh` (assertions + fixtures) and one `test_*.sh` per area under test |
| `.claude/skills/` | Repo skills: `verifying-changes`, `extending-the-verify-loop` |
| `.github/` | CI workflow, PR template, issue templates |

## Module dependency edges

None yet — there is no application code in this repository.

The scaffold's own edges are:

```
Makefile  ->  scripts/bootstrap.sh
          ->  scripts/verify.sh
          ->  scripts/test.sh

scripts/verify.sh  ->  scripts/test.sh          (check_tests)
scripts/test.sh    ->  tests/test_*.sh
tests/test_*.sh    ->  tests/lib.sh             (sourced)
                   ->  scripts/verify.sh        (run against a fixture)

.github/workflows/ci.yml  ->  make verify  ->  scripts/verify.sh
```

CI deliberately shells out to the same `make verify` a developer runs, so the
two cannot drift apart.

**The one cycle, and why it is safe.** `scripts/verify.sh` runs the suite and
the suite runs `scripts/verify.sh`. It terminates because `scripts/test.sh`
exports `BOTOS_SKIP_TESTS=1`, which makes the nested gate runs skip
`check_tests`. Recursion depth is therefore exactly one. Removing that export
turns the gate into an infinite loop.

## TODO — application module edges

Still unfilled: there is no application code, and no approved product design
has reached this repository, so there are no module edges to draw. This is not
an oversight to be tidied away — see "What This Is" in `../AGENTS.md`.

When the first application modules land, add the real graph here: one edge per
line, source module to the modules it imports. Call out any cycle explicitly,
the way the scaffold's own cycle is called out above, rather than letting it
hide in the list.
