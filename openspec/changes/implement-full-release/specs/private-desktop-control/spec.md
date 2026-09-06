## ADDED Requirements

### Requirement: Restricted execution and managed applications
The system SHALL separate managed applications, restricted engine/scripts and trusted control brokerage. Agents SHALL NOT have unrestricted root or unrestricted display/debug sockets. Applications outside the managed catalog SHALL require review.

#### Scenario: Agent requests an unsupported application
- **WHEN** installation cannot satisfy the declared takeover boundary
- **THEN** installation remains pending review and the boundary is not weakened

### Requirement: Independently confirmed private takeover
The system SHALL stop new agent actions, revoke input and observation, close channels, suspend agent-controlled execution and clear agent-facing buffers before enabling private human control. It SHALL block private-mode confirmation when any required revocation cannot be established.

#### Scenario: Recorder remains active
- **WHEN** an agent-created recorder survives a takeover request
- **THEN** human private input remains disabled and the failed isolation step is reported

### Requirement: Explicit teaching and handback
Takeover SHALL be private by default. Teaching SHALL explicitly enable selected observation while agent input stays disabled. Human disconnect or ambiguous service recovery SHALL leave the agent paused; resumption SHALL require explicit handback and reconciliation.

#### Scenario: Operator disconnects during takeover
- **WHEN** the browser connection closes before handback
- **THEN** the agent cannot resume input or observation merely because the connection ended

### Requirement: Application permission honesty
The system SHALL enforce its external boundaries and expose only action restrictions it can enforce. It SHALL NOT present arbitrary in-application business rules as guaranteed controls; unsupported actions SHALL require human intervention where separation is enforceable.

#### Scenario: Application cannot enforce a proposed restriction
- **WHEN** a user configures a restriction unsupported by available execution paths
- **THEN** the interface explains the limitation instead of claiming the action is blocked
