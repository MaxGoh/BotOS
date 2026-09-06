## Context

The foundation and approved visual prototype exist; no runtime exists. This
change translates the [technical architecture](../../../docs/design/technical-design.md)
and [product design](../../../docs/design/product-design.md) into release work.
The [earlier roadmap](../../../docs/plans/implementation-roadmap.md) supplies
background; this change's task graph refines sequencing so core development can
start alongside feasibility research rather than waiting for every gate.

## Goals / Non-Goals

Build a general-purpose local digital-worker platform with persistent state,
credible supervision and recoverable operations. Deliver an independently usable
agent-management slice first. Do not narrow the platform to the sample grocery
workflow or confuse prototype playback with a live workstation.

The proposal lists release exclusions. The application is not a microservice
fleet. Python is integration-specific, Rust is not selected for the initial core,
and Swift/Kotlin clients are future work.

## Decisions

### Core and persistent first slice

One Go host process serves API requests and built Vite assets. PostgreSQL owns
durable product records. Production PostgreSQL runs in the managed VM/cluster as
a separate system workload; initial development/integration tests may connect to
a contributor-owned PostgreSQL instance. This is a development fixture, not a
change to deployment placement. No production SQLite or in-memory fallback.

Start with agent creation/editing, connection references and honest unavailable
workstation state. The first slice needs neither inference nor desktop access.
Go should expose local diagnostics when PostgreSQL is down, but must not pretend
a failed write was accepted. No Node server is required by the release binary.

### Proposed code ownership

| Path | Responsibility |
| --- | --- |
| `cmd/botos/main.go` | Process composition, shutdown and configuration |
| `internal/agents/` | Worker records and configuration revision handling |
| `internal/store/`, `migrations/` | PostgreSQL queries, transactions and schema upgrades |
| `internal/control/` | Operator/agent APIs and control grants |
| `internal/providers/` | Named provider adapters and host-side secret custody |
| `internal/workstations/` | VM/cluster lifecycle and resource admission |
| `internal/runs/` | Durable work, events, scheduling and recovery |
| `internal/knowledge/` | Procedures, memory, source exclusions and retrieval |
| `internal/maintenance/` | Backups, restore and updates |
| `web/` | Agent-first React interface using the Go API |
| `workstation/` | Managed desktop/engine/broker packaging and app catalog |
| `packaging/` | Host installer and post-login service integration |
| `tests/integration/`, `tests/e2e/` | Real dependency and assembled-product verification |

Create each directory with its first behavior, not as empty scaffolding.

### Records and transaction boundaries

Use opaque stable identities for agents, model connections, workstations,
procedures, versions, runs and handoffs. Keep agent configuration revisions,
run states, workstation health and control generations distinct. Large artifacts
live in managed storage with database references and integrity metadata.

A run acceptance transaction commits the request identifier, owner, configuration
snapshot, optional approved procedure version and initial event together. Enforce
uniqueness of the request identifier within its declared API scope. Job claims
must serialize admission for each agent; a database claim does not substitute for
revoking an old executor's action authority. External effects are never made
atomic by a PostgreSQL transaction.

Define concrete schemas, migration library and database driver in the first core
implementation task. Keep API contracts versioned and test duplicate requests,
conflicting revisions, outage responses and event resynchronization. Avoid adding
a message broker or vector database without a demonstrated requirement.

### Local API and observation contracts

Proposed first-slice routes are `GET /healthz`, `GET /v1/agents`,
`POST /v1/agents`, `GET /v1/agents/{id}` and `PATCH /v1/agents/{id}`.
Health must distinguish process liveness from database readiness; edits include
an expected configuration revision and reject conflicts. IDs and revisions must
be returned by the server. Later run commands carry a stable request ID; control
commands also carry the expected control generation.

Use a resumable event feed with a cursor and an explicit resync response when a
cursor cannot be replayed. Desktop media is a separate transport. Do not return
provider secrets through agent, operator, event or settings-export payloads.
Loopback trust does not remove protection against unrelated browser origins or
workstation requests to management endpoints.

### Workstation and authority layout

Lima and single-node K3s are candidates for a shared managed Linux VM. One owner
agent gets one persistent workstation with configurable limits. The desktop,
restricted engine/scripts and trusted broker have separate enforced authority.
No unrestricted agent root, direct display sockets or helper desktop/shell access.
Application accounts belong to the agent; model credentials remain outside all
workstations, including temporary upstream access tokens.

Wayland and noVNC require a compatible compositor, capture/input server and
transport. The G2 report must identify actual UIDs, mounts, sockets, application
policies and revocation behavior. Environment scrubbing, same-UID file modes,
cooperative pause and blanked thumbnails are not privacy controls by themselves.
Default internet/host-network reachability must coexist with protected management
authority, not be silently replaced with a no-network engine.

### Execution and private takeover

One active run per agent; other work queues. On recovery, reconcile recorded
progress and external state before retrying. Outcome evidence is required for
completion; process exit and cancellation request are separate observations.

Takeover proceeds through preparing, revocation confirmation, private operator
control and explicit handback. Close agent observation/input channels, suspend
agent-controlled activity and clear private-frame exposure before confirmation.
Failure or disconnect stays paused. Teaching explicitly permits selected
observation but not agent input. Handback reconciles current permitted state.

Agent-installed instrumentation must be included in adversarial tests. A forced
reload that loses the operator's in-progress application state is not an approved
substitute for same-desktop takeover. Kernel/VM escape containment is not claimed.

### Knowledge, scheduling and maintenance

Approved procedure versions are immutable; activation does not grant permissions.
Memory and retained history are separate. Source exclusions apply before context
assembly, including caches/indexes; describe limits of information already sent
to a model. Handoffs contain explicit context and never transfer workstation control.

Normal scheduled ticks each queue; downtime catch-up only considers the latest
missed tick within expiry. Previously queued work remains. Execution limits,
expiry and capacity admission apply to schedules and heartbeats too.

Backups coordinate database/workstation consistency, retain all successful copies
until deletion, and exclude model secrets. Use maintained encryption and secure
host key storage with an exported recovery key. Restore holds work for review and
provider reconnection. Approved updates require a verified recovery backup and
compatible component/schema versions; failure remains paused.

## Delivery and parallel work

| Workstream | Starts after | Can run alongside | Exit |
| --- | --- | --- | --- |
| A: Core vertical slice | This specification | B: feasibility | Agent edit survives restart; real PostgreSQL and browser tests |
| B: G1/G2/G3 experiments | This specification | A; independent gate investigations | Accepted supported routes and runtime composition |
| C: Workstation/providers | Relevant B evidence and A contracts | Independent UI integration against accepted API | Real agent task and enforced takeover |
| D: Durable supervision | C | Event UI against accepted contracts | G4 fencing, crashes and uncertain-effect matrix |
| E: Reusable work | D | Procedure and memory work with explicit interfaces | Scheduling, forgetting and collaboration acceptance |
| F: Recovery/install | Host contract and D; finalize after E | Backup tooling and packaging where independent | G5 fresh restore and safe update |
| G: Release acceptance | A–F | Independent host/provider matrix rows | Full release evidence, not just foundation CI |

A completed partial slice is reviewable software, not a full-release declaration.
Do not create mock production integrations to make dependent surfaces appear done.

## Risks / Trade-offs

- **Subscription credential boundary:** known external-token candidates do not
  meet it. Validate an eligible route; escalate a demonstrated incompatibility.
- **Private takeover:** desktop-level revocation cannot undo previously injected
  browser code; restrict and test persistent instrumentation routes.
- **Host portability:** advertise only measured host/architecture combinations.
  Resource limits and PVC sizes alone do not prove isolation or quota enforcement.
- **Local trust:** protect management authority despite no separate operator login.
- **Indefinite retention:** capacity failures must be visible; no automatic pruning.
- **Uncertain effects:** recovery may need the human. Do not promise exactly-once
  execution across unrelated external applications.

## Migration Plan

The current repository has no application schema to migrate. Introduce versioned
migrations with the first real persistence task and test forward upgrade and
failure recovery from each supported prior schema. Preserve the approved design
snapshot, MIT license, canonical AGENTS.md symlink and existing verification gate.

When implemented and accepted, archive this change through OpenSpec so capability
requirements become baseline specifications. Do not archive an incomplete release
or mark task completion based on documentation validation.

## Open Questions and Decision Gates

These are concrete outputs required before affected work, not blockers for A:
G1 selects eligible auth routes and versions; G2 selects isolation/display/broker
composition; G3 selects host matrix, resource formula, storage/network mechanisms;
G4 fixes measured transport targets and replay contracts; G5 selects secure-store,
crypto, consistent capture and migration recovery mechanisms. Folder read-only and
collaborator-mode defaults remain proposed until confirmed in implementation
review; do not mislabel them as previously approved decisions.

## Validation Strategy

Every requirement has a WHEN/THEN scenario in `specs/`. Task groups below identify
its owner and evidence. Run the existing `make verify` gate and extend it with
real component tests as they land. OpenSpec syntax validation checks document
structure only. Core/database, provider, desktop, installer and restore tests
must produce their own evidence. Publish exact versions, commands, observed
results and limitations; unavailable tests remain unpassed.
