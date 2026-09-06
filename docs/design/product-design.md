# BotOS product design

Status: product design and revised Open Design prototype approved by the operator. Approved artifact saved and parent browser verification completed.

## Purpose and sources

BotOS is a self-hosted, single-user platform for delegating digital work to persistent AI agents. Each agent has its own workstation, instructions, memory, and application accounts. The user teaches an agent through conversation and supervised work, then approves reusable procedures for future runs.

This document combines the supplied PRD, this session's answers, and the prior brainstorming transcript the operator supplied for reuse. It describes the product and the prototype scope. It does not claim that infrastructure, provider integrations, or security controls have been implemented or tested.

BotOS remains general-purpose. Grocery ordering is a test scenario, not the first release's defining workflow. Individuals and enterprise users may operate a single-user installation; shared multi-user administration is outside the first scope.

## Chosen approach

The operator selected an agent-first experience, with Work as the second focus.

| Approach considered | Benefit | Trade-off |
| --- | --- | --- |
| Agent-first, selected | Matches the persistent digital-worker model; conversation and workstation access sit together | Needs an attention inbox and cross-agent work view to expose blockers |
| Work-first | Makes queues, results, and schedules easy to supervise | Gives agent identity and teaching less prominence |
| Workstation-first | Makes direct computer access prominent | Gives procedures, outcomes, and agent context less prominence |

## Product entities

| Entity | Definition and ownership |
| --- | --- |
| User | The human operator who configures access, approves procedure activation, and intervenes |
| Agent | A persistent digital worker with identity, instructions, private memory, permissions, and optional soul and heartbeat configuration |
| Model connection | Platform-managed access to a supported subscription, API key, or local inference endpoint; explicitly assignable to multiple agents |
| Workstation | A persistent Linux computing environment dedicated to one owning agent; includes applications, files, and signed-in sessions |
| Conversation | The place to request work, teach, correct, and discuss results |
| Procedure | Fixed, editable, versioned instructions with inputs, steps, rules, and stop conditions; private to an agent or in the shared library |
| Run | One execution of an ad hoc request or an approved procedure, with status, progress, result, and evidence |
| Session | One continuous interaction period; interruptions may require a later session to continue the same run |

An agent can change models between runs without changing its identity or losing its explicit saved memory. The product does not promise identical behavior across models or transfer of hidden model state. Available execution features depend on the selected integration.

## Teaching and reuse

1. The user starts through conversation and describes the work.
2. The agent operates its workstation while the user explains, watches, and corrects it.
3. After useful work, the agent can draft a reusable procedure. The draft separates variable inputs from reusable steps and rules.
4. The user edits and approves the procedure before activation. Agents may draft revisions, but cannot activate them.
5. Future runs use an approved version and the agent's separately granted action permissions.

The agent may adapt the mechanics of a step, such as locating a button after a layout change. It must not silently replace the procedure or change its business rules. Stop conditions and exceptions belong in the procedure. If the procedure does not cover a consequential deviation, the run asks for direction.

Procedure activation does not grant action authority. Sharing a procedure does not share the author's credentials, private memory, or workstation. Existing runs retain their approved procedure version when the user activates a revision.

The review interface should show inputs, steps, rules, stop conditions, and expected completion evidence. Completion evidence is a design recommendation to make review useful; the product must not equate an agent's success message with proof of an external result.

## Credentials, workstation ownership, and collaboration

Application credentials belong to the agent. Each newly created agent receives a dedicated workstation. Other agents cannot directly access its desktop or SSH interface. The human can take over.

Signed-in browser sessions and application files remain on the workstation, so agent isolation must include workstation access. Hiding passwords alone does not isolate account access.

Model connections live in platform settings. The user assigns them to agents explicitly; reusing a model connection does not merge agent memories or application accounts. The proposed access design keeps provider secrets out of agent workstations. Specific subscription authentication methods and provider compatibility need verification before implementation.

Collaboration is configurable per agent:

- Disabled.
- Approved collaborators only.
- Any agent in the installation.

Agents may request support autonomously within that setting. Helpers receive only the explicit handoff contents and work within their own access. A handoff grants no workstation access or additional action permission. The earlier discussion recommended approved collaborators as the default; that default is a proposal, while the configurable modes are confirmed.

## Permissions and human intervention

The operator requires enforceable action restrictions. BotOS must restrict execution paths where it cannot reliably prevent a forbidden action. A policy label or instruction to ask first is insufficient when an agent can bypass it through a shell or a signed-in application.

The agent performs supported steps, then requests human takeover for unsupported actions. If BotOS cannot isolate the supported steps from the forbidden capability, takeover starts earlier. An unrestricted shell or authenticated desktop cannot be presented as having fine-grained action restrictions without an actual enforcement mechanism.

Taking control pauses agent actions. Takeover is private by default: agent observation and recording stop. The user may explicitly enable teaching mode so the agent can observe a demonstration. Returning control is explicit. On handback, the agent inspects the permitted current state; private takeover does not erase files or signed-in sessions the user leaves behind.

The prototype must distinguish three decisions: approving procedure instructions, granting action permissions, and handing control back. A single generic Approve button must not imply all three.

## Execution, recovery, and resource lifecycle

Each agent has one active run. Additional requests queue. Different agents may run concurrently within host capacity.

User-visible run states are queued, running, needs attention, paused, completed, failed, and cancelled. Needs attention identifies the blocker and offers the relevant response, review, or takeover action.

After interruption, BotOS checks recorded progress and the application's current state before repeating an action. If an external action might have succeeded and BotOS cannot establish the outcome, it asks the user. It must not retry an uncertain external write blindly.

When agents wait for collaborators, BotOS detects circular waits and surfaces the problem. A helper request does not bypass the helper's queue or permissions.

Workstations stop when idle by default; each agent may instead use an always-on setting. Disk state persists. Work, schedules, and heartbeats can wake a stopped workstation. Restarting may require applications to relaunch or the user to authenticate again.

A workstation is not idle while an active run, a BotOS-managed background process, or human takeover requires it. A blocked run does not automatically qualify as idle. Provisioning and wake-up must respect host capacity and explain resource shortages.

A heartbeat checks for work and runs approved procedures within granted permissions. It cannot activate new procedures or expand access.

## Setup and infrastructure scope

The first deployment target is one local macOS or Linux host running persistent Linux workstations. The BotOS installer handles the underlying runtime and setup; users may need to grant system permissions. Users should not have to configure containers or Kubernetes.

Creating an agent provisions its workstation from a configurable resource preset. The suggested 1 CPU core, 4 GB RAM, and 16 GB storage are illustrative values, not validated minimums.

Kubernetes is the operator's proposed provisioning approach, not a finalized technical decision. Additional hosts and cloud capacity are later expansion. The implementation design must verify supported host versions and architectures, installation privileges, resource requirements, and isolation before making compatibility promises.

## Navigation and main screens

| Surface | Contents and primary actions |
| --- | --- |
| Agents, home | Agent identity, current activity, workstation state, and attention needed; create or open an agent |
| Agent workspace | Conversation and current run, workstation access, private procedures, memory, and agent configuration |
| Work | Cross-agent runs, queues, schedules, status filters, results, and completion evidence |
| Library | Shared procedures, drafts, approved versions, and revision review; agent-private procedures also appear within the agent workspace |
| Settings | Model connections, host capacity, installation health, and platform defaults |
| Attention inbox | Available throughout; collects questions, procedure activation reviews, permission requests, and takeover requests |

Agent settings include instructions, memory controls, model assignment, application credential references, action permissions, collaborators, heartbeat, workstation resources, and idle behavior. Sensitive values are not exposed in normal summaries.

The agent workspace should keep the conversation, current progress, and workstation access close together. The user should be able to discover blockers across the installation without opening each agent.

## Open Design scope

Produce a connected product prototype covering:

1. Agent home and agent creation, including model assignment and workstation resource settings.
2. An agent workspace showing a supervised teaching run and visible progress.
3. Saving a learned procedure, editing its draft, reviewing changes, and approving activation without granting permissions.
4. Work and run details, including a queued run, a blocker, and a completed result with evidence.
5. The attention inbox and private takeover with explicit teaching mode and handback.
6. Shared versus private procedures, agent collaboration settings, and reusable model connections.

Use generic, varied examples. A single shopping workflow must not dictate the navigation or terminology. Any illustrative data belongs only in the design prototype and does not represent live connected accounts or working enforcement.

The operator selected an expressive digital-worker aesthetic for BotOS. Explore distinct agent identities, visible activity, and a workstation feel while keeping permission and takeover controls legible. This selection takes precedence over the supplied runtime brief's Mission Control pixel styling. Do not import Mission Control's life-domain navigation or unrelated product rules into BotOS.

## Scenarios for reviewing the design

- Teach an agent a workflow, correct a step, and activate the resulting procedure without changing its action permissions.
- Assign a shared procedure to another agent and confirm that no credentials or private memory travel with it.
- Queue work behind an active run and show why an agent is waiting for a helper or host capacity.
- Take over privately, enable teaching mode deliberately, and return control explicitly.
- Recover a run after an uncertain submission and require reconciliation or human judgment before retrying.
- Show a safe partial workflow followed by takeover when the required action lacks an enforceable automation path.
- Change an agent's model connection for a later run while retaining its identity and saved context.

The imported grocery example checks configurable limits and blocking: repeat a saved basket on a schedule; ask about unavailable items; hold the whole order until the user replies; honor spending and delivery constraints. Automatic payment is a desired scenario only where BotOS can enforce the separately granted permission. Otherwise the agreed takeover fallback applies. A prototype must not imply that an NTUC integration or payment control has been validated.

## Boundaries before implementation

This design is ready to guide product prototyping once reviewed. It is not a complete engineering specification for an installer, isolation system, or agent runtime. Before implementation, dedicated technical work must establish permission enforcement, provider adapters, workstation lifecycle and recovery, secure storage, and installation support. Those choices cannot be proven by a visual prototype.

The original GitHub-star goal remains a distribution measure. Time saved, intervention frequency, and verifiable successful runs are proposed usefulness measures; numerical launch thresholds have not been agreed. Multi-user operation, mobile workstations, Windows/macOS guest workstations, CAPTCHA circumvention, voice, and unique agent network identities remain outside the initial scope.

## Operator-requested visual revision

Use the supplied GrokBot screenshot as a layout reference: a dark worker roster with search, worker avatars, latest-message snippets and timestamps; a main conversation pane with worker identity in its header; embedded computer activity; and a bottom message composer. Keep BotOS branding and original agent identities.

Add a toggleable live workstation pane beside the selected worker's conversation, with an expanded screen view. Add an All workstations overview showing every worker's workstation, current activity, latest status and update time. Selecting a tile opens the worker and its screen. Keep Work available for cross-agent runs; the workstation overview supplements it.

Screen connection state and run status are distinct. Show freshness and stale/disconnected states rather than presenting old imagery as live. Mask workstation previews during private takeover in both individual and overview views. These are proposed UI behavior details that preserve the already approved privacy model.

Prototype screen activity is illustrative playback, not live access to real machines. Preserve that distinction with a restrained prototype/playback indicator while making the intended real-time experience clear.
