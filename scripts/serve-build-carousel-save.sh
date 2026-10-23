#!/usr/bin/env bash
# Compile carousel-save before process-compose so readiness does not wait on go build.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
bin="${root}/tmp/carousel-save"

if [[ ! -d "${root}/cmd/carousel-save" ]]; then
	echo "cmd/carousel-save missing" >&2
	exit 1
fi

force=false
if [[ "${SERVE_FORCE_BUILD:-}" == "1" ]]; then
	force=true
fi

mkdir -p "${root}/tmp"

need_build=false
if [[ "${force}" == true ]] || [[ ! -x "${bin}" ]]; then
	need_build=true
elif find "${root}/cmd/carousel-save" "${root}/internal/carouselsave" -name '*.go' -newer "${bin}" -print -quit 2>/dev/null | grep -q .; then
	need_build=true
elif [[ "${root}/go.mod" -nt "${bin}" ]] || [[ "${root}/go.sum" -nt "${bin}" ]]; then
	need_build=true
fi

if [[ "${need_build}" == true ]]; then
	echo "serve: building carousel-save -> tmp/carousel-save" >&2
	cd "${root}"
	go build -o "${bin}" ./cmd/carousel-save
	echo "serve: carousel-save binary ready" >&2
else
	echo "serve: using existing tmp/carousel-save" >&2
fi
