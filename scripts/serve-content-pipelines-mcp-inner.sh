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

need_templ=false
while IFS= read -r -d '' f; do
	gof="${f%.templ}_templ.go"
	if [[ ! -f "${gof}" ]] || [[ "${f}" -nt "${gof}" ]]; then
		need_templ=true
		break
	fi
done < <(find "${mcp}" \( -path '*/.git/*' -o -path '*/tmp/*' \) -prune -o -name '*.templ' -print0 2>/dev/null)

if [[ "${need_templ}" == true ]]; then
	if ! go -C "${mcp}" tool templ version >/dev/null 2>&1; then
		echo "go tool templ is required; run: cd providers/content-pipelines-mcp && go get -tool github.com/a-h/templ/cmd/templ@latest" >&2
		exit 1
	fi
	go -C "${mcp}" tool templ generate
fi

need_build=false
if [[ ! -x "${bin}" ]]; then
	need_build=true
elif find "${mcp}" \( -path '*/.git/*' -o -path '*/tmp/*' \) -prune -o \( -name '*.go' -o -name '*.templ' \) -newer "${bin}" -print -quit 2>/dev/null | grep -q .; then
	need_build=true
fi

if [[ "${need_build}" == true ]]; then
	"${root}/scripts/serve-build-content-pipelines-mcp.sh"
fi

export PIPELINES_API_URL="${api_url}"
export POLYPUS_BASE_URL="${polypus_base}"
export POLYPUS_OTLP_ENDPOINT="${polypus_otlp}"
exec "${bin}" --config "${cfg}" "$@"
