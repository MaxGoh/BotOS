# Managed-host preflight

[Environment inventory](environment.json) records the actual agent box checked
on 2026-09-06. It is a Linux x86_64 container with no Docker, Podman, Lima,
Kubernetes CLI, QEMU, Wayland compositor or WayVNC available. `/dev/kvm` is absent
and the cgroup root is not writable by this process.

This preflight is insufficient to execute the approved managed-VM and desktop
isolation tests. Xvfb is available, but substituting it would not verify the
approved Wayland/private-takeover composition. No host installation was attempted.

Repeat the inventory on the intended disposable host before installation:

```bash
uname -sm
id
for executable in docker podman limactl kubectl qemu-system-x86_64 weston wayvnc Xvfb; do
  command -v "$executable" || true
done
if test -e /dev/kvm; then ls -l /dev/kvm; fi
if test -w /sys/fs/cgroup; then echo cgroup-writable; fi
```

Actual macOS and Linux host results must be recorded separately. Tool presence
alone is not proof that provisioning, resource limits or isolation work.
