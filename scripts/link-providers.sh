#!/usr/bin/env bash
# Symlink sibling repos into providers/ for local dev (providers/ is gitignored).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
providers="${root}/providers"
mkdir -p "${providers}"

link() {
	local name="$1"
	local target="$2"
	local link_path="${providers}/${name}"
	if [[ -L "${link_path}" ]] && [[ "$(readlink "${link_path}")" == "${target}" ]]; then
		echo "providers/${name} -> ${target} (ok)"
		return 0
	fi
	if [[ -e "${link_path}" ]]; then
		echo "providers/${name} exists and is not the expected symlink; remove it and retry" >&2
		exit 1
	fi
	ln -sfn "${target}" "${link_path}"
	echo "providers/${name} -> ${target}"
}

# From site/providers/: up to ai/, then into the repo checkout.
link content-pipelines-mcp ../../../content-pipelines-mcp
