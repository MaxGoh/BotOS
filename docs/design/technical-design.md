# BotOS technical design

Status: approved by the operator on 2026-09-06 through botos-consolidated-technical-review. Approval covers the consolidated architecture and validation contracts G1–G5. Candidate technologies remain subject to those gates; no application implementation or feasibility test is claimed.

This is an architecture specification, not an execution-ready implementation plan. Candidate selections become supported components only after the validation gates pass. If a required gate fails, return the incompatibility to the operator instead of silently changing requirements.

Product context: [approved product design](product-design.md). Integration findings: [provider research](provider-integration-findings.md). Approval provenance: operator confirmed botos-consolidated-technical-review on 2026-09-06. This document was imported from the BotOS project planning session; feasibility is still unverified.

## 1. Core structure — approved

One Go core service runs on the host. Its internal modules cover agents/connections, runs/scheduling, workstations, control/model access, knowledge and maintenance. Python is introduced only where an integration requires it. Independent microservices are not selected.

React with TypeScript is built using Vite; the Go service serves release assets. Future native clients use Swift for Apple platforms and Kotlin for Android. Clients use the Go API rather than accessing PostgreSQL, Kubernetes or provider credentials directly. Versioned HTTP/JSON commands and queries plus a resumable event feed are approved in section 4. Detailed schemas remain implementation-plan work. Wayland and noVNC are candidates under section 11.

One BotOS-managed Linux VM runs on both macOS and Linux hosts. A dedicated managed Kubernetes cluster runs inside it, hosting agent workstations and a separate PostgreSQL system workload with persistent storage. The VM stays running while BotOS is enabled; individual idle workstations stop. No existing-cluster support is selected for the first release.

PostgreSQL owns durable application state; Kubernetes reports actual workstation state. The host service can expose diagnostics during VM/database failure, but durable operations wait for recovery. An operational workstation or a successful engine exit does not prove a task outcome.

## Feasibility gates still open

- Engines run inside workstations while every provider credential remains outside. Claude subscription, Codex subscription and OpenAI/Anthropic BYOK are requested first-release targets; no subscription path has passed the strict credential-boundary validation. Local inference follows later.
- Same-desktop private takeover must independently prevent agent action and observation. Unrestricted root was superseded; managed application catalog selected. Restricting root alone is insufficient and the execution/session isolation requires proof.
- Lima, K3s, Wayland and noVNC are approved candidates, not tested support promises. Exact versions, compositor/remote server, host prerequisites, storage, network and secure-store implementations must pass the validation contracts in section 14.

## 2. Durable execution — approved

Persist submitted requests in PostgreSQL before acknowledging acceptance. Client retries of the same submission return the existing run using a stable submission identifier. One active run per agent; ownership is durable. After failure, confirm old execution has stopped or cannot act before starting a replacement, not merely that a database lease expired.

Persist engine events, checkpoints and result evidence against each run; pin approved procedure versions. Reconcile saved progress against workstation/application state following interruption. Uncertain external actions require reconciliation or operator attention before retry. Engine exit status is distinct from outcome evidence. These rules do not guarantee exactly-once effects in external applications or independent verification of every internal engine action.

## 3. Workstation lifecycle — approved

Separate persistent agent identity, persistent workstation storage, and the running workload. Stops/restarts/engine changes preserve identity; idle-stop preserves storage. Reconcile desired state with observed Kubernetes and connection health rather than assuming a submitted cluster operation succeeded.

Start only when configured RAM fits the host budget. Ready requires usable workstation/engine connections, not only a running workload. Protect active runs, BotOS-managed background processes and human takeover from idle-stop. Unexpected failure enters recovery; infrastructure restart does not automatically repeat work. Resource/image changes requiring restart wait for safe maintenance. Agent/data deletion is explicit and separate from stop.

The precise workload/container layout remains subject to private takeover feasibility. One logical workstation does not imply one container.

## 4. API and control boundaries — approved

Separate the local operator API from the scoped agent API. Operator API manages the installation; agent API is bound to its assigned agent/run for reporting, permitted operations and authorized collaboration. BotOS-issued agent credentials are distinct from provider credentials. Agent interfaces grant no operator, Kubernetes-admin or direct database access.

Use versioned HTTP/JSON commands and queries with resumable progress events; when replay is unavailable clients reload authoritative state. Reject stale control commands, including delayed commands issued before human takeover. Desktop video/input uses a separate transport with control-ownership checks; noVNC and a suitable server/bridge are candidates under section 11.

No separate operator login is required for v1 per operator choice. Prevent unrelated websites from initiating commands and workstation traffic from accessing the operator interface. Network reachability does not imply operator authority. API controls alone do not prove same-desktop private takeover.

## 5. Knowledge storage and retrieval — approved

Store procedure versions, private memory and run history/evidence as distinct record types in PostgreSQL. Approved procedure versions are immutable; changes create drafts and activation requires operator approval. Existing runs stay pinned. Private memory entries retain provenance/change history and allow automatic updates plus operator inspection/edit/deletion. Run history is retained until deletion; large artifacts use managed files referenced from records.

The Go retrieval service checks authorization before returning content: agent-private information, authorized shared procedures, and explicit collaboration context only. Shared procedures confer no author memory, credentials or workstation access. Forgetting excludes linked historical sources and derived search entries from subsequent agent retrieval. Retrieved content grants no permissions and cannot activate procedures.

BotOS assembles explicit context independently of an engine-specific conversation format. Search/index choices, context budgets and race-safe retrieval exclusion remain implementation design work.

## 6. Backup and restore — approved

Support configurable recurring and manual backups to a selected folder, external drive or mounted network storage. Retain backups until operator deletion. Encrypt backups with generated recovery material: retain local encryption material securely for automatic backup after OS login and have the operator save a separate recovery key. Password-only protection was superseded. Exclude model credentials; retain connection settings/references and require reconnection after restore. Workstation contents may include application/browser sessions.

A versioned manifest records software/schema versions, workstation image references, included data and integrity checks. Coordinate a consistent capture of PostgreSQL and workstation storage; defer with explanation during human takeover, unsafe interruption or inability to establish consistency. Incomplete backups are unusable; preserve previous successful backups. Validate output before reporting success.

Before restore, check compatibility/integrity. Restore records and contents without automatically replaying work. Restored runs/schedules wait for review, provider reconnection where needed and reconciliation of uncertain external actions. Include actual restore testing in implementation verification. Encryption/key storage libraries, snapshot/export mechanism and destination durability semantics remain to select and validate.

## 7. Controlled updates — approved

Updates require operator approval and an identified compatible set of Go service, database schema, Kubernetes and workstation-image versions. At a safe maintenance point, stop admission of new runs and finish or safely pause existing work; human takeover blocks maintenance. Require a verified recovery backup before proceeding.

Apply upgrades/migrations while preserving workstation data. Validate database, cluster, engine connections and dashboard before resuming work. On failure, keep work paused and surface recovery diagnostics. Follow release-specific recovery procedures; executable rollback alone may not reverse schema or image-state changes. Managed application/engine updates follow the same approval policy; independent auto-updaters must not silently alter tested components.

## 8. Infrastructure candidates — approved for validation

Evaluate Lima to manage one Linux VM per host and K3s as the single-node Kubernetes distribution inside it. BotOS manages setup and pins tested versions. Additional hosts/high availability are later scope. Candidate approval does not imply verified compatibility.

Validate macOS/Linux installation and post-login startup, host-folder permissions, VPN/network reachability, layered resource accounting, persistent storage, backups/restores and upgrades. Define actual supported host prerequisites from evidence rather than claiming universal Linux compatibility.

## 9. Workstation trust layout — approved design for validation

Present one logical workstation per agent, composed of separately controlled managed desktop/applications, restricted engine/script execution environment, and trusted observation/input broker. Engine co-location is retained at the logical workstation level. Engine access to protected desktop state is mediated; no unrestricted display, browser debugging or system-configuration access. Managed catalog owns system installations.

Private takeover requires external revocation of agent observation/input and suspension of agent-controlled execution while maintaining the human connection. Separate components alone do not establish privacy: test background scripts, modified files, browser instrumentation and stale connections. Exclude applications from supported catalog if they cannot satisfy the boundary. Terminal scripts cannot freely alter protected desktop components.

Concrete process/container boundaries and transport selection remain validation work, not a proven guarantee. Protecting against agent observation in this layout is distinct from claiming containment against every possible workstation/kernel compromise.

## 10. Private takeover protocol — approved for validation

On takeover request, enter Preparing takeover and stop admission of new agent actions. Revoke agent input/observation, close existing observation channels, suspend agent-controlled execution and clear agent-facing preview buffers. Enable human input and label the session private only after required controls acknowledge completion; otherwise show the blocker.

Handback is explicit. Browser disconnect leaves the agent paused. Before resuming, inspect permitted current state and reconcile execution/control ownership. Service restart cannot implicitly return control while ownership is uncertain. Teaching is an explicit transition permitting selected observation while retaining disabled agent actions; indicate recording behavior.

Protocol correctness does not prove desktop integrity. Test that agent-created scripts/instrumentation cannot continue observation through alternate channels. Previous information already sent to a provider is not erased by takeover.

## 11. Display and remote viewing — approved candidates

Evaluate Wayland as the primary display foundation, with broker-mediated engine observation/input and noVNC as a browser viewing candidate using a suitable VNC server and WebSocket endpoint. Select a compatible compositor, capture/input implementation and remote server together through validation; Wayland is not itself a complete remote-desktop implementation. Test X11 application compatibility separately. This revises the original PRD's direct X11 entry-point requirement; no unrestricted display socket is granted to engine scripts.

A selected workstation supports interactive viewing, while the fleet overview uses lower-rate trusted thumbnails, timestamps and stale/disconnected states. These are separate observation paths governed by the same takeover boundary. Human access remains available during private takeover; engine capture and fleet previews do not reveal private frames. Exact performance targets are to be measured and proposed in the desktop validation report before acceptance. Do not treat smooth prototype playback as transport evidence.

## 12. Operating policies — consolidated prior decisions

### Host and operator access

- Target local macOS and Linux broadly, with actual supported architectures/host prerequisites established by installer validation. Do not claim every distro/custom kernel is supported.
- Installer owns prerequisites and dedicated cluster setup. Startup is automatic after OS login, not a pre-login boot guarantee. Closing the browser leaves the service running; host shutdown/sleep prevents normal scheduled execution.
- Local browser access only for the first release; no separate BotOS login. Trust local operator access while preventing workstation access to the operator interface and unrelated-web-origin commands. Native and remote clients are later scope with a future authentication design, not public unauthenticated access.
- One managed VM per host, shared across workstations. PostgreSQL is a separate system workload. Workstations receive no cluster-admin authority, database credentials, host credential-store access or implicit access to each other's contents.

### Resources and files

- Concurrency is capacity-limited, not fixed by a product agent-count cap. Reserve configured workstation RAM and queue starts when capacity is insufficient. Include host, VM, Kubernetes, database and trusted-component overhead in budgeting.
- Setup suggests an adjustable budget; manual values must stay within validated host limits. The specific formula must be measured rather than equating physical RAM with available workstation RAM. Proposed decrease behavior: keep active allocations safe and restrict new starts until usage fits rather than abruptly evicting agents.
- Notify about approaching workstation storage limits; increases require approval. No automatic deletion of agent files or history is authorized. Distinguish quota enforcement from disk exhaustion: Kubernetes storage declarations alone are not proof of hard storage limits.
- Host folders are granted explicitly per agent. Read-only by default with separately granted writes is the proposed default; it was recommended but not separately approved. Test path traversal, symlinks, mount permissions and folder-grant changes.
- Default workstation networking includes internet and networks reachable by the host. VPN transparency is a validation goal, not proven behavior. Operator/cluster/database/credential management boundaries remain protected even where network routing exists.

### Queues, schedules and limits

- One active run per agent; additional work queues. Persistent states: queued, running, needs attention, paused, completed, failed, cancelled. Distinguish run states from workload health and screen connectivity.
- Messages, schedules and heartbeats wake the agent's stopped workstation; insufficient capacity queues the start.
- During normal operation, every scheduled occurrence gets a queue entry. Skip expired entries with a recorded reason when they reach admission.
- After downtime, consider only the latest missed occurrence within its configured expiry. Distinguish occurrences already durably queued before interruption from genuinely missed occurrences; preserve existing queue entries and apply their expiry normally.
- Heartbeats check for work and execute approved procedures within current grants. They do not activate procedures or expand permissions.
- Require configurable active-execution-time and model-request limits. Pause additional work and notify on exhaustion. Reconcile in-flight effects; a limit cannot undo an already-submitted remote operation.
- Proposed schedule contract for implementation planning: stable schedule and occurrence IDs, explicit timezone, due time and expiry, with defined daylight-saving and clock-change behavior before the scheduler is implemented. Define pause/wait time accounting and heartbeat/queue interaction alongside that contract.

### Connections, collaboration and memory

- First-release targets: Claude subscription, Codex subscription, OpenAI BYOK and Anthropic BYOK. Named providers only. Local inference and arbitrary custom endpoints are later scope.
- Every provider credential stays outside workstations, including temporary access tokens. BotOS-scoped engine/broker credentials are a different class and must not reveal upstream provider secrets.
- Provider unavailable: pause and notify; no automatic provider/connection/billing fallback. Operators explicitly choose connection changes for subsequent runs; automatic mid-run substitution is not selected. Provider reassignment does not guarantee identical behavior or hidden-state portability.
- Model connections may be reused through explicit agent assignment without sharing agent-private memory or application credentials. Application accounts belong to the owning agent and its workstation.
- Collaboration modes: disabled, approved collaborators only, or any agent in the installation. Handoffs share explicit context only, use the helper's own queue/access, and do not delegate workstation control. Detect circular waits. Approved-collaborators default remains a proposal.
- Automatic private memory updates are allowed. Operator can inspect/edit/delete. Deleting memory excludes linked sources and derived search entries from future retrieval, while retained history remains available to the operator. Do not promise erasure from prior provider requests, already-loaded engine context or independently supplied new information.
- Shared and private procedure libraries, editable drafts, explicit activation, immutable approved versions. Procedure activation remains distinct from permissions.

### Recording, backups and updates

- Save action logs, selected screenshots and result evidence; no default continuous video. Private takeover is unrecorded; teaching observation requires explicit opt-in.
- Keep history and backups until operator deletion. Show capacity/failure states; do not silently prune to make a backup/update succeed.
- Recurring and manual encrypted backups to selected storage. Retain recovery material locally for automatic operation and provide a separate recovery key. No backup password-only mode is selected.
- Back up application records/workstation contents; exclude model credentials. Browser sessions can still be present, so backup data remains sensitive.
- Notify about updates; apply only with approval, a verified recovery backup, safe maintenance and compatibility/health checks.

## 13. Superseded choices and scope limits

- Go core replaces the earlier tentative Go-plus-mandatory-Python-service suggestion. Python remains integration-specific; Rust is not selected for initial core implementation.
- PostgreSQL was chosen over the proposed SQLite application database. This does not prescribe how Kubernetes internally stores its own state.
- React/TypeScript/Vite served by Go replaces the early Next.js suggestion. Swift/Kotlin are future clients.
- Workstation-wide root was explicitly withdrawn in favor of same-desktop privacy and restricted engine execution with managed applications.
- The operator earlier narrowed action enforcement to external boundaries. Removing root later does not silently reintroduce a promise of arbitrary application-level restrictions such as preventing purchases inside any signed-in website. Such rules need separately verified controls; otherwise they are instructions/stop conditions, not guaranteed enforcement. Workstation, model-access and private-takeover boundaries remain mandatory.
- Full containment against every possible workstation compromise was not selected. This does not waive the required separation of agents, external secrets, operator control or private takeover under the declared execution model.
- Generated recovery-key encryption supersedes password-only backup proposals. Model credentials are excluded from backups.
- Kubernetes is required; dedicated managed cluster only. Multiple hosts, existing clusters, multi-user operation, mobile/native clients, non-Linux guest OSs, voice and CAPTCHA circumvention are outside initial scope.

## 14. Validation contracts — approved; execution pending

### G1: Subscription and BYOK integration

Deliver a per-provider report identifying official supported integration interfaces, authentication eligibility, token lifecycle, request routing and cancellation/resume capabilities. Demonstrate that an engine within its logical workstation can operate without provider keys/tokens in its filesystem, environment, process-accessible configuration or logs. The broker may expose only BotOS-scoped access. Include refresh, expiration, revocation, stream interruption and provider-unavailable cases. Use controlled test credentials; never publish real secrets.

The Codex external-token mode documented during research passes a provider access token to the app server and therefore does not by itself pass this gate. Claude subscription billing documentation and third-party integration permission are separate questions; resolve eligibility rather than asserting a blanket prohibition or approval. No unsupported proxy path is accepted merely because it can technically forward traffic.

Success requires evidence for each first-release target. If a subscription path fails this gate, report the exact incompatibility and return the launch-scope/credential/placement trade-off to the operator. Do not silently ship fewer integrations or move engines.

### G2: Trusted same-desktop takeover

Select exact engine/desktop/broker process and container identities, mount/socket permissions, compositor, capture/input server, and privileged installer boundary. Demonstrate allowed agent desktop use followed by private takeover of the same logical desktop.

Negative tests cover direct display connections, alternate capture/debug endpoints, background child processes, startup-file changes, browser instrumentation/extensions, clipboard observation, delayed input, stale observation connections, cached previews, and service/browser disconnects. Show human input stays disabled if revocation/suspension is unconfirmed. Verify teaching and handback separately. Reject managed applications that cannot meet this execution model; do not substitute cooperative pause for enforced privacy.

The report must state what remains outside the tested threat model, including kernel/VM compromise and data already shared before takeover. A failed privacy test blocks claims of private mode and triggers architecture revision.

### G3: Installer, resources and local infrastructure

Pin candidate component versions and enumerate tested macOS/Linux host versions and CPU architectures. Verify hardware virtualization prerequisites, post-login startup, read-only/writable host grants, host-network/VPN reachability, management-interface isolation, real storage quota behavior, capacity admission and resource exhaustion. Measure baseline overhead separately from workstation allocations.

Test clean install, interrupted install, partial VM/cluster creation, reboot, missing mounts, failed workloads and safe uninstall behavior. Preserve pre-existing host settings/data; do not turn off host security services as an undocumented workaround. Produce exact supported prerequisites and actionable unsupported-host diagnostics.

### G4: Durable state, transport and recovery

Specify request IDs, command revision/control generation, event cursor semantics, retention/replay boundaries and database transactions. Test duplicate submissions, concurrent scheduler attempts, engine/core/database interruption, stale owners, failed cancellation and uncertain external effects using fixtures. Verify no replacement engine can act alongside an unfenced predecessor.

Exercise selected-screen input, fleet thumbnails, stale state, reconnection, and privacy transitions under connection failure and resource pressure. Measure responsiveness and propose acceptance targets from those measurements before accepting the transport. Keep action telemetry separate from claims of independently observed completion.

### G5: Backup, forgetting and update recovery

Select maintained encryption/backup components and a supported host secure-store backend; specify key creation/export, missing-key behavior and secure-store unavailability without plaintext fallback. Validate PostgreSQL/workstation consistency and restore onto a fresh installation with provider reconnection. Missing images, incompatible schema, partial/corrupt copies and destination-full cases must preserve existing valid data.

Test forgotten-source exclusions against retrieval caches/indexes and active engine-context handling. Restore can reintroduce state older than a deletion: proposed restore review must explicitly surface that risk before enabling agent retrieval. A backup is not a guarantee that old deleted data vanishes from all retained copies.

Test a failed upgrade at each migration boundary with a documented recovery route. No silent return to execution when recovery/state is uncertain.

## 15. Remaining mechanism choices and delivery sequence — approved planning direction

Do not add dependencies to solve hypothetical future scale. Resolve these choices in the relevant gate report before implementation tasks depend on them:

| Area | Required output before dependent implementation |
| --- | --- |
| Engine adapters and model gateway | G1 supported provider/engine matrix and credential-flow design |
| Desktop isolation and transport | G2 identity/mount/socket layout, compositor, remote server, capture/input revocation; G4 performance evidence |
| Infrastructure | G3 version matrix, networking/storage drivers, host resource formula and installer privileges |
| Database/API | G4 schemas/migrations, request/event contracts, authoritative run ownership and queue semantics |
| Memory/search | Authorized retrieval queries, source-exclusion mechanism and bounded context assembly; measure need before adding vector infrastructure |
| Secrets/backups | G5 host keystore, encryption and consistency/restore design |
| Build/release | Reproducible component pins, tests, license inventory, integrity verification and approved update/recovery manifest |

Start with G1 and G2 as independent feasibility work, since they can invalidate the architecture. G3 can proceed alongside them where independent. Then produce an implementation plan for the proven stack: host/core/database foundation; one real workstation and provider; durable runs and takeover; procedure/memory/scheduling/collaboration; backup/update/installation hardening. The first implementation slice is narrow, but the first-release acceptance scope still includes all selected provider integrations.

Each implementation phase needs exact files, interfaces, migrations and checks based on the target repository's then-current main branch. Code is not authorized merely by approving this architecture draft. The harness remains responsible for commits, pushes and PR creation in a correctly bound BotOS session.

## 16. Sources and evidence limits

Official documentation reviewed during brainstorming:

- [Go concurrency](https://go.dev/doc/effective_go#concurrency)
- [Python asyncio](https://docs.python.org/3/library/asyncio.html)
- [Rust ownership](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html)
- [Vite deployment](https://vite.dev/guide/static-deploy.html)
- [Next.js static export](https://nextjs.org/docs/app/guides/static-exports)
- [K3s requirements](https://docs.k3s.io/installation/requirements)
- [Lima](https://lima-vm.io/docs/)
- [Wayland architecture](https://wayland.freedesktop.org/architecture.html)
- [Wayland protocol](https://wayland.freedesktop.org/docs/book/Protocol.html)
- [WayVNC](https://github.com/any1/wayvnc)
- [noVNC](https://github.com/novnc/noVNC)
- [WebRTC overview](https://webrtc.org/getting-started/overview)
- [Linux cgroup freezing](https://docs.kernel.org/admin-guide/cgroup-v2.html)
- [Codex App Server](https://developers.openai.com/codex/app-server)
- [Claude SDK overview](https://code.claude.com/docs/en/agent-sdk/overview)
- [Claude subscription SDK guidance](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan)

These support the comparison and identify interfaces. They are not evidence that the assembled BotOS system passes G1–G5. Earlier prototype checks cover illustrative UI only. No actual subscription isolation, private takeover, cross-platform installation or backup restoration has been demonstrated in this brainstorming session.
