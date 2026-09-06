#!/bin/sh
# Contributor probes only: no credentials, model requests or installation.
set -eu

case "${1:-}" in
 local)
  botos_probe_dir=$(mktemp -d "${TMPDIR:-/tmp}/botos-probe.XXXXXX")
  trap 'rm -rf "$botos_probe_dir"' EXIT
  trap 'exit 1' INT TERM
  chmod 700 "$botos_probe_dir"
  printf '%s' 'botos-controlled-marker' > "$botos_probe_dir/marker"
  chmod 600 "$botos_probe_dir/marker"
  # Run an actual child with an empty environment, not a simulated reader.
  observed=$(env -i /bin/sh -c 'cat "$1"' sh "$botos_probe_dir/marker")
  if [ "$observed" != 'botos-controlled-marker' ]; then
   printf '%s\n' 'Unexpected negative-control result: inspect host restrictions.' >&2
   exit 1
  fi
  printf '%s\n' 'OBSERVED: same-UID reader accessed the marker' \
   'File modes and an empty environment alone do not isolate agent code.' \
   'NOT VALIDATED: workstation privacy or provider access'
  ;;
 host)
  printf 'Host: %s %s\n' "$(uname -s)" "$(uname -m)"
  for tool in limactl kubectl; do
   if command -v "$tool" >/dev/null 2>&1; then
    printf 'AVAILABLE: %s\n' "$tool"
   else
    printf 'MISSING: %s (required for managed-host experiments)\n' "$tool"
   fi
  done
  case $(uname -s) in
   Linux)
    if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
     printf '%s\n' 'AVAILABLE: accessible /dev/kvm'
    else
     printf '%s\n' 'MISSING: accessible /dev/kvm; accelerated VM execution unverified'
    fi
    ;;
   Darwin) printf '%s\n' 'REQUIRED: verify Apple virtualization support through the managed-VM experiment' ;;
   *) printf '%s\n' 'UNSUPPORTED: host is outside the macOS/Linux candidate matrix' ;;
  esac
  printf '%s\n' 'NOT VALIDATED: G1/G2/G3; inventory does not run integration experiments.'
  exit 2
  ;;
 *) printf '%s\n' 'Usage: scripts/feasibility.sh local|host' >&2; exit 64 ;;
esac
