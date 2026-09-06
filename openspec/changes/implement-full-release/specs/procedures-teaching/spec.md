## ADDED Requirements

### Requirement: Conversation-led procedures
The system SHALL support ad hoc requests and agent-operated teaching with human corrections, producing editable procedures with steps, inputs, rules and stop conditions. Saving a procedure SHALL NOT be required for an ad hoc run.

#### Scenario: Teaching finishes
- **WHEN** the operator and agent complete a useful workflow
- **THEN** the agent can draft a reusable procedure without activating it

### Requirement: Version approval and libraries
The system SHALL provide agent-private and shared procedure libraries. Agents may draft revisions; only the operator SHALL activate immutable versions. Active runs SHALL retain their selected version.

#### Scenario: Revision activated during a run
- **WHEN** the operator approves a new procedure version
- **THEN** future runs may use it while the existing run retains its original version

### Requirement: Instructions separate from authority
Procedure activation and sharing SHALL NOT grant action permissions, credentials, private context or workstation access. An agent may adapt execution mechanics but SHALL require approval for procedural changes.

#### Scenario: Shared procedure assigned
- **WHEN** another agent uses a shared procedure
- **THEN** it supplies its own authorized inputs, permissions and accounts
