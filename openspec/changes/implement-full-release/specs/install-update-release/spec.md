## ADDED Requirements

### Requirement: Managed installation and supported hosts
The installer SHALL own prerequisite and dedicated-cluster setup on validated macOS/Linux hosts, start the service after OS login, preserve user data during repair and report unsupported hosts. Closing the browser SHALL NOT stop background service operation.

#### Scenario: Installation interrupted
- **WHEN** setup fails after partial VM creation
- **THEN** a retry identifies partial state and repairs or safely reports it without destroying existing data

### Requirement: Approved recoverable updates
Updates SHALL require approval, a verified recovery backup, compatible component/schema versions and safe maintenance. Human takeover SHALL defer updates; failed migration or health checks SHALL leave execution paused with a recovery route.

#### Scenario: Migration fails
- **WHEN** an approved update fails after modifying the database
- **THEN** execution remains paused and database recovery is distinguished from binary rollback

### Requirement: Open-source verification and release gates
The project SHALL provide contributor-owned verification without maintainer credentials, keep fixtures outside production paths and publish supported versions with G1–G5 evidence. Missing experiments SHALL NOT count as passes. All four model access modes SHALL pass before claiming the full release.

#### Scenario: Only local checks pass
- **WHEN** portable CI is green but takeover or subscription tests are missing
- **THEN** the full release is not declared validated
