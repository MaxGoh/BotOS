#!/bin/sh
# Every check in scripts/verify.sh, proved to fire.
#
# A check that has never failed is a check nobody knows works. Each case below
# breaks exactly one thing in a scratch copy of the repo and asserts that the
# gate reports it, with a control case proving an untouched copy still passes.
set -eu
. "$REPO_ROOT/tests/lib.sh"

# Credential shapes are assembled at runtime rather than written literally:
# a literal token in this file would trip check_secrets against the suite
# itself, and the fix for that would be an exemption that hides real leaks.
secret_shape() {
	case $1 in
		aws)    printf 'AKIA%s\n' 'IOSFODNN7EXAMPLE' ;;
		github) printf 'gh%s_%s\n' 'p' '0123456789abcdefghijklmn' ;;
		pem)    printf -- '-----BEGIN RSA %s KEY-----\n' 'PRIVATE' ;;
		openai) printf 'sk-%s\n' 'abcdefghijklmnopqrstuvwxyz0123456789' ;;
		*)      printf 'unknown shape: %s\n' "$1" >&2; return 1 ;;
	esac
}

# --- control --------------------------------------------------------------

it "passes on an unmodified working tree"
fx=$(fixture_new)
run_verify "$fx"
assert_ok "$last_status" "control fixture"
assert_contains "$last_output" "0 failures" "control fixture"

# --- check_required_files -------------------------------------------------

it "fails when a required foundation file is missing"
fx=$(fixture_new)
rm "$fx/AGENTS.md"
run_verify "$fx"
assert_fails "$last_status" "missing AGENTS.md"
assert_contains "$last_output" "missing required file: AGENTS.md" "missing AGENTS.md"

it "fails when the test runner is missing"
fx=$(fixture_new)
rm "$fx/scripts/test.sh"
run_verify "$fx"
assert_fails "$last_status" "missing scripts/test.sh"
assert_contains "$last_output" "missing required file: scripts/test.sh" "missing scripts/test.sh"

# --- check_claude_symlink -------------------------------------------------

it "fails when CLAUDE.md is a regular file instead of a symlink"
fx=$(fixture_new)
rm "$fx/CLAUDE.md"
printf '# BotOS\n\nA copy, not a link.\n' > "$fx/CLAUDE.md"
run_verify "$fx"
assert_fails "$last_status" "CLAUDE.md copied"
assert_contains "$last_output" "CLAUDE.md is not a symlink" "CLAUDE.md copied"

it "fails when CLAUDE.md points somewhere other than AGENTS.md"
fx=$(fixture_new)
rm "$fx/CLAUDE.md"
ln -s README.md "$fx/CLAUDE.md"
run_verify "$fx"
assert_fails "$last_status" "CLAUDE.md mistargeted"
assert_contains "$last_output" "expected the relative target AGENTS.md" "CLAUDE.md mistargeted"

# The control case only proves the symlink survives if the fixture copies it as
# one. If cp ever stops preserving links, this is the case that says so.
it "carries CLAUDE.md into the fixture as a symlink"
fx=$(fixture_new)
if [ -L "$fx/CLAUDE.md" ]; then
	:
else
	fail_case "fixture symlink: CLAUDE.md was dereferenced by fixture_new"
fi

# --- check_agdr_naming ----------------------------------------------------

it "fails on a decision record with a malformed name"
fx=$(fixture_new)
cp -p "$fx/docs/agdr/AGDR-0000-template.md" "$fx/docs/agdr/notes-about-things.md"
run_verify "$fx"
assert_fails "$last_status" "malformed AGDR name"
assert_contains "$last_output" "expected AGDR-YYYY-MM-DD-NNN-short-title.md" "malformed AGDR name"

it "leaves the template and README out of the naming rule"
fx=$(fixture_new)
run_verify "$fx"
assert_not_contains "$last_output" "AGDR-0000-template.md: expected" "AGDR exemptions"

# --- check_approved_design ------------------------------------------------

it "fails when the approved prototype no longer matches its manifest hash"
fx=$(fixture_new)
printf '<!-- edited after approval -->\n' >> "$fx/docs/design/approved/prototype.html"
run_verify "$fx"
assert_fails "$last_status" "prototype edited"
assert_contains "$last_output" "approved snapshots are immutable" "prototype edited"

it "fails when the manifest records no prototype hash"
fx=$(fixture_new)
edit_file "$fx/docs/design/approved/manifest.json" 's/"prototypeSha256"/"wasPrototypeSha256"/'
run_verify "$fx"
assert_fails "$last_status" "manifest hash removed"
assert_contains "$last_output" "no prototypeSha256 recorded" "manifest hash removed"

# --- check_license --------------------------------------------------------

it "fails when LICENSE is no longer the MIT License"
fx=$(fixture_new)
edit_file "$fx/LICENSE" '1s/.*/Apache License/'
run_verify "$fx"
assert_fails "$last_status" "relicensed"
assert_contains "$last_output" "no longer the MIT License" "relicensed"

it "fails when the LICENSE copyright attribution is altered"
fx=$(fixture_new)
edit_file "$fx/LICENSE" 's/Max Goh/Someone Else/'
run_verify "$fx"
assert_fails "$last_status" "attribution changed"
assert_contains "$last_output" "copyright line was altered" "attribution changed"

it "fails when LICENSE is deleted outright"
fx=$(fixture_new)
rm "$fx/LICENSE"
run_verify "$fx"
assert_fails "$last_status" "license deleted"
assert_contains "$last_output" "LICENSE is missing" "license deleted"

# --- check_shell_syntax ---------------------------------------------------

it "fails on a shell syntax error"
fx=$(fixture_new)
printf 'if\n' >> "$fx/scripts/bootstrap.sh"
run_verify "$fx"
assert_fails "$last_status" "syntax error"
assert_contains "$last_output" "shell syntax error" "syntax error"

it "fails when a script is not executable"
fx=$(fixture_new)
chmod -x "$fx/scripts/bootstrap.sh"
run_verify "$fx"
assert_fails "$last_status" "non-executable script"
assert_contains "$last_output" "not executable" "non-executable script"

# CI installs shellcheck and this box may not, so the lint path is easy to break
# without noticing until CI goes red. When the tool is present, prove the gate
# uses it; when it is absent, say so rather than silently passing.
it "fails on a shellcheck violation when shellcheck is available"
if command -v shellcheck >/dev/null 2>&1; then
	fx=$(fixture_new)
	cat > "$fx/scripts/lint-me.sh" <<'BAD'
#!/bin/sh
set -eu
# Valid POSIX syntax, but `==` inside [ ] is a bashism (SC3014).
x=1
if [ "$x" == "1" ]; then
	printf 'yes\n'
fi
BAD
	chmod +x "$fx/scripts/lint-me.sh"
	run_verify "$fx"
	assert_fails "$last_status" "shellcheck violation"
	assert_contains "$last_output" "shellcheck reported issues" "shellcheck violation"
else
	printf '    note  shellcheck not installed; lint path not exercised here\n'
fi

it "fails when a script has no shebang"
fx=$(fixture_new)
edit_file "$fx/scripts/bootstrap.sh" '1d'
run_verify "$fx"
assert_fails "$last_status" "missing shebang"
assert_contains "$last_output" "missing shebang" "missing shebang"

# --- check_secrets --------------------------------------------------------

for shape in aws github pem openai; do
	it "fails on a committed credential ($shape)"
	fx=$(fixture_new)
	secret_shape "$shape" > "$fx/leaked.txt"
	run_verify "$fx"
	assert_fails "$last_status" "$shape credential"
	assert_contains "$last_output" "looks like it contains a credential" "$shape credential"
done

it "does not flag the gate's own pattern definitions"
fx=$(fixture_new)
run_verify "$fx"
assert_not_contains "$last_output" "scripts/verify.sh: looks like" "self-scan"

# --- check_env_example ----------------------------------------------------

it "fails when .env.example carries a populated value"
fx=$(fixture_new)
printf 'API_TOKEN=hunter2\n' >> "$fx/.env.example"
run_verify "$fx"
assert_fails "$last_status" "populated env value"
assert_contains "$last_output" "has a populated value" "populated env value"

it "accepts documented placeholder forms in .env.example"
fx=$(fixture_new)
{
	printf 'EMPTY_ONE=\n'
	printf 'ANGLE_ONE=<placeholder>\n'
	printf 'CHANGEME_ONE=changeme\n'
	printf 'LOCAL_ONE=http://localhost:5432\n'
} >> "$fx/.env.example"
run_verify "$fx"
assert_ok "$last_status" "placeholder env values"

# --- check_markdown_links -------------------------------------------------

it "fails on a relative markdown link that does not resolve"
fx=$(fixture_new)
printf '\n[dead](docs/does-not-exist.md)\n' >> "$fx/README.md"
run_verify "$fx"
assert_fails "$last_status" "broken link"
assert_contains "$last_output" "link target does not exist" "broken link"

it "leaves absolute and anchor links alone"
fx=$(fixture_new)
printf '\n[web](https://example.com) [anchor](#quick-start)\n' >> "$fx/README.md"
run_verify "$fx"
assert_ok "$last_status" "non-relative links"

# --- check_trailing_whitespace --------------------------------------------

it "fails on trailing whitespace"
fx=$(fixture_new)
printf '\ntrailing   \n' >> "$fx/README.md"
run_verify "$fx"
assert_fails "$last_status" "trailing whitespace"
assert_contains "$last_output" "trailing whitespace" "trailing whitespace"

# --- check_skills ---------------------------------------------------------

it "fails when a skill has no frontmatter name"
fx=$(fixture_new)
mkdir -p "$fx/.claude/skills/broken"
printf -- '---\ndescription: no name here\n---\n\nBody.\n' > "$fx/.claude/skills/broken/SKILL.md"
run_verify "$fx"
assert_fails "$last_status" "skill without name"
assert_contains "$last_output" "frontmatter is missing 'name'" "skill without name"

it "fails when a skill directory has no SKILL.md"
fx=$(fixture_new)
mkdir -p "$fx/.claude/skills/empty"
printf 'notes\n' > "$fx/.claude/skills/empty/NOTES.md"
run_verify "$fx"
assert_fails "$last_status" "skill without SKILL.md"
assert_contains "$last_output" "has no SKILL.md" "skill without SKILL.md"

it "fails when a skill name does not match its directory"
fx=$(fixture_new)
mkdir -p "$fx/.claude/skills/mismatched"
printf -- '---\nname: something-else\ndescription: d\n---\n\nBody.\n' \
	> "$fx/.claude/skills/mismatched/SKILL.md"
run_verify "$fx"
assert_fails "$last_status" "skill name mismatch"
assert_contains "$last_output" "does not match its directory" "skill name mismatch"

finish
