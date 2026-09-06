# G3 — managed-host validation: blocked at preflight

[Environment evidence](../../experiments/managed-host/environment.json) records
Linux x86_64, no installed VM/container orchestration tools, no `/dev/kvm`, a
read-only cgroup mount and denied user namespace mapping. There is no connected
macOS test host. No supported-host provisioning was attempted.

[Results](G3-results.json) keep provisioning, restart, resources, mounts/network,
repair and macOS execution blocked. The box's existing Xvfb is not a substitute
for an isolated managed Linux VM running the proposed workstation stack.

Next integration requirement: a contributor-owned disposable macOS or Linux host
capable of virtualization and authorized runtime installation. Start with one
host to test the composition, then verify each advertised host/architecture.
Do not change this agent box's parent cluster or reuse its administrative access
as a BotOS isolation experiment.

The contributor workflow supersedes the earlier personal-host access request.
See [portable checks](CONTRIBUTING.md); no maintainer machine is required.
