#!/bin/sh
# scripts/bootstrap.sh — the setup contract.
#
# Bootstrap installs nothing today (there is nothing to install), so what it
# owes a newcomer is an accurate answer: succeed when the toolchain is usable,
# and fail loudly, naming the tool, when it is not.
set -eu
. "$REPO_ROOT/tests/lib.sh"

it "succeeds and reports the toolchain when the required tools are present"
fx=$(fixture_new)
run_in "$fx" sh scripts/bootstrap.sh
assert_ok "$last_status" "bootstrap on a healthy box"
assert_contains "$last_output" "Bootstrap complete" "bootstrap on a healthy box"
assert_contains "$last_output" "git" "bootstrap on a healthy box"
assert_contains "$last_output" "make" "bootstrap on a healthy box"

it "exits non-zero and names what is missing when a required tool is absent"
fx=$(fixture_new)
# An empty PATH is the portable way to simulate a box without the toolchain;
# bootstrap uses only shell builtins, so it still runs and reports honestly.
last_output=$( cd "$fx" && PATH='' /bin/sh scripts/bootstrap.sh 2>&1 ) \
	&& last_status=0 || last_status=$?
assert_fails "$last_status" "bootstrap without a toolchain"
assert_contains "$last_output" "Bootstrap incomplete" "bootstrap without a toolchain"
assert_not_contains "$last_output" "Bootstrap complete" "bootstrap without a toolchain"
# Name each required tool, and pin the count: asserting only that *something*
# was missing would still pass if a tool were quietly downgraded to optional.
assert_contains "$last_output" "MISSING  git" "bootstrap without a toolchain"
assert_contains "$last_output" "MISSING  make" "bootstrap without a toolchain"
assert_contains "$last_output" "2 required tool(s) missing" "bootstrap without a toolchain"

it "points at the env template when no .env exists"
fx=$(fixture_new)
run_in "$fx" sh scripts/bootstrap.sh
assert_contains "$last_output" "cp .env.example .env" "env hint"

it "stays quiet about the env template once .env exists"
fx=$(fixture_new)
printf 'EXAMPLE=1\n' > "$fx/.env"
run_in "$fx" sh scripts/bootstrap.sh
assert_ok "$last_status" "bootstrap with .env present"
assert_not_contains "$last_output" "cp .env.example .env" "bootstrap with .env present"

it "reports shellcheck as optional rather than required"
fx=$(fixture_new)
run_in "$fx" sh scripts/bootstrap.sh
assert_contains "$last_output" "shellcheck" "shellcheck is optional"
assert_ok "$last_status" "shellcheck is optional"

finish
