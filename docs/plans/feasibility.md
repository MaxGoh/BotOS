# BotOS Feasibility Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans or superpowers:subagent-driven-development when executing these work packages. Follow the active harness publication contract. These are evidence-producing investigations, not authorization to ship an experimental runtime.

**Goal:** Establish tested provider, desktop and host mechanisms before dependent production implementation.

**Architecture:** Validate the three hard boundaries independently, then reconcile them into one runtime contract. Experiments remain isolated from production paths and use disposable environments.

**Tech Stack:** Go core target; candidate Lima/K3s managed VM, PostgreSQL, restricted provider engines, Wayland desktop and noVNC transport. Record concrete versions in each experiment rather than adopting unverified latest versions.

**Spec:** [Approved technical design](../design/technical-design.md). Delivery context: [phased implementation plan](implementation-roadmap.md).

## Global constraints

All global constraints in the phased plan apply. In particular, provider credentials cannot enter a workstation; private takeover must be independently enforced; no agent root; and a failed gate cannot silently weaken a requirement. Do not expose secrets in reports. Use controlled credentials for negative tests. Do not install into or alter an operator's host without the authorization required for that action.

Paths below are intended MaxGoh/BotOS paths. The approved documents are now imported alongside this plan; publication remains owned by the harness. These packages consume documents and produce evidence; they do not prescribe unproven production APIs.

## Task 0 — import the approved specification

**Files:** Create `docs/design/technical-design.md`, `docs/design/provider-integration-findings.md`, `docs/plans/implementation-roadmap.md`, `docs/plans/feasibility.md`; update `docs/BUILD.md`; add a new `docs/agdr/AGDR-YYYY-MM-DD-NNN-technical-architecture.md` using the repository's next actual sequence.

**Consumes:** The four corresponding project artifacts, plus existing product design and instructions.

**Produces:** Self-contained repository planning documents, with relative links resolved and approval provenance retained.

- [x] Copy the approved architecture, provider findings and both plans; rewrite links to the existing `docs/design/product-design.md` and their new relative locations. Do not copy WORKLOG history or baseline logs as implicit runtime evidence.
- [x] Record the approved architecture and its explicit supersessions in the new agDR. Align BUILD's previous “stack undecided” statement with approved-but-unimplemented status.
- [x] Run `make verify`; fix broken links and substantive instruction contradictions without modifying the immutable approved prototype. Keep future tasks unchecked.

## Evidence contract for G1–G3

Each gate creates `docs/validation/GN-report.md` and `docs/validation/GN-results.json`, where GN is G1, G2 or G3. JSON contains `gate`, `verdict` (`pass`, `fail` or `blocked`), `tested_at`, `host`, `versions`, `cases`, `limitations`, and `artifact_paths`. Each case has `id`, `requirement`, `setup`, `command_or_steps`, `expected`, `observed`, `verdict`, and `evidence_path`. The report includes source links and retrieval dates for claims derived from upstream documentation.

A pass requires every mandatory case to pass on the declared configuration. An unavailable environment is blocked, not passed by document inspection. An observed violation is fail, not merely a risk note. Evidence must distinguish the tested candidate from a hypothetical alternative.

## Task G1 — provider access without workstation credentials

**Files:** Create `docs/validation/G1-report.md`, `docs/validation/G1-results.json`, and `experiments/provider-boundary/README.md`. Put any disposable probes and test-service code under that experiment directory, with commands and cleanup recorded in its README.

**Consumes:** Approved provider boundary, the existing research findings and current official provider integration contracts.

**Produces:** Per-mode authentication/data-flow diagram; eligible official integration route; secret lifecycle; supported engine version; cancellation/resumption behavior; pass/fail evidence. Do not create a production adapter interface until the supported route is established.

- [ ] Recheck official Claude and Codex subscription integration documentation and named-provider BYOK documentation. Record eligibility separately from technical compatibility; distinguish host-owned token exchange from a token delivered into the engine.
- [ ] Draw the engine/host/provider request path for each mode. Enumerate every credential and capability visible to the engine. A restricted BotOS capability is acceptable only if it cannot reveal an upstream credential or escape its assigned authority.
- [ ] Build the smallest disposable request-path experiment using the documented interface. Stop and report if it requires violating the boundary; do not fabricate a proxy for an undocumented authentication protocol.
- [ ] Run cases P1–P6 below for each candidate route. Redact real secrets at collection, not after publishing evidence.
- [ ] Record all four mode verdicts independently. A blocked subscription mode remains a launch blocker even when both BYOK modes pass.

| Case | Required observation |
| --- | --- |
| P1 | One supported inference request works through the host-owned credential path. |
| P2 | Engine-visible filesystem, environment, arguments, configuration and logs do not expose upstream keys or tokens. |
| P3 | An agent cannot request another agent's connection or retrieve raw secret material. |
| P4 | Expiry/revocation pauses execution and notifies; no silent fallback or credential copying. |
| P5 | Cancel and reconnect do not create an untracked active executor or silently duplicate an external tool action. |
| P6 | Backed-up model settings contain connection references, not provider secrets. |

## Task G2 — independently enforced private takeover

**Files:** Create `docs/validation/G2-report.md`, `docs/validation/G2-results.json`, `experiments/private-takeover/README.md` and the exact image/configuration/probe files used by the experiment in that directory.

**Consumes:** Restricted engine plus managed desktop and trusted broker architecture; Wayland/noVNC candidates; declared threat model.

**Produces:** Concrete process identities, mounts, sockets, capabilities, capture/input routes, application restrictions and revocation protocol with an adversarial test report.

- [ ] Assemble one disposable desktop and engine separation using pinned components. Enumerate agent-writable files and every display, debug, clipboard and remote-control endpoint.
- [ ] Demonstrate ordinary agent observation and input. Demonstrate the operator connection remains usable after revoking agent access.
- [ ] Install controlled recording probes through every path the agent is actually permitted to use. Include browser instrumentation and background jobs; merely stopping the primary engine is insufficient.
- [ ] Exercise preparing → confirmed private control → explicit handback, injecting channel failures and delayed commands at each transition.
- [ ] Run D1–D7 and document any application or scripting restrictions required to pass. Failure must block private-mode confirmation, not hide the indicator.

| Case | Required observation |
| --- | --- |
| D1 | Revoked screen/input capabilities cannot reconnect or replay queued input. |
| D2 | Agent-created capture, debug and clipboard probes cannot observe private operator actions. |
| D3 | Fleet previews, screenshot persistence and stream buffers reveal no private-period frames. |
| D4 | Browser debugging, extensions and startup-file changes cannot bypass the declared boundary; unsupported paths are unavailable. |
| D5 | Operator disconnect or controller crash leaves agent access revoked until explicit recovery/handback. |
| D6 | Teaching mode visibly enables only intended observation; agent control remains off. |
| D7 | Handback inspects permitted current state without replaying uncertain actions; failure to prove revocation never enables private control. |

Do not claim kernel-compromise containment. Do not treat a frozen whole desktop as a successful interactive takeover.

## Task G3 — managed VM, cluster and storage on supported hosts

**Files:** Create `docs/validation/G3-report.md`, `docs/validation/G3-results.json`, `experiments/managed-host/README.md` and pinned VM/cluster/storage configurations under that directory.

**Consumes:** Lima/K3s candidates; shared VM and PostgreSQL placement; configured RAM reservation and persistent storage requirements.

**Produces:** Tested host/architecture matrix, version inventory, measured overhead, lifecycle commands, network/mount design, actual storage-limit mechanism and supported installation prerequisites.

- [ ] Inventory available real macOS/Linux hosts and architectures. Declare untested combinations explicitly; a Linux test cannot establish macOS compatibility.
- [ ] Provision a disposable managed VM and cluster with PostgreSQL and one workstation. Record all commands and measured CPU/RAM/disk usage at idle and during representative work.
- [ ] Exercise startup after login, workload stop/restart and VM restart with retained files and database records.
- [ ] Test resource admission at the configured budget, host overhead, impossible manual settings and storage exhaustion. Verify filesystem behavior at the limit rather than inferring a quota from a PVC request.
- [ ] Test explicit folder mounts, missing/remounted directories, internet/host-network reachability and denial of workstation access to management interfaces. Test a VPN where a supported host uses one.
- [ ] Exercise interrupted installation and uninstall/repair preserving user data. Record required OS permissions without disabling host security as a workaround.

A failed or unavailable host does not expand the supported matrix. Reserve an actual macOS execution slot before claiming the cross-platform installer gate passed.

## Task 4 — reconcile evidence and write the first coding plan

**Files:** Create `docs/design/runtime-contracts.md`, `docs/plans/core-local-service.md` and a new agDR; update gate reports only to append clearly dated integration results.

**Consumes:** G1–G3 reports and original approved requirements.

**Produces:** An accepted implementation boundary, or a concise operator decision describing the specific incompatibility.

- [ ] Check that the G1 engine can operate under G2 restrictions and that G3 can host that exact composition. Re-run any invalidated gate case against the combined configuration.
- [ ] Document process placement, persistent data ownership, supported versions, secret routing, operator/agent API separation and revocation responsibilities.
- [ ] For a passing host/database contract, write the phase 1 coding plan: exact source/test files, migration and driver choices, API types, failing-test examples and commands, build integration and failure states. Keep provider/desktop production work gated if either boundary is unresolved.
- [ ] Run `make verify` for repository artifacts and the separate recorded experimental commands for gate evidence. Never equate documentation verification with an experiment passing.
- [ ] Independently review security-sensitive gate evidence before accepting it as the foundation for phase 2. Follow the session's required delegation workflow and integrate the review locally.

Execution update 2026-09-06: Task 0 is complete. A local Codex schema probe and host preflight ran; the assembled G1–G3 experiments remain blocked. See the gate reports in `docs/validation/`. This document does not certify feasibility.
