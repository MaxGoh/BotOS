## ADDED Requirements

### Requirement: Persistent agent configuration
The system SHALL provide a Go host service with PostgreSQL persistence and a React/TypeScript/Vite dashboard served by Go. It SHALL allow creating and editing agent identity, instructions, model-connection assignments and resource configuration without requiring a working model connection.

#### Scenario: Agent edited and service restarted
- **WHEN** the operator saves an agent and restarts the Go service
- **THEN** the saved configuration is restored from PostgreSQL and unavailable workstations are shown honestly

### Requirement: Local operator boundary
The system SHALL serve the first-release operator interface locally without a separate BotOS login, reject unrelated-web-origin commands, and prevent workstation clients from acquiring operator authority. Agent APIs SHALL use scoped authority distinct from operator APIs.

#### Scenario: Workstation attempts an operator command
- **WHEN** an agent workload submits an operator-level configuration command
- **THEN** the command is denied even if network routing reaches the service

### Requirement: Database outage diagnostics
The system SHALL retain host diagnostics when the VM or PostgreSQL is unavailable and SHALL NOT acknowledge durable work until its transaction commits.

#### Scenario: Database fails during submission
- **WHEN** persistence fails before a request is committed
- **THEN** the request is not reported accepted and the dashboard explains the unavailable dependency
