## ADDED Requirements

### Requirement: Agent-first navigation
The dashboard SHALL provide Agents as its home, Work for cross-agent supervision, shared Library, Settings and a persistent attention inbox. Agent views SHALL expose conversation, workstation, procedures, memory and configuration.

#### Scenario: Agent is blocked
- **WHEN** a run requires human judgment
- **THEN** the global inbox identifies the owning agent, reason and available intervention

### Requirement: Live desktop and fleet view
The system SHALL provide interactive selected-workstation viewing and timestamped lower-rate fleet previews with latest activity and stale/disconnected states. Wayland/noVNC are candidates, not mandatory unverified implementations.

#### Scenario: Preview stops updating
- **WHEN** a workstation stream disconnects
- **THEN** the preview is visibly stale or disconnected instead of appearing live

### Requirement: Privacy across viewing paths
Private takeover SHALL prevent private frames reaching agent capture, stored screenshots or fleet previews while preserving the operator connection.

#### Scenario: Fleet page open during takeover
- **WHEN** the operator types on a private workstation
- **THEN** other observation paths display masked state and retain no private-period frames
