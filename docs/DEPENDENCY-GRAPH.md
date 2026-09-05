# Codebase Orientation

Where things live and what depends on what. Update this file in the same change
that adds or moves a top-level directory — an orientation doc that lags the tree
is worse than none.

## Directory map

| Path | Purpose |
|------|---------|
| `docs/` | Project documentation |
| `docs/agdr/` | Agent Decision Records (append-only; see `docs/agdr/README.md`) |
| `scripts/` | `bootstrap.sh` (toolchain check) and `verify.sh` (the gate) |
| `.github/` | CI workflow, PR template, issue templates |

## Module dependency edges

None yet — there is no application code in this repository.

The scaffold's only internal edge is:

```
Makefile  ->  scripts/bootstrap.sh
          ->  scripts/verify.sh
.github/workflows/ci.yml  ->  make verify  ->  scripts/verify.sh
```

CI deliberately shells out to the same `make verify` a developer runs, so the
two cannot drift apart.

## TODO — dependency edges

When the first application modules land, replace the section above with the
real graph: one edge per line, source module to the modules it imports. Call
out any cycle explicitly rather than letting it hide in the list.
