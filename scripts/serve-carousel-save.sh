#!/usr/bin/env bash
# Exec prebuilt carousel-save; wgo rebuilds tmp/carousel-save on .go changes.
# wgo must run from cmd/carousel-save (not site root) or it walks content/ before first exec.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
bin="${root}/tmp/carousel-save"
wgo="$(cd "${root}" && go tool -n wgo)"

if [[ ! -d "${root}/cmd/carousel-save" ]]; then
	echo "cmd/carousel-save missing" >&2
	exit 1
fi

cd "${root}/cmd/carousel-save"
exec "${wgo}" -file .go -root "${root}/internal/carouselsave" \
	bash "${root}/scripts/serve-carousel-save-inner.sh" "${bin}"
