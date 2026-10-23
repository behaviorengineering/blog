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

force=false
if [[ "${SERVE_FORCE_BUILD:-}" == "1" ]]; then
	force=true
fi

mkdir -p "${root}/tmp"

need_templ=false
if [[ "${force}" == true ]]; then
	need_templ=true
else
	while IFS= read -r -d '' f; do
		gof="${f%.templ}_templ.go"
		if [[ ! -f "${gof}" ]] || [[ "${f}" -nt "${gof}" ]]; then
			need_templ=true
			break
		fi
	done < <(find "${mcp}" \( -path '*/.git/*' -o -path '*/tmp/*' \) -prune -o -name '*.templ' -print0 2>/dev/null)
fi

if [[ "${need_templ}" == true ]]; then
	echo "serve: templ generate (content-pipelines-mcp)" >&2
	go -C "${mcp}" tool templ generate
fi

need_build=false
if [[ "${force}" == true ]] || [[ ! -x "${bin}" ]]; then
	need_build=true
elif find "${mcp}" \( -path '*/.git/*' -o -path '*/tmp/*' \) -prune -o \( -name '*.go' -o -name '*.templ' -o -name 'go.mod' -o -name 'go.sum' \) -newer "${bin}" -print -quit 2>/dev/null | grep -q .; then
	need_build=true
fi

if [[ "${need_build}" == true ]]; then
	echo "serve: building content-pipelines-mcp -> tmp/content-pipelines-mcp" >&2
	go build -C "${mcp}" -o "${bin}" ./cmd/content-pipelines-mcp
	echo "serve: content-pipelines-mcp binary ready" >&2
else
	echo "serve: using existing tmp/content-pipelines-mcp" >&2
fi
