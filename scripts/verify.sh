#!/bin/sh
# The BotOS gate. CI runs this via `make verify`; so should you, before
# handing work back.
#
# Adding a check: write a `check_<name>` function that calls `fail` for each
# problem it finds, then register it in `run_all`. Defining it in one place
# keeps the local run and the CI run identical.
set -eu

failures=0
checks_run=0

fail() {
	failures=$((failures + 1))
	printf '  FAIL  %s\n' "$*" >&2
}

start() {
	checks_run=$((checks_run + 1))
	printf '\n[%s]\n' "$1"
}

# Every file git knows about, plus new untracked files, minus anything
# gitignored — so the gate covers work that has not been committed yet.
tracked_files() {
	git ls-files --cached --others --exclude-standard
}

tracked_matching() {
	tracked_files | grep -E "$1" || true
}

# --- checks ---------------------------------------------------------------

check_required_files() {
	start "required foundation files"
	for f in \
		LICENSE README.md AGENTS.md CLAUDE.md CONTRIBUTING.md SECURITY.md \
		Makefile .gitignore .env.example \
		docs/DEPENDENCY-GRAPH.md docs/agdr/README.md \
		docs/agdr/AGDR-0000-template.md \
		scripts/bootstrap.sh scripts/verify.sh \
		.github/workflows/ci.yml
	do
		[ -f "$f" ] || fail "missing required file: $f"
	done
}

# The MIT grant is a hard guardrail: it must stay, and stay attributed.
check_license() {
	start "license integrity"
	if [ ! -f LICENSE ]; then
		fail "LICENSE is missing"
		return
	fi
	grep -q '^MIT License' LICENSE || fail "LICENSE is no longer the MIT License"
	grep -q 'Copyright (c) 2026 Max Goh' LICENSE || fail "LICENSE copyright line was altered"
}

check_shell_syntax() {
	start "shell script syntax"
	for f in $(tracked_matching '\.sh$'); do
		sh -n "$f" 2>/dev/null || fail "$f: shell syntax error"
		[ -x "$f" ] || fail "$f: not executable (chmod +x)"
		head -n 1 "$f" | grep -q '^#!' || fail "$f: missing shebang"
	done
	if command -v shellcheck >/dev/null 2>&1; then
		for f in $(tracked_matching '\.sh$'); do
			shellcheck -s sh "$f" || fail "$f: shellcheck reported issues"
		done
	else
		printf '  note  shellcheck not installed; skipped (optional)\n'
	fi
}

# Catch a credential before it reaches history. Patterns are deliberately
# narrow: a noisy secret check is one people learn to ignore.
check_secrets() {
	start "no committed secrets"
	pattern='BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|xox[abprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9]{32,}'
	for f in $(tracked_files); do
		# This script defines the patterns; scanning it would always match.
		[ "$f" = "scripts/verify.sh" ] && continue
		[ -f "$f" ] || continue
		if grep -Eq "$pattern" "$f" 2>/dev/null; then
			fail "$f: looks like it contains a credential — rotate it, then scrub"
		fi
	done
}

# .env.example documents variable *names*. A populated value there is either a
# leaked secret or a lie about the default.
check_env_example() {
	start ".env.example carries no real values"
	[ -f .env.example ] || return 0
	while IFS= read -r line; do
		case "$line" in
			''|'#'*) continue ;;
		esac
		value=${line#*=}
		[ -z "$value" ] && continue
		case "$value" in
			'<'*'>'|changeme|example|localhost*|http://localhost*) continue ;;
			*) fail ".env.example: '${line%%=*}' has a populated value; use <placeholder>" ;;
		esac
	done < .env.example
}

# A broken relative link is a dead end for the next agent reading the docs.
check_markdown_links() {
	start "relative markdown links resolve"
	for f in $(tracked_matching '\.md$'); do
		dir=$(dirname "$f")
		targets=$(grep -oE '\]\([^)]+\)' "$f" 2>/dev/null | sed 's/^](//; s/)$//' || true)
		for t in $targets; do
			case "$t" in
				http:*|https:*|mailto:*|'#'*) continue ;;
			esac
			t=${t%%#*}
			[ -z "$t" ] && continue
			[ -e "$dir/$t" ] || fail "$f: link target does not exist: $t"
		done
	done
}

check_trailing_whitespace() {
	start "no trailing whitespace"
	for f in $(tracked_matching '\.(md|sh|yml|yaml)$'); do
		if grep -nE ' +$' "$f" >/dev/null 2>&1; then
			fail "$f: trailing whitespace on line(s): $(grep -nE ' +$' "$f" | cut -d: -f1 | tr '\n' ' ')"
		fi
	done
}

# --- runner ---------------------------------------------------------------

run_all() {
	check_required_files
	check_license
	check_shell_syntax
	check_secrets
	check_env_example
	check_markdown_links
	check_trailing_whitespace
}

main() {
	printf 'BotOS verify\n'
	run_all
	printf '\n----------------------------------------\n'
	if [ "$failures" -eq 0 ]; then
		printf 'PASS  %s checks, 0 failures\n' "$checks_run"
		exit 0
	fi
	printf 'FAIL  %s checks, %s failure(s)\n' "$checks_run" "$failures" >&2
	exit 1
}

main "$@"
