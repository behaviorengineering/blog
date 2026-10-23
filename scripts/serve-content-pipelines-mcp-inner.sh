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
export POLYPUS_BASE_URL="${polypus_base}"
export POLYPUS_OTLP_ENDPOINT="${polypus_otlp}"
exec "${bin}" --config "${cfg}" "$@"
