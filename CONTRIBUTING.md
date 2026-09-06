# Contributing to BotOS

Humans and agents follow the same rules. This is the short version;
[`AGENTS.md`](AGENTS.md) is the detailed contract and takes precedence, and
[`docs/conventions.md`](docs/conventions.md) has the fuller conventions.
Start a session with [`docs/BUILD.md`](docs/BUILD.md).

## Getting set up

```bash
make bootstrap   # checks your toolchain; installs nothing (there is nothing to install yet)
make verify      # the gate
```

## Making a change

1. Branch off `main`.
2. Make the change. Update any document the change makes wrong, in the same commit.
3. If the decision was non-obvious or hard to reverse, add an AGDR — see
   [`docs/agdr/README.md`](docs/agdr/README.md).
4. Run `make verify` and read the output.
5. Open a PR. Fill in the template; explain the *why*, not just the *what*.

## What gets a change rejected

- `make verify` fails.
- A secret, or a real value in `.env.example`.
- A change to `LICENSE` without the owner's explicit approval.
- Demo, mock, or stub data on a production path.
- A new runtime dependency without an AGDR justifying it.
- "It works" with no evidence that the gate was run.

## Style

- POSIX `sh` for scripts; `set -eu` at the top of every one.
- Imperative commit subjects: "add the verify loop", not "added" or "adds".
- Prefer clarity over cleverness. The next reader may be a machine.

## Reporting a vulnerability

Do not open a public issue — see [`SECURITY.md`](SECURITY.md).
