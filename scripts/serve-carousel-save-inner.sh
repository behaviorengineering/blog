#!/usr/bin/env bash
# Invoked by wgo; skip-if-fresh then exec carousel-save binary.
set -euo pipefail

bin="$1"
root="$(cd "$(dirname "$0")/.." && pwd)"

need_build=false
if [[ ! -x "${bin}" ]]; then
	need_build=true
elif find "${root}/cmd/carousel-save" "${root}/internal/carouselsave" -name '*.go' -newer "${bin}" -print -quit 2>/dev/null | grep -q .; then
	need_build=true
fi

if [[ "${need_build}" == true ]]; then
	"${root}/scripts/serve-build-carousel-save.sh"
fi

exec "${bin}" -addr 127.0.0.1:3848 -root "${root}"
