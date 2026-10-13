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

cd "${root}"
if ! command -v go >/dev/null 2>&1 || ! go tool templ version >/dev/null 2>&1; then
	echo "go tool templ is required; run: cd providers/content-pipelines-mcp && go get -tool github.com/a-h/templ/cmd/templ@latest" >&2
	exit 1
fi
exec go tool wgo -cd "${mcp}" -file .go -file .html -file .css -file .templ bash -c 'go tool templ generate && go run ./cmd/content-pipelines-mcp --config "$1" "${@:2}"' _ "${cfg}" "$@"
