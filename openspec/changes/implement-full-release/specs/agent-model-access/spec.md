## ADDED Requirements

### Requirement: Stable worker identity
The system SHALL separate persistent agent identity, instructions, private context and application accounts from replaceable model execution settings. Model changes SHALL take effect between runs.

#### Scenario: Model replaced
- **WHEN** the operator selects another supported model for an agent
- **THEN** future runs use it while explicit agent memory remains and active runs retain their settings

### Requirement: Four launch access modes
The first release SHALL support Claude subscription, Codex subscription, OpenAI BYOK and Anthropic BYOK through eligible supported interfaces. Every provider credential, including access tokens, SHALL remain outside workstations; only scoped BotOS capabilities may enter them.

#### Scenario: A candidate needs a provider token in the engine
- **WHEN** an integration requires a provider token in an engine inside its workstation
- **THEN** G1 fails for that candidate and release scope or engine placement is not silently changed

### Requirement: Connection failure and limits
The system SHALL permit explicit assignment of reusable model connections to agents without sharing application accounts or memory. It SHALL pause and notify on provider failure or configured execution-time/model-request limits, with no automatic provider fallback.

#### Scenario: Shared connection revoked
- **WHEN** a connection used by two agents is revoked
- **THEN** affected work pauses with a reason and neither agent receives another connection automatically
