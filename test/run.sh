#!/usr/bin/env bash
# Run the headless config smoke test. Exits non-zero on failure.
# Usage: test/run.sh [timeout-seconds]   (default 120)
set -euo pipefail

cd "$(dirname "$0")/.."
limit="${1:-120}"

# macOS has no coreutils `timeout`; perl's alarm kills a hung nvim
exec perl -e 'alarm shift; exec @ARGV' "$limit" \
	nvim --headless --cmd "luafile test/smoke.lua"
