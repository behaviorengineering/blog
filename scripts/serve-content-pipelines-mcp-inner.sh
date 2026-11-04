#!/usr/bin/env bash
# Invoked by wgo; skip-if-fresh then exec content-pipelines-mcp binary.
set -euo pipefail

bin="$1"
cfg="$2"
api_url="$3"
polypus_base="$4"
polypus_otlp="$5"
shift 5

root="$(cd "$(dirname "$0")/.." && pwd)"
mcp="${root}/providers/content-pipelines-mcp"

if [[ ! -d "${mcp}" ]]; then
	echo "providers/content-pipelines-mcp missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi

"${root}/scripts/serve-build-content-pipelines-mcp.sh"

export PIPELINES_API_URL="${api_url}"
export POLYPUS_URL="${polypus_base}"
export POLYPUS_BASE_URL="${polypus_base}"
export POLYPUS_OTLP_ENDPOINT="${polypus_otlp}"

# Rebuilt tmp/content-pipelines-mcp binaries lose macOS keychain ACL, so the
# server's go-keyring Get is empty and pipelines-proxy returns 401. Load the
# token from the same keychain item via a stable go run (prints to stdout only).
if [[ -z "${PIPELINES_API_TOKEN:-}" ]]; then
	tok="$(
		cd "${mcp}" && go run -tags keyringget "${root}/scripts/mcp-keyring-get.go" 2>/dev/null || true
	)"
	if [[ -n "${tok}" ]]; then
		export PIPELINES_API_TOKEN="${tok}"
	else
		echo "serve: PIPELINES_API_TOKEN missing from keychain service content-pipelines-mcp; command center board calls will 401" >&2
	fi
fi

exec "${bin}" --config "${cfg}" "$@"
