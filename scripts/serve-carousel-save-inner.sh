#!/usr/bin/env bash
# Invoked by wgo; skip-if-fresh then exec carousel-save binary.
set -euo pipefail

bin="$1"
root="$(cd "$(dirname "$0")/.." && pwd)"

"${root}/scripts/serve-build-carousel-save.sh"

exec "${bin}" -addr 127.0.0.1:3848 -root "${root}"
