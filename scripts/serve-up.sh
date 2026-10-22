#!/usr/bin/env bash
# Start process-compose for local dev; run serve-cleanup on exit (Task/go-task safe).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

SOCK="$root/tmp/process-compose.sock"
mkdir -p "$root/tmp"
"$root/scripts/serve-build-pipelines-api.sh"
"$root/scripts/serve-build-content-pipelines-mcp.sh"
"$root/scripts/serve-build-carousel-save.sh"

cleaning=0
cleanup() {
	if [[ "$cleaning" == 1 ]]; then
		return
	fi
	cleaning=1
	trap - EXIT INT TERM
	"$root/scripts/serve-cleanup.sh"
}

trap cleanup EXIT INT TERM
# Do not exec: exec discards this trap, so quitting the TUI leaked wgo trees.
set +e
process-compose up -f process-compose.yaml -U -u "$SOCK"
status=$?
set -e
exit "$status"
