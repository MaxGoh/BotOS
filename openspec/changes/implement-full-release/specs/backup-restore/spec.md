## ADDED Requirements

### Requirement: Encrypted recoverable backups
The system SHALL support manual and recurring encrypted backups of records and workstation contents to chosen folders, external drives or mounted storage. It SHALL securely retain material for unattended encryption and provide a separately saved recovery key, with no plaintext fallback.

#### Scenario: Secure store unavailable
- **WHEN** a scheduled backup cannot obtain encryption material
- **THEN** backup fails visibly without writing a plaintext substitute

### Requirement: Consistent capture and retention
The system SHALL coordinate safe pauses for consistent database/workstation capture, defer during human takeover or unsafe interruption, validate manifests/integrity and retain every successful backup until user deletion.

#### Scenario: Backup destination fills
- **WHEN** capture cannot finish
- **THEN** the new backup is not reported recoverable and prior valid backups remain intact

### Requirement: Safe restore and reconnect
Backups SHALL exclude provider secrets. Restore SHALL verify compatibility, require model reconnection, hold runs/schedules for review and surface older-memory resurrection before retrieval resumes.

#### Scenario: Older backup restored
- **WHEN** the restored state predates a memory deletion and contains pending runs
- **THEN** the operator reviews the restored context and work before retrieval or execution resumes
