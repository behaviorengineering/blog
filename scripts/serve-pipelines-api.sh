#!/usr/bin/env bash
# Exec the prebuilt pipelines-api binary. Compile happens in serve-up / task serve.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lib="${root}/providers/content-pipelines"
forms="${root}/data/essay-content-forms.yaml"
bin="${root}/tmp/pipelines-serve"

if [[ ! -d "${lib}" ]]; then
	echo "providers/content-pipelines missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi

"${root}/scripts/serve-build-pipelines-api.sh"

extra_args=()
if [[ -f "${forms}" ]]; then
	extra_args+=(--content-forms "${forms}")
fi

polypus_base="${POLYPUS_BASE_URL:-https://polypus.manticore-powan.ts.net}"
polypus_otlp="${POLYPUS_OTLP_ENDPOINT:-polypus.manticore-powan.ts.net:4317}"
# Relative migration paths (migrations/shared) resolve from the pipelines module.
cd "${lib}"
exec env "POLYPUS_BASE_URL=${polypus_base}" "POLYPUS_OTLP_ENDPOINT=${polypus_otlp}" \
	"${bin}" serve "${extra_args[@]}" "$@"
