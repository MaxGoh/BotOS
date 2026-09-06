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
		docs/BUILD.md docs/conventions.md \
		docs/DEPENDENCY-GRAPH.md docs/agdr/README.md \
		docs/agdr/AGDR-0000-template.md \
		docs/design/product-design.md \
		docs/design/approved/README.md \
		docs/design/approved/manifest.json \
		docs/design/approved/verification.json \
		docs/design/approved/prototype.html \
		docs/design/approved/conversation.png \
		docs/design/approved/workstations.png \
		scripts/bootstrap.sh scripts/verify.sh scripts/test.sh \
		.github/workflows/ci.yml
	do
		[ -f "$f" ] || fail "missing required file: $f"
	done
}

# One instruction source. CLAUDE.md must stay a *relative* symlink to
# AGENTS.md — a regular copy is how the two silently diverge.
check_claude_symlink() {
	start "CLAUDE.md is a relative symlink to AGENTS.md"
	if [ ! -L CLAUDE.md ]; then
		fail "CLAUDE.md is not a symlink; it must link to AGENTS.md"
		return
	fi
	target=$(readlink CLAUDE.md)
	[ "$target" = "AGENTS.md" ] || \
		fail "CLAUDE.md points at '$target'; expected the relative target AGENTS.md"
	[ -f AGENTS.md ] || fail "CLAUDE.md symlink target AGENTS.md does not exist"
}

sha256_of() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | cut -d' ' -f1
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | cut -d' ' -f1
	else
		printf ''
	fi
}

# The approved prototype is a provenance artifact. If its bytes change, the
# manifest hash no longer describes what the operator approved.
check_approved_design() {
	start "approved design matches its manifest"
	manifest=docs/design/approved/manifest.json
	html=docs/design/approved/prototype.html
	if [ ! -f "$manifest" ] || [ ! -f "$html" ]; then
		fail "approved design artifacts are missing"
		return
	fi
	expected=$(grep -o '"prototypeSha256"[[:space:]]*:[[:space:]]*"[0-9a-f]*"' "$manifest" \
		| sed 's/.*"\([0-9a-f]*\)"$/\1/')
	if [ -z "$expected" ]; then
		fail "$manifest: no prototypeSha256 recorded"
		return
	fi
	actual=$(sha256_of "$html")
	if [ -z "$actual" ]; then
		printf '  note  no sha256 tool available; hash check skipped\n'
		return
	fi
	[ "$actual" = "$expected" ] || \
		fail "$html: sha256 $actual does not match manifest $expected — approved snapshots are immutable; add a new version instead"

	expected_bytes=$(grep -o '"prototypeBytes"[[:space:]]*:[[:space:]]*[0-9]*' "$manifest" \
		| grep -o '[0-9]*$')
	if [ -n "$expected_bytes" ]; then
		actual_bytes=$(wc -c < "$html" | tr -d ' ')
		[ "$actual_bytes" = "$expected_bytes" ] || \
			fail "$html: $actual_bytes bytes, manifest records $expected_bytes"
	fi
}

# Records are append-only and dated. A misnamed record does not sort into the
# log and is easy to miss when reconstructing a decision.
check_agdr_naming() {
	start "decision records are named correctly"
	for f in $(tracked_matching '^docs/agdr/.*\.md$'); do
		base=${f##*/}
		case "$base" in
			README.md|AGDR-0000-template.md) continue ;;
		esac
		printf '%s' "$base" \
			| grep -Eq '^AGDR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}-[a-z0-9-]+\.md$' || \
			fail "$f: expected AGDR-YYYY-MM-DD-NNN-short-title.md"
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
		# -x follows sourced files. Without it a helper library looks like a
		# pile of undefined variables to shellcheck, and the scripts that
		# source it fail the gate for no real reason.
		for f in $(tracked_matching '\.sh$'); do
			shellcheck -s sh -x "$f" || fail "$f: shellcheck reported issues"
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

# A skill the harness cannot load is worse than no skill: it looks like the
# workflow is documented when nothing will ever read it. Frontmatter `name`
# and `description` are what make a skill discoverable, and the name has to
# match the directory the loader found it in.
check_skills() {
	start "agent skills are loadable"
	[ -d .claude/skills ] || {
		printf '  note  no .claude/skills directory; skipped\n'
		return 0
	}
	found=0
	for dir in .claude/skills/*/; do
		[ -d "$dir" ] || continue
		found=$((found + 1))
		name=$(basename "$dir")
		manifest="${dir}SKILL.md"
		if [ ! -f "$manifest" ]; then
			fail ".claude/skills/$name: has no SKILL.md"
			continue
		fi
		# Frontmatter is the block between the first two `---` lines.
		front=$(awk 'NR==1 && $0 != "---" { exit } NR>1 && $0 == "---" { exit } NR>1' "$manifest")
		declared=$(printf '%s\n' "$front" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)
		if [ -z "$declared" ]; then
			fail ".claude/skills/$name: frontmatter is missing 'name'"
		elif [ "$declared" != "$name" ]; then
			fail ".claude/skills/$name: frontmatter name '$declared' does not match its directory"
		fi
		printf '%s\n' "$front" | grep -q '^description:[[:space:]]*[^[:space:]]' \
			|| fail ".claude/skills/$name: frontmatter is missing 'description'"
	done
	[ "$found" -gt 0 ] || printf '  note  .claude/skills exists but is empty\n'
}

# The test suite is part of the gate, so `make verify` remains the one command
# to run. scripts/test.sh executes *this* script inside scratch copies of the
# repo; BOTOS_SKIP_TESTS is how those nested runs avoid re-entering the suite.
check_tests() {
	start "test suite"
	if [ "${BOTOS_SKIP_TESTS:-0}" = "1" ]; then
		printf '  note  nested verify run; suite skipped by BOTOS_SKIP_TESTS\n'
		return 0
	fi
	if [ ! -x scripts/test.sh ]; then
		fail "scripts/test.sh is missing or not executable"
		return 0
	fi
	./scripts/test.sh || fail "test suite failed (output above)"
}

# --- runner ---------------------------------------------------------------

run_all() {
	check_required_files
	check_claude_symlink
	check_license
	check_approved_design
	check_agdr_naming
	check_shell_syntax
	check_secrets
	check_env_example
	check_markdown_links
	check_trailing_whitespace
	check_skills
	# Last: the static checks above are fast, and a developer should see a
	# typo'd link before waiting on the suite.
	check_tests
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
