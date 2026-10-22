#!/usr/bin/env bash
# Compile pipelines-api before process-compose so readiness does not wait on go build.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lib="${root}/providers/content-pipelines"
bin="${root}/tmp/pipelines-serve"

if [[ ! -d "${lib}" ]]; then
	echo "providers/content-pipelines missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi

mkdir -p "${root}/tmp"
echo "serve: building pipelines-api -> tmp/pipelines-serve" >&2
go build -C "${lib}" -o "${bin}" ./cmd
echo "serve: pipelines-api binary ready" >&2
