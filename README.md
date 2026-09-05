# BotOS

<!-- mc-readiness-badge:start -->
[![MC readiness: Not ready](https://img.shields.io/badge/MC%20readiness-Not%20ready-red)](docs/mc-readiness-report.md)
_Last evaluated: [2026-09-05](docs/mc-readiness-report.md)._
<!-- mc-readiness-badge:end -->

> **Status: foundation.** This repository currently contains its agent-ready
> scaffold — instructions, decision log, verify loop, test suite, skills, and
> CI — and no application code. The product definition has not been recorded
> here yet.

## Quick start

```bash
make bootstrap   # check your local toolchain
make verify      # run the full gate: static checks, then the test suite
make test        # the test suite on its own, while iterating
```

`make verify` is the only gate you need to satisfy. CI runs the same target,
so green locally means green in CI. Run `make help` for the full list.

## Repository layout

| Path | What lives there |
|------|------------------|
| `AGENTS.md` | Agent + contributor contract: commands, conventions, guardrails |
| `CLAUDE.md` | Pointer to `AGENTS.md` |
| `docs/agdr/` | Agent Decision Records — why things are the way they are |
| `docs/DEPENDENCY-GRAPH.md` | Directory map and module dependency edges |
| `scripts/` | `bootstrap.sh`, `verify.sh`, `test.sh` — all pure POSIX shell |
| `tests/` | The test suite: `lib.sh` plus one `test_*.sh` per area |
| `.claude/skills/` | Repo skills for the run/verify workflows |
| `.github/workflows/ci.yml` | CI, which runs `make verify` |

## Dependencies

None. The scaffold is `make` plus POSIX shell, both of which ship with the
standard developer toolchain — the test suite is written in the same two
things. No package manager is required to run `make verify` today, and no
runtime dependency has been introduced.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Contributors and agents share the
same rules; [`AGENTS.md`](AGENTS.md) is the detailed version.

## Security

Please report vulnerabilities privately — see [`SECURITY.md`](SECURITY.md).

## License

[MIT](LICENSE) © 2026 Max Goh.
