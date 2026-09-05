#!/bin/sh
# Prepare a working copy for development.
#
# BotOS has no dependencies yet, so this installs nothing — it verifies that
# the tools the scaffold relies on are present and tells you what is missing.
# When the first real toolchain lands, add its install step here so that
# `make bootstrap` stays the one command a newcomer has to run.
set -eu

missing=0

require() {
	if command -v "$1" >/dev/null 2>&1; then
		printf '  ok       %-12s %s\n' "$1" "$(command -v "$1")"
	else
		printf '  MISSING  %-12s %s\n' "$1" "$2" >&2
		missing=$((missing + 1))
	fi
}

optional() {
	if command -v "$1" >/dev/null 2>&1; then
		printf '  ok       %-12s %s\n' "$1" "$(command -v "$1")"
	else
		printf '  absent   %-12s optional — %s\n' "$1" "$2"
	fi
}

printf 'BotOS bootstrap\n\nRequired:\n'
require git  'install git'
require make 'install make (build-essential, xcode-select --install, or equivalent)'

printf '\nOptional:\n'
optional shellcheck 'enables shell linting during make verify'

if [ ! -f .env ] && [ -f .env.example ]; then
	printf '\nNo .env found. Copy the template when you need local config:\n'
	printf '  cp .env.example .env\n'
fi

printf '\n'
if [ "$missing" -gt 0 ]; then
	printf 'Bootstrap incomplete: %s required tool(s) missing.\n' "$missing" >&2
	exit 1
fi

printf 'Bootstrap complete. No dependencies to install. Next: make verify\n'
