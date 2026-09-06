# BotOS OpenSpec

The [full-release change](changes/implement-full-release/proposal.md) defines
release requirements, architecture and sequenced implementation tasks. It is a
proposal derived from the approved product/technical designs, not a claim that
the application is built. Capability deltas remain under the change until it
is implemented and archived.

Use OpenSpec 1.12.0 for reproducible validation. It is documentation tooling,
not a BotOS production dependency. With Node.js 22 and npm available:

```bash
npx --yes @fission-ai/openspec@1.12.0 validate implement-full-release --strict
npx --yes @fission-ai/openspec@1.12.0 show implement-full-release
```

Run commands from the repository root. Read the change's tasks in dependency
order; mark a task complete only when its implementation and verification are
finished. Keep unsupported candidates and incomplete release gates visible.
