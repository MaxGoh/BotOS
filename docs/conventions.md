# Repository conventions

## Scope and structure

Keep BotOS independently understandable and runnable. Its foundation borrows documentation practices from Mission Control, not Mission Control's life-domain services, deployment assumptions, or product-specific policy defaults.

Keep agent instructions in root `AGENTS.md`; `CLAUDE.md` points to it. Add narrower instructions only when a directory needs additional rules.

Introduce application directories and dependency managers with the architecture decision that needs them. Do not pre-create microservices, an empty workspace, or a Kubernetes deployment before choosing the implementation boundary.

## Decisions and dependencies

Use the agDR template for each logical change covered by `AGENTS.md`. Records are append-only and use a daily three-digit sequence. Explain superseding decisions in a new record.

Update `DEPENDENCY-GRAPH.md` when implemented dependencies or routes change. Record planned architecture in design documents until it exists.

## Verification

Choose checks that exercise observable behavior and failures at boundaries. Report skips and unavailable infrastructure as limitations, not passes. Keep prototype fixtures and runtime tests separate from production data paths.

When a task involves scripts or tools, verify the expected artifact or external outcome as well as the process exit status. A completed model response can contain a question or error instead of the requested work.

## Security and generated artifacts

Application credentials belong to the agent; model access is a separately assigned connection. Never store secrets or signed-in browser profiles in the repository.

Preserve approved design artifacts and their provenance. Prototype screen playback is illustrative and must remain outside production routes. Introduce live data only through tested integrations.

## Publishing

Follow the operator's active publishing contract. Do not commit, push, or create a PR yourself when the session harness owns those actions. Include the relevant verification and decision record in the prepared change.
