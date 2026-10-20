#!/usr/bin/env bash
# Run a long-lived dev command under process-compose and tear down the whole
# process tree on exit. wgo / go run often move the listener into a new
# process group, so kill 0 (this group only) leaves :3850 held.
set -euo pipefail

self_pid=$$
child_pid=""
cleaning=0

list_descendants() {
	local pid="$1"
	local kids k
	kids="$(pgrep -P "$pid" 2>/dev/null || true)"
	for k in $kids; do
		list_descendants "$k"
		printf '%s\n' "$k"
	done
}

collect_pids() {
	local root_pid="$1"
	local pid
	if [[ -n "$root_pid" ]]; then
		list_descendants "$root_pid"
		printf '%s\n' "$root_pid"
	fi
	list_descendants "$self_pid" | while IFS= read -r pid; do
		if [[ -n "$pid" && "$pid" != "$self_pid" ]]; then
			printf '%s\n' "$pid"
		fi
	done
}

unique_lines() {
	sort -u | grep -v '^$' || true
}

self_pgid() {
	ps -o pgid= -p "$self_pid" 2>/dev/null | tr -d ' '
}

signal_pids() {
	local sig="$1"
	shift
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	local pid pgid own_pgid
	own_pgid="$(self_pgid)"
	for pid in "$@"; do
		if [[ "$pid" == "$self_pid" ]]; then
			continue
		fi
		kill -s "$sig" -- "$pid" 2>/dev/null || true
	done
	for pid in "$@"; do
		pgid="$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
		if [[ -z "$pgid" || "$pgid" == "0" || "$pgid" == "$own_pgid" ]]; then
			continue
		fi
		kill -s "$sig" -- "-$pgid" 2>/dev/null || true
	done
}

cleanup() {
	if [[ "$cleaning" == 1 ]]; then
		return
	fi
	cleaning=1
	trap - EXIT INT TERM

	local pids
	pids="$(collect_pids "$child_pid" | unique_lines)"
	if [[ -n "$pids" ]]; then
		# Word split of pid list is intentional.
		# shellcheck disable=SC2086
		signal_pids TERM $pids
		sleep 0.5
		# shellcheck disable=SC2086
		signal_pids KILL $pids
	fi
}

trap cleanup EXIT INT TERM

"$@" &
child_pid=$!
set +e
wait "$child_pid"
status=$?
set -e
exit "$status"
