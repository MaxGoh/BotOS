## ADDED Requirements

### Requirement: Managed persistent Linux workstations
The system SHALL manage one shared Linux VM and a dedicated Kubernetes cluster per installation, including a separate PostgreSQL system workload. Each agent SHALL own a persistent Linux workstation; other agents SHALL NOT directly access its desktop, shell or files.

#### Scenario: Helper offers assistance
- **WHEN** an authorized helper returns a result
- **THEN** the owner receives only the explicit handoff and retains sole agent control of its workstation

### Requirement: Capacity admission
The system SHALL reserve configured RAM and queue starts when capacity is insufficient. Setup SHALL suggest an adjustable total budget and constrain manual budgets to validated limits accounting for host, VM, cluster, database and broker overhead. Agent count SHALL depend on capacity rather than a fixed product cap.

#### Scenario: Insufficient memory reservation
- **WHEN** a queued agent needs more RAM than remains within the configured budget
- **THEN** the workstation does not start and the queue reports capacity as its reason

### Requirement: Persistence and idle policy
The system SHALL default to idle-stop with an always-on option. It SHALL preserve workstation storage on stop, wake for queued work when capacity permits, and keep the shared VM running while BotOS is enabled. Active runs, managed background jobs and human control SHALL prevent idle-stop.

#### Scenario: Idle workstation receives scheduled work
- **WHEN** an idle-stopped agent has admitted work
- **THEN** its persistent workstation starts and required connections become ready before execution

### Requirement: Storage and host grants
The system SHALL require approval for storage increases, avoid automatic file/history deletion, enforce actual storage limits and expose explicit per-agent host-folder read/write grants. It SHALL validate traversal, symlink and grant-revocation behavior.

#### Scenario: Folder grant revoked
- **WHEN** an agent attempts further access through a revoked folder grant or a symlink escaping it
- **THEN** the host boundary denies that access without granting another agent access

### Requirement: Network and management separation
Workstations SHALL have internet and host-reachable network access by default while remaining unable to access operator, cluster-admin, database and credential-store authority. Supported VPN behavior SHALL be measured.

#### Scenario: Reachable management endpoint
- **WHEN** an agent can route packets to a management service
- **THEN** network reachability does not grant administrative access

### Requirement: Explicit workstation retirement
The system SHALL distinguish agent identity, persistent storage and running workload lifetimes. Retirement or deletion SHALL require explicit operator intent and SHALL NOT silently erase persistent files when stopping or replacing a workload.

#### Scenario: Workload replaced
- **WHEN** a failed workload is replaced during reconciliation
- **THEN** its persistent contents and owner remain intact unless the operator explicitly requested deletion
