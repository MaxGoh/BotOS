## Implementation status and execution rules

All tasks below are future release implementation work. Existing foundation,
prototype and contributor probes do not complete these tasks. Execute A now;
execute B in parallel. A does not wait for provider or desktop feasibility.
C–G require their listed predecessor contracts and evidence. Keep each checkbox
current when its actual work and verification finish. Publication belongs to the
active harness, not an implementation task.

Before each task, read its capability spec and relevant technical design section.
Add meaningful failing tests, implement behavior, run component checks and
`make verify`, then review the result. Update BUILD/dependency documentation and
append an agDR for each logical implementation change. Do not introduce placeholder
endpoints or production fixture data. A failed prerequisite blocks the affected
task, not unrelated workstreams.

## A. Persistent agent-management vertical slice — start immediately

Owner paths: `cmd/botos`, `internal/agents`, `internal/control`, `internal/store`,
`migrations`, `web`, `scripts`, `.github/workflows`.
Capability coverage: `local-core`, identity portion of `agent-model-access`,
navigation portion of `live-supervision`.

- [ ] A.1 Select and pin the Go/PostgreSQL driver and migration tool; introduce the Go module with real database connectivity, startup/shutdown and liveness/readiness behavior. Verify unavailable PostgreSQL never reports ready.
- [ ] A.2 Add versioned agent/configuration/connection-reference tables with stable IDs and revision checks. Verify create/edit survives a service restart and conflicting edits are rejected without lost updates.
- [ ] A.3 Implement and document the first-slice HTTP routes from design.md, validation, error responses and expected-revision contract. Test malformed inputs, unknown IDs, database failure and concurrent edits against real PostgreSQL.
- [ ] A.4 Enforce loopback operator serving, unrelated-origin write protection and distinct scoped agent API authority. Test hostile browser origins and agent-origin operator requests rather than only checking bind configuration.
- [ ] A.5 Build the React/TypeScript/Vite agent list and create/edit flow using the actual API. Serve release assets from Go and verify no production Node service is required.
- [ ] A.6 Add approved navigation and truthful empty/unavailable Work, Library, attention and workstation views; preserve the approved prototype separately. Verify creating an agent does not invent a connected engine or desktop.
- [ ] A.7 Wire Go, web and real PostgreSQL integration tests into `make verify` and contributor/CI setup. Add a browser acceptance test for create, edit, refresh and service restart. Record exact toolchain and commands.

A acceptance: a contributor can build and run the service/UI, persist an agent
and see honest dependency state without subscriptions, host virtualization or
maintainer credentials. This is the first reviewable software milestone.

## B. Feasibility contracts — parallel with A

Owner paths: `experiments`, `docs/validation`, `docs/design/runtime-contracts.md`.
Capability coverage: `agent-model-access`, `private-desktop-control`,
`workstation-lifecycle`, `install-update-release`.

- [ ] B.1 Implement a disposable request-capture fixture isolated from ambient CLI configuration and credentials. Test engine request routing with controlled markers and deny access to other agents' capabilities; keep the fixture outside production code.
- [ ] B.2 Validate OpenAI and Anthropic BYOK paths with contributor-controlled connections. Record engine visibility, streaming, refresh/revocation, error and cancellation results; ensure upstream keys never enter workstation state or exports.
- [ ] B.3 Validate Claude and Codex subscription eligibility and credential routing independently. Reject the known external-token candidate under the current boundary. Record an exact incompatibility for operator resolution if no supported route passes; do not silently move engines or reduce launch scope.
- [ ] B.4 Assemble a pinned disposable desktop, restricted engine and trusted broker candidate with explicit UIDs, mounts, sockets and application policy. Demonstrate ordinary observation/input and record all alternate capture/control routes.
- [ ] B.5 Run G2 adversarial takeover cases: persistent recorders, browser instrumentation/extensions, debug/accessibility/display routes, stale input, private-frame buffers, disconnect and handback. Keep private confirmation disabled when any revocation is unproven.
- [ ] B.6 Implement reproducible managed VM/Kubernetes/PostgreSQL experiment setup and teardown for contributor-owned hosts. Record exact macOS/Linux architectures, component versions and unsupported-host diagnostics; preserve unrelated host data/settings.
- [ ] B.7 Measure baseline overhead and concurrent resource reservations, actual disk quota, mounts/symlink escapes, network/VPN behavior, management isolation, restart and interrupted setup. Inventory success alone must not pass G3.
- [ ] B.8 Review the combined G1–G3 composition and publish accepted runtime contracts. Verify the chosen engine works under the chosen desktop restrictions on the chosen host setup. Obtain an independent security review and resolve findings before dependent production integration.

B acceptance: supported mechanisms and observed evidence, not a speculative proxy
or successful prototype. Incomplete subscriptions block the full release but do
not prevent A or an explicitly labeled partial development milestone.

## C. Real workstation and model execution

Depends on A plus accepted B contracts for each integration.
Owner paths: `internal/workstations`, `internal/providers`, `internal/control`,
`workstation`, `web`.
Capability coverage: `workstation-lifecycle`, `agent-model-access`,
`private-desktop-control`, `live-supervision`.

- [ ] C.1 Implement the managed-host adapter and reconciliation loop for persistent storage, workload lifecycle and actual connection readiness. Test partial provisioning, workload failure, stop/restart, explicit retirement and storage preservation during workload replacement.
- [ ] C.2 Add budget configuration and RAM admission with measured overhead. Queue starts when full, reject impossible manual budgets and avoid abruptly evicting active work when lowering a budget.
- [ ] C.3 Implement one owner per workstation, explicit host folder grants, management-network protection and actual storage enforcement. Test cross-agent access denial, grant revocation, path escape and storage-full notifications with approval-only expansion.
- [ ] C.4 Implement production host-side model custody and explicit reusable connection assignment using accepted G1 paths. Test scoped access, secret-redacted diagnostics, expiry/revocation and refusal of automatic fallback.
- [ ] C.5 Implement restricted engine launch and managed application catalog with reviewed installation requests. Test that scripts cannot acquire root, alter trusted startup/configuration or use unmediated desktop/debug authority.
- [ ] C.6 Implement broker control generations and takeover state transitions with independently confirmed revocation. Repeat G2 against production packaging, including operator disconnect, teaching mode and explicit handback.
- [ ] C.7 Add selected live desktop and fleet thumbnails with latest activity, timestamps and stale/disconnected indicators. Test private takeover across every media, recording and cache path.
- [ ] C.8 Implement idle-stop and always-on settings; wake workstations for queued work while preserving active runs, managed background jobs and human control. Test capacity-limited wakeups and retained files.
- [ ] C.9 Complete the real vertical slice: delegate a harmless browser/filesystem task, observe actual work, take over privately, hand back and restart the workstation. Record evidence using a real supported provider, with no mock production route.

## D. Durable execution and recovery

Depends on C; finalize API/event contracts before parallel UI work.
Owner paths: `internal/runs`, `internal/store`, `internal/control`, `web`.
Capability coverage: `durable-execution`, `live-supervision`.

- [ ] D.1 Implement atomic request acceptance, stable request deduplication, per-agent admission and all specified run states. Test racing submissions and crashes on both sides of transaction commit.
- [ ] D.2 Implement executor ownership with actual fencing and generation checks. Test a living stale engine after lease expiry and prevent overlapping action authority.
- [ ] D.3 Implement persisted checkpoints, action/evidence records and outcome-based completion. Test an external fixture that commits an effect then loses its response; require reconciliation or attention without duplicate action.
- [ ] D.4 Implement pause, resume, cancellation and configurable execution/model-request limits. Separate cancellation intent from confirmed shutdown and reconcile in-flight effects before resumption.
- [ ] D.5 Implement resumable events, cursor resync and stale-command rejection. Test reconnect after event loss, database interruption and old-browser commands.
- [ ] D.6 Complete Work/run-detail/attention views with real progress, results, evidence and intervention actions. Keep run state distinct from workload health and screen connectivity.
- [ ] D.7 Run the G4 crash matrix across core, database, engine and control broker; measure transport response under load and set reviewed acceptance targets. Resolve stale-owner, double-action and private-frame failures before accepting this phase.

## E. Repeatable work, knowledge and collaboration

Depends on D. Procedure and memory implementation may proceed independently once
shared record and retrieval-authority contracts are accepted.
Owner paths: `internal/knowledge`, `internal/runs`, `internal/agents`, `web`.
Capability coverage: `procedures-teaching`, `scheduling-collaboration`,
`memory-evidence`.

- [ ] E.1 Add conversation-led ad hoc runs and supervised procedure drafting with steps, inputs, rules and stop conditions. Test useful work without first saving a procedure.
- [ ] E.2 Implement private/shared libraries, draft revision, operator activation and immutable approved versions. Test that active runs stay pinned and shared procedures grant no memory, account or workstation access.
- [ ] E.3 Implement normal occurrence queuing, expiry reasons and downtime catch-up while retaining the prior durable queue. Test races between scheduler workers and duplicate wakeups.
- [ ] E.4 Implement heartbeat initiation restricted to approved procedures and existing authority, budgets and limits. Reject execution of unapproved drafts.
- [ ] E.5 Implement automatic private memory changes with provenance and operator inspect/edit/delete UI. Apply access controls before context assembly and test cross-agent retrieval denial.
- [ ] E.6 Implement forgetting through source exclusions and derived-index/cache removal; test that retained history cannot repopulate deleted memory through retrieval. Explain already-sent context limitations.
- [ ] E.7 Implement disabled/approved/any-agent collaboration settings, explicit-context handoffs, helper queuing and circular-wait detection. Test that a helper never gains direct control of the owner's workstation.
- [ ] E.8 Implement retained action logs, selected screenshots and evidence storage with capacity reporting and operator deletion. Test no default continuous recording and no automatic pruning under pressure.
- [ ] E.9 Run two distinct application workflows through teaching, approval, recurring execution, exception handling and evidence review. Keep examples as acceptance fixtures, not product scope restrictions.

## F. Installer, backups and controlled updates

Depends on accepted host contracts and D. Final capture/restore tests include E.
Owner paths: `packaging`, `internal/maintenance`, `internal/workstations`, `web`.
Capability coverage: `backup-restore`, `install-update-release`.

- [ ] F.1 Package the managed VM/cluster prerequisites and post-login host service for the published macOS/Linux matrix. Test fresh install, partial install, repair, restart and uninstall without silently deleting user data.
- [ ] F.2 Implement secure host key storage, automatic-backup encryption and recovery-key export with maintained components. Test unavailable secure storage, missing/wrong recovery key and refusal of plaintext fallback.
- [ ] F.3 Implement coordinated PostgreSQL/workstation capture and versioned integrity manifests. Defer during human takeover or unsafe interruption and reject inconsistent captures.
- [ ] F.4 Add manual and recurring backup UI for chosen folders, external drives and mounted storage. Test destination loss, full disk, interrupted writes and preservation of every existing valid backup until explicit deletion.
- [ ] F.5 Implement restore compatibility/integrity checks and provider reconnection. Hold restored work and schedules for review, and surface older-memory resurrection before retrieval resumes.
- [ ] F.6 Restore a backup into a clean installation using only the separately saved recovery key and documented inputs. Verify records/files agree, provider secrets are excluded and no external effect resumes automatically.
- [ ] F.7 Implement approved updates with compatible component pins, a verified recovery backup, admission stop, safe pause, migrations and health checks. Prevent managed components from silently bypassing the update policy.
- [ ] F.8 Run G5 failure injection for corrupted manifests, absent images, incompatible schemas, interrupted migrations and failed health checks. Demonstrate recovery and leave uncertain execution paused.

## G. Full release acceptance

Depends on A–F; no estimated timeline substitutes for evidence.
Owner paths: `tests/integration`, `tests/e2e`, `docs/validation`, `docs/BUILD.md`,
`.github/workflows`, release packaging.
Capability coverage: all eleven capability specs.

- [ ] G.1 Run each capability scenario against the assembled release and record requirement-to-test evidence, exact versions, commands and limitations. Do not reuse foundation CI results as runtime proof.
- [ ] G.2 Complete the four-mode provider matrix including subscription eligibility, secret custody, cancellation and revocation. Block the full-release claim if any selected mode remains unvalidated.
- [ ] G.3 Complete each advertised host/architecture row for installation, post-login startup, concurrency/resource limits, folder grants, networking, takeover and recovery. Do not advertise untested distributions.
- [ ] G.4 Obtain independent security review of management authority, provider custody, private takeover and backup/recovery. Fix findings and rerun affected adversarial cases.
- [ ] G.5 Verify reproducible builds, pinned component inventory/licenses, release artifact integrity, contributor instructions and real CI checks without production fixture data or maintainer-secret dependencies.
- [ ] G.6 Publish installation, intervention, limitations, backup/key-recovery and failed-update runbooks. Update implemented dependency maps and BUILD commands; archive this OpenSpec change only after release acceptance is complete.

## Requirement ownership and gates

| Capability | Task groups | Required release evidence |
| --- | --- | --- |
| local-core | A, D | Real persistence/restart, outage and API authority tests |
| agent-model-access | A, B, C, G | G1 all four modes; stable identity and no secret leakage |
| workstation-lifecycle | B, C, F, G | G3 persistence, capacity, quotas, grants and host matrix |
| private-desktop-control | B, C, D, G | G2 adversarial capture/input and explicit handback |
| live-supervision | A, C, D | Actual media, freshness, attention and privacy evidence |
| durable-execution | D | G4 duplicate, fencing, crash and external uncertainty matrix |
| procedures-teaching | E | Draft/activation/version and authority separation tests |
| scheduling-collaboration | E | Overlap, downtime, expiry, heartbeat and wait-cycle tests |
| memory-evidence | E, F | Authorized retrieval, forgetting, retention and restore review |
| backup-restore | F | G5 fresh-machine recovery and corruption/failure evidence |
| install-update-release | F, G | G3/G5 install/update plus complete release acceptance |
