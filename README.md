# BotOS

<!-- mc-readiness-badge:start -->
[![MC readiness: Not ready](https://img.shields.io/badge/MC%20readiness-Not%20ready-red)](docs/mc-readiness-report.md)
_Last evaluated: [2026-09-05](docs/mc-readiness-report.md)._
<!-- mc-readiness-badge:end -->

BotOS is a self-hosted platform for persistent AI workers. You guide an agent
through work, review the procedure it learns, and decide what it may do on
future runs.

Each agent has its own instructions, memory, application accounts, and
dedicated workstation. You can follow its work through conversation, view its
screen, or take control. An overview shows all workers and their latest
status.

## Project status

> **Status: foundation.** The product design and visual prototype are
> approved and recorded here. This repository has no application runtime or
> installer yet. Implementation planning is the next deliverable.

- [Start here](docs/BUILD.md)
- [Approved product design](docs/design/product-design.md)
- [Approved prototype](docs/design/approved/prototype.html), which can be
  opened in a browser
- [Conversation and workstation view](docs/design/approved/conversation.png)
- [All-workstations view](docs/design/approved/workstations.png)
- [Agent instructions](AGENTS.md)
- [Repository conventions](docs/conventions.md)
- [Decision records](docs/agdr/README.md)

The prototype uses illustrative playback. It does not connect to real
desktops, accounts, or payment services.

## Quick start

```bash
make bootstrap   # check your local toolchain
make verify      # run the full gate
```

`make verify` is the only gate you need to satisfy. CI runs the same target,
so green locally means green in CI. Run `make help` for the full list. The
gate checks the documentation foundation; there is no application build or
test command yet, and none is faked.

## Repository layout

| Path | What lives there |
|------|------------------|
| `AGENTS.md` | Agent + contributor contract: commands, conventions, guardrails |
| `CLAUDE.md` | Relative symlink to `AGENTS.md` |
| `docs/BUILD.md` | Current state, orientation, and available checks |
| `docs/conventions.md` | Repository and development conventions |
| `docs/design/` | Approved product design, prototype, and provenance |
| `docs/agdr/` | Agent Decision Records — why things are the way they are |
| `docs/DEPENDENCY-GRAPH.md` | Directory map and dependency edges |
| `scripts/` | `bootstrap.sh` and `verify.sh`, both pure POSIX shell |
| `.github/workflows/ci.yml` | CI, which runs `make verify` |

## Dependencies

None. The foundation is `make` plus POSIX shell, both of which ship with the
standard developer toolchain. No package manager is required to run `make
verify` today, and no runtime dependency has been introduced. The application
stack and build commands will be documented when the first implementation
phase establishes them.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Contributors and agents share the
same rules; [`AGENTS.md`](AGENTS.md) is the detailed version.

## Security

Please report vulnerabilities privately — see [`SECURITY.md`](SECURITY.md).

## License

[MIT](LICENSE) © 2026 Max Goh.
