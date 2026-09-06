#!/bin/sh
# The BotOS test suite.
#
# Each tests/test_*.sh is a standalone POSIX shell program that sources
# tests/lib.sh and exits non-zero if any case fails. `make verify` runs this
# script, so a green suite locally means a green suite in CI.
#
# BOTOS_SKIP_TESTS is exported here because the tests run scripts/verify.sh
# inside scratch copies of this repo. verify.sh runs this suite; without the
# guard, each nested verify would start the suite again, forever.
set -eu

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
export REPO_ROOT
export BOTOS_SKIP_TESTS=1

files_run=0
files_failed=0

printf 'BotOS test suite\n'

for f in "$REPO_ROOT"/tests/test_*.sh; do
	[ -f "$f" ] || continue
	files_run=$((files_run + 1))
	printf '\n[%s]\n' "${f#"$REPO_ROOT"/}"
	if ! sh "$f"; then
		files_failed=$((files_failed + 1))
	fi
done

printf '\n----------------------------------------\n'

# An empty suite passing would be worse than no suite: it reports green while
# testing nothing.
if [ "$files_run" -eq 0 ]; then
	printf 'FAIL  no test files found in tests/ — the suite must not be empty\n' >&2
	exit 1
fi

if [ "$files_failed" -eq 0 ]; then
	printf 'PASS  %s test file(s), 0 failures\n' "$files_run"
	exit 0
fi

printf 'FAIL  %s test file(s), %s with failures\n' "$files_run" "$files_failed" >&2
exit 1
