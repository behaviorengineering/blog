#!/usr/bin/env bash
# Run content-pipelines-mcp from providers/ (gitignored symlink). Used by process-compose.
# Stay in the site module so `go tool wgo` resolves; -cd switches into the provider for run.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
mcp="${root}/providers/content-pipelines-mcp"
cfg="${root}/content-pipelines-mcp.yaml"

if [[ ! -d "${mcp}" ]]; then
	echo "providers/content-pipelines-mcp missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi
if [[ ! -f "${cfg}" ]]; then
	echo "content-pipelines-mcp.yaml missing" >&2
	exit 1
fi

abs_from_root() {
	local p="$1"
	if [[ "${p}" = /* ]]; then
		printf '%s\n' "${p}"
	else
		printf '%s\n' "${root}/${p}"
	fi
}

: "${PIPELINES_BIN:=providers/content-pipelines/bin/pipelines}"
: "${PIPELINES_DIR:=providers/content-pipelines}"
PIPELINES_BIN="$(abs_from_root "${PIPELINES_BIN}")"
PIPELINES_DIR="$(abs_from_root "${PIPELINES_DIR}")"
export PIPELINES_BIN PIPELINES_DIR

if [[ ! -x "${PIPELINES_BIN}" ]]; then
	echo "PIPELINES_BIN not executable: ${PIPELINES_BIN} (run ./scripts/link-providers.sh and build pipelines)" >&2
	exit 1
fi
if [[ ! -d "${PIPELINES_DIR}" ]]; then
	echo "PIPELINES_DIR missing: ${PIPELINES_DIR} (run ./scripts/link-providers.sh)" >&2
	exit 1
fi

cd "${root}"
exec go tool wgo -cd "${mcp}" -file .go run ./cmd/content-pipelines-mcp --config "${cfg}" "$@"
