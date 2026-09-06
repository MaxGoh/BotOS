## ADDED Requirements

### Requirement: Durable acceptance and queue
The system SHALL use stable request identifiers and transactional acceptance, allow one active run per agent, and retain queued, running, needs attention, paused, completed, failed and cancelled states separately from workload health.

#### Scenario: Duplicate request submitted
- **WHEN** two submissions use the same accepted request identifier
- **THEN** one logical run exists and the caller receives its durable identity

### Requirement: Fenced execution ownership
The system SHALL prevent replacement execution until the predecessor is stopped or independently fenced from acting. Lease expiry alone SHALL NOT authorize overlapping execution.

#### Scenario: Lease expires while old engine lives
- **WHEN** recovery attempts to start a replacement
- **THEN** the replacement cannot act until the old executor loses action authority

### Requirement: Outcome reconciliation
The system SHALL checkpoint progress, reconcile uncertain external effects and require outcome evidence for completion. It SHALL NOT replay an uncertain action or equate a successful process exit with task success.

#### Scenario: Response lost after external effect
- **WHEN** a remote service commits an action but its response is lost
- **THEN** the run reconciles or asks for attention instead of blindly repeating the action

### Requirement: Resumable events and cancellation
The system SHALL publish resumable run events, reject stale control commands and distinguish cancellation intent from confirmed executor shutdown. Cursor expiry SHALL trigger state resynchronization.

#### Scenario: Stale browser sends a command
- **WHEN** the command references an obsolete control generation
- **THEN** it is rejected and the client must refresh authoritative state
