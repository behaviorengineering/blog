#!/usr/bin/env bash
# Exec the prebuilt pipelines-proxy binary. Compile happens in serve-up / task serve.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lib="${root}/providers/content-pipelines"
bin="${root}/tmp/pipelines-proxy"

if [[ ! -d "${lib}" ]]; then
	echo "providers/content-pipelines missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi

"${root}/scripts/serve-build-pipelines-proxy.sh"

polypus_base="${POLYPUS_URL:-${POLYPUS_BASE_URL:-https://polypus-local.manticore-powan.ts.net}}"
polypus_otlp="${POLYPUS_OTLP_ENDPOINT:-polypus-local.manticore-powan.ts.net:4317}"
# Relative migration paths resolve from the pipelines module.
cd "${lib}"
exec env "POLYPUS_URL=${polypus_base}" "POLYPUS_BASE_URL=${polypus_base}" "POLYPUS_OTLP_ENDPOINT=${polypus_otlp}" \
	"${bin}" serve "$@"
