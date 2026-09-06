# G2 — private takeover: blocked before assembled experiment

The current box cannot run the approved isolation composition. User namespace
creation fails, cgroups are read-only, and the Wayland/VNC and container runtime
components are absent. [Inventory](../../experiments/managed-host/environment.json).
All D1–D7 cases remain unexecuted in [the results](G2-results.json).

## Reviewed direction

A managed desktop and browser must be protected from the agent's engine and
arbitrary scripts through enforceable process, filesystem and socket boundaries.
The broker owns all agent capture/input grants and revokes them before confirming
private control; the operator path remains usable.

WayVNC documents support for headless wlroots-based compositor sessions and
explicitly excludes GNOME, KDE and Weston. A compatible compositor plus WayVNC
is a candidate, not an accepted tested stack. Source checked 2026-09-06:
[WayVNC upstream](https://github.com/any1/wayvnc).

## Specialist findings not accepted as proof

The research specialist proposed labwc/WayVNC, separate channels and browser
policy restrictions. None was exercised here. Its report also contained unsafe
fallbacks; they are rejected:

- Removing display or D-Bus environment variables does not revoke access to a
  discoverable socket. Tests must attempt actual connections.
- A directory owned by the same UID as arbitrary agent code does not isolate
  that code through mode 0700. Use distinct enforced identities/mount visibility.
- A snapshot of PIDs followed by SIGSTOP is not proof that all descendant or
  racing background execution is stopped. Require the tested supervision and
  fencing mechanism specified by the architecture.
- A pipe transport alone cannot remove scripts already injected into a browser.
  Browser profile modifications, debugging, extensions and other persistence
  paths must be prevented or shown unable to observe private interaction.
- Force-reloading the page or deleting application service workers is not an
  approved substitute for preserving the interactive session during takeover.
- A claim of an empirical kernel test without its command output and artifact
  is not accepted as observed evidence in this gate.

The report's proposed no-network engine also conflicts with the approved network
policy and is not adopted. A missing environment variable, refused connection to
one conventional port, or hidden preview does not establish takeover privacy.

## Next required execution

On a disposable host, assemble the pinned managed desktop, restricted engine and
broker; enumerate identities, mounts, process visibility and all capture/input
channels. Run D1–D7 from [the plan](../plans/feasibility.md), including persistent
browser instrumentation and stale connections. No privacy claim is passed until
those actual adversarial tests succeed.

## Local negative control

A same-UID child with an empty environment successfully read a controlled marker
inside a 0700 directory and 0600 file. This confirms that the suggested fallback
does not isolate files. It does not test the intended separated runtime.
[Observed evidence](../../experiments/private-takeover/same-uid-negative-control.json).
