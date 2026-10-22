#!/usr/bin/env bash
# Compile carousel-save before process-compose so readiness does not wait on go build.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
bin="${root}/tmp/carousel-save"

if [[ ! -d "${root}/cmd/carousel-save" ]]; then
	echo "cmd/carousel-save missing" >&2
	exit 1
fi

mkdir -p "${root}/tmp"
echo "serve: building carousel-save -> tmp/carousel-save" >&2
cd "${root}"
go build -o "${bin}" ./cmd/carousel-save
echo "serve: carousel-save binary ready" >&2
