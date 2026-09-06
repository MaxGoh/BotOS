#!/bin/sh
# Assertions and fixture helpers for the BotOS test suite.
#
# Sourced by every tests/test_*.sh; scripts/test.sh is the entry point and is
# the only supported way to run these files (it exports REPO_ROOT and the
# recursion guard they depend on).
#
# A *fixture* is a throwaway git repo holding a copy of the current working
# tree. A test mutates one thing in it and asserts that the gate notices. That
# is the whole trick: the checks are tested against a real repo layout rather
# than against a mock of one, so a check that only appears to work fails here.
set -eu

: "${REPO_ROOT:?tests must be run through scripts/test.sh}"

tests_run=0
tests_failed=0
case_name='(none)'

TESTS_TMP=$(mktemp -d "${TMPDIR:-/tmp}/botos-tests.XXXXXX")
trap 'rm -rf "$TESTS_TMP"' EXIT
trap 'rm -rf "$TESTS_TMP"; exit 1' INT TERM

# --- reporting ------------------------------------------------------------

it() {
	case_name=$1
	tests_run=$((tests_run + 1))
	printf '  %s\n' "$case_name"
}

fail_case() {
	tests_failed=$((tests_failed + 1))
	printf '    FAIL  %s: %s\n' "$case_name" "$*" >&2
}

# Dump captured output under a failure. Without it, a failing assertion tells
# you what did not happen but not what did.
show() {
	printf '%s\n' "$1" | sed 's/^/      | /' >&2
}

finish() {
	if [ "$tests_failed" -eq 0 ]; then
		printf '  ok    %s case(s)\n' "$tests_run"
		exit 0
	fi
	printf '  FAIL  %s of %s case(s)\n' "$tests_failed" "$tests_run" >&2
	exit 1
}

# --- assertions -----------------------------------------------------------

assert_ok() {
	if [ "$1" -ne 0 ]; then
		fail_case "$2: expected exit status 0, got $1"
		show "${last_output:-}"
	fi
}

assert_fails() {
	if [ "$1" -eq 0 ]; then
		fail_case "$2: expected a non-zero exit status, got 0"
		show "${last_output:-}"
	fi
}

assert_contains() {
	case $1 in
		*"$2"*) return 0 ;;
	esac
	fail_case "$3: output did not contain '$2'"
	show "$1"
}

assert_not_contains() {
	case $1 in
		*"$2"*)
			fail_case "$3: output unexpectedly contained '$2'"
			show "$1"
			;;
	esac
}

# --- fixtures -------------------------------------------------------------

# A copy of the working tree (tracked + untracked, minus ignored) as its own
# git repo, so verify.sh's `git ls-files` sees the file set a real checkout
# would. Uncommitted work is included on purpose: the gate is meant to cover
# changes before they are committed, so the tests must too.
#
# `cp -P` is load-bearing: CLAUDE.md is a symlink to AGENTS.md, and without -P
# cp copies what it points at. The fixture would then hold a regular file and
# check_claude_symlink would fail in every case for a reason no case is about.
fixture_new() {
	_dir=$(mktemp -d "$TESTS_TMP/fixture.XXXXXX")
	( cd "$REPO_ROOT" && git ls-files --cached --others --exclude-standard ) \
	| while IFS= read -r _f; do
		mkdir -p "$_dir/$(dirname "$_f")"
		cp -Pp "$REPO_ROOT/$_f" "$_dir/$_f"
	done
	git -C "$_dir" init -q
	printf '%s\n' "$_dir"
}

# Rewrite a file through sed without relying on a non-POSIX `sed -i`.
edit_file() {
	_target=$1
	_expr=$2
	sed "$_expr" "$_target" > "$_target.edited"
	mv "$_target.edited" "$_target"
}

# Run a command inside a fixture, capturing status and merged output.
# Results land in $last_status / $last_output for the assertions above.
# shellcheck disable=SC2034  # both are read by the tests/*.sh that source this
run_in() {
	_dir=$1
	shift
	last_output=$( cd "$_dir" && "$@" 2>&1 ) && last_status=0 || last_status=$?
}

# The common case: run the gate inside a fixture.
run_verify() {
	run_in "$1" sh scripts/verify.sh
}
