#!/bin/sh
# The Makefile is the published interface: every routine task is a target, and
# CI runs one of them. These cases pin the wiring — that `make verify` really
# is the gate, and that the gate really does run the tests.
set -eu
. "$REPO_ROOT/tests/lib.sh"

# Replace a fixture's suite with a stub. Running the real suite from inside a
# test would recurse; a stub proves the wiring without the recursion.
stub_suite() {
	_fx=$1
	_exit=$2
	cat > "$_fx/scripts/test.sh" <<STUB
#!/bin/sh
printf 'stub suite ran\n'
exit $_exit
STUB
	chmod +x "$_fx/scripts/test.sh"
}

it "make help lists every target"
fx=$(fixture_new)
run_in "$fx" make help
assert_ok "$last_status" "make help"
for target in bootstrap verify check test clean; do
	assert_contains "$last_output" "$target" "make help lists $target"
done

it "make verify runs the gate"
fx=$(fixture_new)
run_in "$fx" make verify
assert_ok "$last_status" "make verify"
assert_contains "$last_output" "BotOS verify" "make verify"

it "make check is an alias for verify"
fx=$(fixture_new)
run_in "$fx" make check
assert_ok "$last_status" "make check"
assert_contains "$last_output" "BotOS verify" "make check"

it "make test runs the suite runner"
fx=$(fixture_new)
stub_suite "$fx" 0
run_in "$fx" make test
assert_ok "$last_status" "make test"
assert_contains "$last_output" "stub suite ran" "make test"

it "make test fails when the suite fails"
fx=$(fixture_new)
stub_suite "$fx" 1
run_in "$fx" make test
assert_fails "$last_status" "make test with a failing suite"

# The point of registering the suite in run_all(): one gate, not two.
it "make verify fails when the suite fails"
fx=$(fixture_new)
stub_suite "$fx" 1
last_output=$( cd "$fx" && BOTOS_SKIP_TESTS=0 make verify 2>&1 ) \
	&& last_status=0 || last_status=$?
assert_fails "$last_status" "verify with a failing suite"
assert_contains "$last_output" "stub suite ran" "verify with a failing suite"
assert_contains "$last_output" "test suite failed" "verify with a failing suite"

it "make verify runs the suite when it passes"
fx=$(fixture_new)
stub_suite "$fx" 0
last_output=$( cd "$fx" && BOTOS_SKIP_TESTS=0 make verify 2>&1 ) \
	&& last_status=0 || last_status=$?
assert_ok "$last_status" "verify with a passing suite"
assert_contains "$last_output" "stub suite ran" "verify with a passing suite"

it "make verify fails when the suite runner is not executable"
fx=$(fixture_new)
stub_suite "$fx" 0
chmod -x "$fx/scripts/test.sh"
last_output=$( cd "$fx" && BOTOS_SKIP_TESTS=0 make verify 2>&1 ) \
	&& last_status=0 || last_status=$?
assert_fails "$last_status" "verify with a non-executable runner"
assert_contains "$last_output" "missing or not executable" "verify with a non-executable runner"

it "the empty suite is treated as a failure, not a pass"
fx=$(fixture_new)
rm -f "$fx"/tests/test_*.sh
run_in "$fx" sh scripts/test.sh
assert_fails "$last_status" "empty suite"
assert_contains "$last_output" "must not be empty" "empty suite"

it "make clean succeeds"
fx=$(fixture_new)
run_in "$fx" make clean
assert_ok "$last_status" "make clean"

it "CI runs the same target a developer runs"
assert_contains "$(cat "$REPO_ROOT/.github/workflows/ci.yml")" \
	"run: make verify" "ci workflow"

finish
