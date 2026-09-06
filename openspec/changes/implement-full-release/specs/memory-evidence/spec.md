## ADDED Requirements

### Requirement: Private inspectable memory
The system SHALL support automatic private memory updates with source provenance and operator inspection, editing and deletion. Authorization SHALL precede retrieval into engine context.

#### Scenario: Agent requests another agent memory
- **WHEN** the information was not explicitly shared
- **THEN** retrieval denies it before constructing the model request

### Requirement: Forgetting and source exclusions
Deleting memory SHALL exclude linked historical sources and derived retrieval entries from subsequent agent retrieval without silently deleting retained operator history. Limits concerning already-sent context and independently supplied information SHALL be explained.

#### Scenario: Deleted memory remains in old history
- **WHEN** retrieval searches its historical source
- **THEN** the linked source is excluded from future agent context

### Requirement: Evidence retention
The system SHALL retain action logs, selected screenshots and result evidence until user deletion, with large files referenced by database metadata. Continuous video SHALL NOT be the default and private takeover SHALL remain unrecorded.

#### Scenario: Storage pressure occurs
- **WHEN** history consumes available space
- **THEN** the operator is notified without automatic history deletion
