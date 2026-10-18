#!/usr/bin/env bash
# Run pipelines serve from providers/content-pipelines. Used by process-compose.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lib="${root}/providers/content-pipelines"
forms="${root}/data/essay-content-forms.yaml"

if [[ ! -d "${lib}" ]]; then
	echo "providers/content-pipelines missing; run ./scripts/link-providers.sh" >&2
	exit 1
fi

cd "${root}"
extra_args=()
if [[ -f "${forms}" ]]; then
	extra_args+=(--content-forms "${forms}")
fi

polypus_base="${POLYPUS_BASE_URL:-https://polypus.manticore-powan.ts.net}"
polypus_otlp="${POLYPUS_OTLP_ENDPOINT:-polypus.manticore-powan.ts.net:4317}"
exec go tool wgo -cd "${lib}" -file .go \
	env "POLYPUS_BASE_URL=${polypus_base}" "POLYPUS_OTLP_ENDPOINT=${polypus_otlp}" \
	go run ./cmd serve "${extra_args[@]}" "$@"
