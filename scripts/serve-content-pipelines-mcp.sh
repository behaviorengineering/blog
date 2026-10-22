#!/usr/bin/env bash
# Run content-pipelines-mcp from providers/ (gitignored symlink). Used by process-compose.
# wgo must run with cwd in the MCP module (site-root wgo walks content/ before first exec).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
mcp="${root}/providers/content-pipelines-mcp"
cfg="${root}/content-pipelines-mcp.yaml"
bin="${root}/tmp/content-pipelines-mcp"
wgo="$(cd "${root}" && go tool -n wgo)"

if [[ ! -d "${mcp}" ]]; then
	echo "providers/content-pipelines-mcp missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi
if [[ ! -f "${cfg}" ]]; then
	echo "content-pipelines-mcp.yaml missing" >&2
	exit 1
fi

# wgo's child can drop process-compose env; pass API and Polypus on argv.
api_url="${PIPELINES_API_URL:-http://127.0.0.1:3850}"
polypus_base="${POLYPUS_BASE_URL:-https://polypus.manticore-powan.ts.net}"
polypus_otlp="${POLYPUS_OTLP_ENDPOINT:-polypus.manticore-powan.ts.net:4317}"

cd "${mcp}"
exec "${wgo}" -file .go -file .templ \
	bash "${root}/scripts/serve-content-pipelines-mcp-inner.sh" \
	"${bin}" "${cfg}" "${api_url}" "${polypus_base}" "${polypus_otlp}" "$@"
