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

kill_trees_matching() {
	local pattern="$1"
	local pids pid
	pids="$(pgrep -f "$pattern" 2>/dev/null || true)"
	if [[ -z "$pids" ]]; then
		return 0
	fi
	for pid in $pids; do
		if [[ "$pid" == "$$" ]]; then
			continue
		fi
		signal_tree TERM "$pid"
	done
	sleep 0.4
	pids="$(pgrep -f "$pattern" 2>/dev/null || true)"
	for pid in $pids; do
		if [[ "$pid" == "$$" ]]; then
			continue
		fi
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
kill_trees_matching "${root}/scripts/serve-process.sh"
kill_trees_matching "${root}/scripts/serve-pipelines-api.sh"
kill_trees_matching "${root}/scripts/serve-content-pipelines-mcp.sh"

for port in "${ports[@]}"; do
	free_listen_port "$port"
done

if [[ "${1:-}" == "--preflight" ]]; then
	exit 0
fi

if [[ -t 1 ]]; then
	echo "serve: stopped process-compose and freed ports ${ports[*]}"
fi
