## Why

BotOS has approved product, visual and technical designs, but no application
runtime. A single release specification is needed to turn those decisions into
working increments without hiding the unresolved credential, desktop privacy
and installation mechanisms behind a green dashboard.

## What Changes

- Build a persistent Go/PostgreSQL core and React/TypeScript/Vite dashboard.
- Provision dedicated agent workstations in a managed Linux VM/Kubernetes cluster.
- Integrate Claude/Codex subscriptions and named OpenAI/Anthropic BYOK connections.
- Add independently enforced takeover, live supervision and durable recovery.
- Add approved procedures, scheduling, memory, collaboration and result evidence.
- Deliver managed installation, encrypted backups, restore and controlled updates.
- Provide contributor-owned checks and explicit full-release acceptance evidence.

## Capabilities

### New Capabilities
- `local-core`: Persistent agent configuration.
- `agent-model-access`: Stable worker identity.
- `workstation-lifecycle`: Managed persistent Linux workstations.
- `private-desktop-control`: Restricted execution and managed applications.
- `live-supervision`: Agent-first navigation.
- `durable-execution`: Durable acceptance and queue.
- `procedures-teaching`: Conversation-led procedures.
- `scheduling-collaboration`: Normal scheduling and expiry.
- `memory-evidence`: Private inspectable memory.
- `backup-restore`: Encrypted recoverable backups.
- `install-update-release`: Managed installation and supported hosts.

### Modified Capabilities

None. BotOS has no archived application capability specs yet.

## Impact

Targets MaxGoh/BotOS only. Planned application paths are `cmd/botos`, `internal`,
`migrations`, `web`, `workstation` and `packaging`. Dependencies include Go,
PostgreSQL and the web build toolchain; Lima/K3s and display components remain
validation candidates. No Mission Control service or policy is imported.

This change adds specifications only. Runtime dependency adoption, migrations,
public interfaces and installers land with their implementing tasks. Preserve
the existing MIT license and immutable approved visual artifacts.

## Scope and exclusions

The full release is single-user and locally accessed, with Linux guest desktops
on validated macOS/Linux hosts. Multiple hosts, bring-your-own clusters, remote
operator access, native/mobile clients, local inference, non-Linux guests, voice
and CAPTCHA circumvention are later scope. Broad Linux portability is a goal,
not an untested promise to support every distro.

## Acceptance

The first vertical slice may ship for review before all integration gates pass;
it must show truthful unavailable states. The full release requires all tasks
and G1–G5 acceptance evidence, including each selected model-access mode. A
failed candidate requires an explicit decision rather than silent scope reduction.
