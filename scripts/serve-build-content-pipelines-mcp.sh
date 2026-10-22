#!/usr/bin/env bash
# Compile content-pipelines-mcp before process-compose so readiness does not wait on go build.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
mcp="${root}/providers/content-pipelines-mcp"
bin="${root}/tmp/content-pipelines-mcp"

if [[ ! -d "${mcp}" ]]; then
	echo "providers/content-pipelines-mcp missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi
if ! command -v go >/dev/null 2>&1 || ! go -C "${mcp}" tool templ version >/dev/null 2>&1; then
	echo "go tool templ is required; run: cd providers/content-pipelines-mcp && go get -tool github.com/a-h/templ/cmd/templ@latest" >&2
	exit 1
fi

mkdir -p "${root}/tmp"
echo "serve: templ generate (content-pipelines-mcp)" >&2
go -C "${mcp}" tool templ generate
echo "serve: building content-pipelines-mcp -> tmp/content-pipelines-mcp" >&2
go build -C "${mcp}" -o "${bin}" ./cmd/content-pipelines-mcp
echo "serve: content-pipelines-mcp binary ready" >&2
