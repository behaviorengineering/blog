#!/usr/bin/env bash
# Compile tenant-admin before process-compose so readiness does not wait on go build.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lib="${root}/providers/content-pipelines"
bin="${root}/tmp/tenant-admin-serve"

if [[ ! -d "${lib}" ]]; then
	echo "providers/content-pipelines missing; run ./scripts/link-providers.sh" >&2
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
elif find "${lib}" \( -path '*/.git/*' -o -path '*/tmp/*' \) -prune -o \( -name '*.go' -o -name 'go.mod' -o -name 'go.sum' \) -newer "${bin}" -print -quit 2>/dev/null | grep -q .; then
	need_build=true
fi

if [[ "${need_build}" == true ]]; then
	echo "serve: building tenant-admin -> tmp/tenant-admin-serve" >&2
	go build -C "${lib}" -o "${bin}" ./cmd/tenant-admin
	echo "serve: tenant-admin binary ready" >&2
else
	echo "serve: using existing tmp/tenant-admin-serve" >&2
fi
