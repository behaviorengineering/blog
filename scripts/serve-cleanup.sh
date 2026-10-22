#!/usr/bin/env bash
# Stop process-compose and free loopback ports used by make serve.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

SOCK="$root/tmp/process-compose.sock"
ports=(3848 3849 3850)

list_descendants() {
	local pid="$1"
	local kids k
	kids="$(pgrep -P "$pid" 2>/dev/null || true)"
	for k in $kids; do
		list_descendants "$k"
		printf '%s\n' "$k"
	done
}

signal_tree() {
	local sig="$1"
	local root_pid="$2"
	local pid pgid own_pgid
	own_pgid="$(ps -o pgid= -p $$ 2>/dev/null | tr -d ' ')"
	local pids
	pids="$(list_descendants "$root_pid"; printf '%s\n' "$root_pid")"
	for pid in $pids; do
		if [[ "$pid" == "$$" ]]; then
			continue
		fi
		kill -s "$sig" -- "$pid" 2>/dev/null || true
		pgid="$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
		if [[ -n "$pgid" && "$pgid" != "0" && "$pgid" != "$own_pgid" ]]; then
			kill -s "$sig" -- "-$pgid" 2>/dev/null || true
		fi
	done
}

# Fixed-string match against ps command lines (relative ./scripts/... and
# absolute paths both contain scripts/serve-process.sh). pgrep -f is regex
# and previously used $root/scripts/... which missed process-compose's
# bash ./scripts/serve-process.sh leftovers.
pids_matching() {
	local needle="$1"
	local pid cmd
	while read -r pid cmd; do
		if [[ "$pid" == "$$" || "$pid" == "$PPID" ]]; then
			continue
		fi
		if [[ "$cmd" == *"$needle"* ]]; then
			printf '%s\n' "$pid"
		fi
	done < <(ps -ax -o pid=,command=)
}

kill_trees_matching() {
	local needle="$1"
	local pids pid
	pids="$(pids_matching "$needle")"
	if [[ -z "$pids" ]]; then
		return 0
	fi
	for pid in $pids; do
		signal_tree TERM "$pid"
	done
	sleep 0.4
	pids="$(pids_matching "$needle")"
	for pid in $pids; do
		signal_tree KILL "$pid"
	done
}

free_listen_port() {
	local port="$1"
	local pids
	pids="$(lsof -nP -iTCP:"${port}" -sTCP:LISTEN -t 2>/dev/null || true)"
	if [[ -z "${pids}" ]]; then
		return 0
	fi
	local pid
	for pid in $pids; do
		signal_tree TERM "$pid"
	done
	sleep 0.3
	pids="$(lsof -nP -iTCP:"${port}" -sTCP:LISTEN -t 2>/dev/null || true)"
	if [[ -z "${pids}" ]]; then
		return 0
	fi
	for pid in $pids; do
		signal_tree KILL "$pid"
		kill -s KILL -- "$pid" 2>/dev/null || true
	done
}

process-compose down -U -u "$SOCK" 2>/dev/null || true
rm -f "$SOCK"

# Wrappers first: leftover wgo will otherwise restart go run and re-bind.
# Substring needles hit both ./scripts/... and absolute script paths.
kill_trees_matching "scripts/serve-process.sh"
kill_trees_matching "scripts/serve-pipelines-api.sh"
kill_trees_matching "scripts/serve-content-pipelines-mcp.sh"
kill_trees_matching "scripts/serve-carousel-save.sh"
# Orphaned wgo after the wrapper is SIGKILL'd (new process group, PPID 1).
kill_trees_matching "-cd ${root}/providers/content-pipelines-mcp"
kill_trees_matching "carousel-save -addr 127.0.0.1:3848"
kill_trees_matching "${root}/tmp/pipelines-serve"
kill_trees_matching "${root}/tmp/content-pipelines-mcp"
kill_trees_matching "${root}/tmp/carousel-save"

for port in "${ports[@]}"; do
	free_listen_port "$port"
done

if [[ "${1:-}" == "--preflight" ]]; then
	exit 0
fi

if [[ -t 1 ]]; then
	echo "serve: stopped process-compose and freed ports ${ports[*]}"
fi
