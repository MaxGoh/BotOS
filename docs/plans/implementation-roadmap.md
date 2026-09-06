# BotOS Phased Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development or superpowers:executing-plans when implementation is authorized. Follow the active harness publication contract. Checkboxes below describe future work, not completed implementation.

**Goal:** Deliver the approved general-purpose digital-worker platform through independently verifiable increments.

**Architecture:** One Go host service owns permissions and durable execution; PostgreSQL runs inside a managed Linux VM and Kubernetes cluster. Each agent has a persistent workstation containing a restricted engine environment, managed desktop applications and a trusted control broker. React presents the local operator dashboard.

**Tech Stack:** Go; PostgreSQL; React, TypeScript and Vite. Lima, K3s, Wayland and noVNC are approved candidates awaiting feasibility evidence. Python is permitted only where an integration requires it.

**Spec:** [Approved technical architecture](../design/technical-design.md), [approved product design](../design/product-design.md), [provider findings](../design/provider-integration-findings.md).

## Status and scope

Planning is complete at the phased delivery level. The immediate feasibility work packages are in [the gate plan](feasibility.md). Production coding plans for later phases must be generated from the accepted gate evidence; this document deliberately does not invent an authentication mechanism or a private-takeover implementation before either has been demonstrated.

Baseline: MaxGoh/BotOS main `89283bd56a6014ec88aed42cf018f5f6c214a26b`, with PRs #1–#3 merged. The repository has documentation, approved prototype artifacts and a shell verification suite. It has no application runtime. `make verify` passed 12 checks, 3 test files, zero failures in this planning session; recorded against that exact baseline. This is not evidence for the future runtime.

All paths below are relative to MaxGoh/BotOS unless explicitly linked as current project artifacts. The original planning task changed no application files. The subsequent feasibility branch imports these documents; no publication is claimed.

## Global constraints

- First release is single-user, local browser access after OS login; no remote dashboard or native client requirement.
- Broad macOS/Linux portability is the goal. Advertise only the host versions and architectures verified by the installer gate.
- One owner agent per workstation and one active run per agent. Different agents run concurrently within a configured host budget.
- Reserve configured RAM; queue when full. Suggest an adjustable setup budget and accept manual values within enforced limits.
- Every provider credential, including access tokens, remains outside workstations. Reusable model connections are assigned explicitly.
- First-release model access targets Claude subscription, Codex subscription, OpenAI BYOK and Anthropic BYOK. Local inference follows later.
- No unrestricted root for agent execution. Managed application installation and independently enforced private takeover are required.
- Do not promise arbitrary in-application action restrictions that the selected execution paths cannot enforce.
- Explicit folder grants per agent; internet and host-reachable networks by default without granting management-plane authority.
- Procedure activation and action permissions are separate. Approved procedure versions do not change within a run.
- Uncertain external outcomes pause for reconciliation. No blind replay, silent provider fallback or automatic authority expansion.
- Keep history and every backup until user deletion. Encrypt backups; retain recovery-key support. Exclude model credentials from backups.
- Updates require approval. Backup and update operations coordinate with active work and human takeover.
- Preserve the approved visual snapshot and MIT license. No fixture-backed production features.
- Extend the existing `make verify` gate as real components land. Each substantive change includes an append-only agDR; update dependency/build documentation with actual implementation.

## Delivery dependencies

| Phase | Deliverable | Prerequisite | Exit evidence |
| --- | --- | --- | --- |
| 0 | Feasibility and concrete runtime contracts | Approved architecture | G1–G3 reports; no unsupported security claim |
| 1 | Go core, PostgreSQL and local dashboard | Accepted host/database contract from G3 | Real persistent API, restart and local access tests |
| 2 | One real agent and workstation | G1, G2, G3 and phase 1 | Real provider execution, persistent desktop, private takeover |
| 3 | Durable runs and supervision | Phase 2 | G4 crash, fencing and reconnect matrix |
| 4 | Reusable work and memory | Phase 3 | Procedure, scheduler, forgetting and collaboration tests |
| 5 | Installation, backup, restore and updates | G3, phases 3–4 | G5 fresh restore and update failure matrix |
| 6 | First-release acceptance | All preceding phases | Four access modes, supported-host matrix and end-to-end evidence |

G1, G2 and G3 can be investigated independently with at most two delegated workers at once. Their integration review is sequential. Independent frontend and core implementation can proceed against an accepted API contract; neither may make decisions that bypass a failed gate.

## Phase 0 — settle the mechanisms that constrain the product

- [ ] Execute G1 provider access, G2 private takeover and G3 managed-host feasibility using the companion plan.
- [ ] Review concrete versions, processes, trust boundaries, routes and failure evidence together.
- [ ] Record accepted mechanisms in `docs/design/runtime-contracts.md` and a new agDR. Record any incompatibility as a decision for the operator, preserving the current requirement until it is explicitly revised.
- [ ] Produce the phase 1 coding plan with exact migration library, Go PostgreSQL driver, host supervisor contract, API schemas and test commands selected from the evidence.

**Gate:** BYOK success does not discharge either subscription requirement. A desktop that looks private while an agent-created recorder still runs does not discharge takeover privacy. A Kubernetes namespace or resource request alone does not establish isolation or a hard disk limit.

## Proposed production file map

Create directories when their first real behavior lands, not as empty scaffolding. Paths are proposed implementation ownership, not existing files or final public interfaces.

| Path | Responsibility | First phase |
| --- | --- | --- |
| `cmd/botos/main.go` | Host process wiring and lifecycle | 1 |
| `internal/agents/` | Agent identity, configuration and connection assignments | 1 |
| `internal/control/` | Operator API, scoped agent API and control authority | 1 |
| `internal/store/`, `migrations/` | Database access, transactions and versioned schemas | 1 |
| `web/` | Vite application; production assets served by Go | 1 |
| `internal/workstations/` | VM/cluster adapter, capacity and workstation reconciliation | 2 |
| `internal/providers/` | Host-side credential custody and named provider integrations | 2 |
| `workstation/` | Pinned managed images, broker packaging and application catalog | 2 |
| `internal/runs/` | Durable runs, checkpoints, events and scheduling | 3 |
| `internal/knowledge/` | Procedures, memory, source exclusions and retrieval | 4 |
| `internal/maintenance/` | Backup, restore and controlled updates | 5 |
| `packaging/` | Supported host installation and OS-login integration | 5 |
| `tests/integration/`, `tests/e2e/` | Real database/runtime tests and operator journeys | With corresponding behavior |

Do not add a message broker, vector database, distributed workflow engine or independent service without evidence that PostgreSQL and the Go process cannot meet a specific requirement.

## Phase 1 — real local core and persistent dashboard

- [ ] Add the Go module and PostgreSQL driver with actual health/read/write behavior. Embed migrations, test fresh installation and migration failure against real PostgreSQL, and expose degraded diagnostics when the VM/database is unavailable.
- [ ] Establish versioned operator commands/queries and scoped agent endpoints. Document request IDs, error responses, event cursor and authorization scope in `docs/design/api-contract.md` before concurrent UI work.
- [ ] Add transactional agent/configuration records and model-connection references. Never return underlying secrets through API responses, logs or exported settings.
- [ ] Implement loopback binding and unrelated-web request protections without adding a separate BotOS login. Demonstrate that an agent workload cannot use the operator interface.
- [ ] Add React/TypeScript/Vite with production assets served by Go. Implement the approved navigation: Agents, Work, Library, Settings and attention inbox. Use honest empty/unavailable states until each integration exists.
- [ ] Extend `scripts/verify.sh`, `scripts/bootstrap.sh`, CI, `docs/BUILD.md` and `docs/DEPENDENCY-GRAPH.md` with real Go/web/database checks. Preserve the shell fixture recursion guard.

**Exit:** Create and edit an agent through the browser, restart the service, and recover the same stored state. Killing PostgreSQL must display unavailable state and reject unpersisted work rather than reporting acceptance. Tests reject cross-origin writes and attempts to use the operator API from the workstation network. The release binary serves the UI without a Node server.

## Phase 2 — first real workstation and provider connection

- [ ] Implement the G3 host adapter and capacity accounting. Agent creation provisions persistent storage plus a dedicated workload; readiness requires working control connections, not just a running pod.
- [ ] Implement the G1 credential path and an accepted real provider engine adapter. Integrate all four launch modes before phase 6; validate subscription modes in phase 0 rather than deferring their feasibility.
- [ ] Implement the G2 managed desktop, restricted engine and broker. Version every control grant; revoke old input and observation channels during takeover.
- [ ] Add selected-workstation live interaction and timestamped fleet previews. Mask previews during private takeover; show disconnected/stale status honestly.
- [ ] Enforce per-agent folder grants, workstation ownership, storage growth approval and network/management-plane separation.
- [ ] Implement idle-stop with durable storage preservation. Do not stop active work, managed background jobs or human control merely because there has been no recent UI input.

**Exit:** The operator creates an agent, assigns a real connection, delegates a harmless filesystem/browser task, observes actual execution, enters private takeover, hands back explicitly, and stops/restarts the workstation with files retained. Adversarial capture and stale-input tests must pass. Separate agents cannot read each other's private memory, credentials or workstation storage. Capacity exhaustion queues work with a visible reason.

## Phase 3 — durable runs, recovery and cross-agent supervision

- [ ] Persist accepted requests and procedure-version references atomically. Stable request IDs deduplicate BotOS submissions without implying exactly-once external actions.
- [ ] Implement admission and all approved run states, including explicit attention reasons, cancellation and execution-limit handling.
- [ ] Implement leases plus actual action fencing. Prevent a replacement executor from acting while an older executor remains authorized.
- [ ] Persist checkpoints, action logs, selected screenshots and result evidence. Completion depends on outcome evidence, not child-process exit alone.
- [ ] Implement resumable progress subscriptions, connection loss and snapshot refresh when an event cursor is no longer usable.
- [ ] Add Work views and inbox actions backed by durable state. Preserve private takeover across disconnects and ambiguous restarts.
- [ ] Execute G4 with crashes before and after command acceptance, persistence, external submission and result recording. Use a controlled test service that can commit an effect and then lose its response.

**Exit:** Duplicate submissions create one run. Restart loses no accepted work. An uncertain external effect becomes needs-attention instead of a duplicate action. Old executors and stale UI commands cannot regain control. Run limits pause and notify; connection failure never silently selects a different provider.

## Phase 4 — procedures, schedules, memory and collaboration

- [ ] Add conversational teaching and editable procedure drafts, private/shared libraries, user activation and immutable versions. Test that sharing instructions grants no additional credentials or permissions.
- [ ] Add normal occurrence queuing and downtime catch-up: queue every normal occurrence, recover only the latest missed occurrence within expiry, and skip expired queued work with a recorded reason.
- [ ] Add approved-procedure heartbeat initiation under existing permissions and resource/run limits.
- [ ] Add private automatic memory updates with user inspection, edits, deletion and source provenance. Apply retrieval authorization before supplying context to any engine.
- [ ] Implement forgetting across source links and derived retrieval indexes. Test that retained historical records cannot immediately repopulate deleted memory through retrieval; document the limits of already-sent context.
- [ ] Add configurable collaborator access with explicit-context handoffs. Helpers use their own workstation and authority. Detect circular waits and surface a blocker.

**Exit:** Teach a generic procedure once, approve it, run it with different inputs, and review traceable output. A revision affects subsequent runs only. Scheduler tests cover normal overlap, downtime, expiration and duplicate wakeups. Collaboration cannot read unshared context or directly control the owner's workstation.

## Phase 5 — installation and recoverable maintenance

- [ ] Package the accepted G3 runtime into an installer that owns prerequisites on the published support matrix. Install the background service after OS login, preserve existing data during repair, and document permissions the OS requires.
- [ ] Suggest a host resource budget, enforce manual limits and test VM overhead plus concurrent workstation reservations. Notify on storage pressure without silently increasing limits or deleting history.
- [ ] Implement encrypted manual/recurring backups to chosen folders, external drives and mounted network storage. Securely remember local key material for unattended backup and provide a separately saved recovery key.
- [ ] Coordinate database/workstation consistency with a pause. Exclude model credentials, preserve model settings and record image/schema identities in a validated manifest.
- [ ] Restore into an isolated clean installation for verification. Require provider reconnection and review before restored runs/schedules act. Surface older-backup memory resurrection before enabling retrieval.
- [ ] Implement approval-controlled updates with a verified recovery backup, maintenance admission stop, migrations and health checks. Keep failed upgrades paused; distinguish binary rollback from database recovery.
- [ ] Execute G5 for corruption, wrong/missing key, disk full, disconnected destination, interrupted write, incompatible schema/image and update failure.

**Exit:** Restore a real backup onto a clean supported installation using the exported recovery key. Workstation files and records agree, model secrets are absent, and nothing automatically repeats an external action. An incomplete backup is never offered as successful recovery. A failed update preserves a verified recovery route. Retention remains user-controlled.

## Phase 6 — release acceptance

- [ ] Exercise Claude subscription, Codex subscription, OpenAI BYOK and Anthropic BYOK individually against the credential boundary. Record supported versions and any provider eligibility limitations.
- [ ] Run the installer and lifecycle matrix on each advertised host/architecture, including a host restart and OS-login startup.
- [ ] Run at least two different application workflows through teaching, approval, recurring execution, intervention and evidence review. These are acceptance scenarios, not product scope restrictions.
- [ ] Verify fleet behavior under the configured resource limit, human takeover, stale previews, scheduled wakeups and storage exhaustion.
- [ ] Review independent security evidence for provider custody and private takeover, then run the assembled backup/update/recovery suite.
- [ ] Finish release-facing setup, limitations and recovery documentation. Update BUILD and dependency records to reflect implemented behavior; keep the prototype separate.

**Exit:** All advertised first-release behavior is backed by evidence from the assembled release. No unsupported provider mode, host platform or privacy guarantee is presented as working. Unresolved gate failure blocks the affected release claim and requires an explicit scope decision.

## Coverage and handoff

Architecture sections 1–4 map to phases 0–3; knowledge in section 5 maps to phase 4; backup/update sections 6–7 map to phase 5; infrastructure, trust and transport sections 8–11 map to phases 0, 2 and 5; consolidated policies in sections 12–13 map across phases 2–5; validation and delivery sections 14–15 map to phase 0 and gates G1–G5 through phase 6. Section 16 supplies source provenance and limits for those investigations.

For each phase, first write its coding plan using accepted predecessor contracts, then implement with meaningful failing tests, verify the integrated result and obtain an independent review of security-sensitive changes. A downstream plan must name exact interfaces and chosen dependency versions; it cannot substitute this roadmap for unresolved gate outputs.

The immediate next work is G1 and G2 in parallel, with G3 as the next available investigation slot. No new product decision is needed to start those bounded feasibility investigations. Real-account consent or an unavailable host needed for a test may become a specific execution blocker; never assume that approval of this architecture authorizes a purchase or account modification.
