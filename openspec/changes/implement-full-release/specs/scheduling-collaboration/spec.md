## ADDED Requirements

### Requirement: Normal scheduling and expiry
During normal operation the system SHALL queue every scheduled occurrence, enforce one active run per agent, and skip expired occurrences with a recorded reason.

#### Scenario: Queue entry expires
- **WHEN** an occurrence reaches admission after expiry
- **THEN** it is skipped with a reason rather than executed

### Requirement: Downtime catch-up
After downtime the system SHALL consider only the latest missed occurrence within expiry, preserving occurrences already durably queued before downtime.

#### Scenario: Several ticks missed
- **WHEN** the host returns after several scheduled times
- **THEN** only the latest unqueued missed occurrence is considered, while the existing queue is preserved

### Requirement: Constrained heartbeat
Heartbeats SHALL check for work and initiate only approved procedures under existing permissions and execution/resource limits.

#### Scenario: Heartbeat finds an unapproved draft
- **WHEN** the draft matches a possible task
- **THEN** the heartbeat does not activate or execute the draft

### Requirement: Explicit-context collaboration
The system SHALL offer disabled, authorized-collaborators-only and any-agent collaboration modes. Helpers SHALL receive only explicit handoff context and use their own queue and authority. Circular waits SHALL become visible blockers.

#### Scenario: Agents wait on each other
- **WHEN** collaboration creates a wait cycle
- **THEN** the cycle is detected and shown as a blocker rather than waiting indefinitely
