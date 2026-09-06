#!/bin/sh
set -eu
. "$REPO_ROOT/tests/lib.sh"

it 'runs a credential-free same-UID negative control'
run_in "$REPO_ROOT" sh scripts/feasibility.sh local
assert_ok "$last_status" 'local probe'
assert_contains "$last_output" 'OBSERVED: same-UID reader accessed the marker' 'negative control observation'
assert_contains "$last_output" 'NOT VALIDATED: workstation privacy or provider access' 'scope limit'

it 'rejects unknown modes instead of running a different experiment'
run_in "$REPO_ROOT" sh scripts/feasibility.sh unknown
assert_fails "$last_status" 'unknown mode'
assert_contains "$last_output" 'Usage:' 'usage diagnostic'

it 'does not mistake host inventory for a passed integration gate'
run_in "$REPO_ROOT" sh scripts/feasibility.sh host
if [ "$last_status" -ne 2 ]; then
 fail_case "expected incomplete-gate status 2, got $last_status"
fi
assert_contains "$last_output" 'NOT VALIDATED: G1/G2/G3' 'unexecuted gate diagnostic'
assert_not_contains "$last_output" 'PASS' 'inventory cannot pass a gate'
finish
