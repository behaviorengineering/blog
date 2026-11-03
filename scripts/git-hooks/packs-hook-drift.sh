#!/usr/bin/env bash
# Compare copied pack hook files to the local cursor-packs plugin clone.
# Prints host path, incoming path, and GitHub blob URL. Does not copy.
set -euo pipefail

PLUGIN="${CURSOR_PACKS_PLUGIN:-${HOME}/.cursor/plugins/local/cursor-packs}"
BLOB_ROOT="https://github.com/xynova/cursor-packs/blob"
SKIP_SCRIPTS="pins-are-latest-release.sh"

if [[ ! -d "$PLUGIN" ]]; then
  exit 0
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

file_hash() {
  shasum -a 256 "$1" | awk '{print $1}'
}

plugin_sha=""
if [[ -d "$PLUGIN/.git" || -f "$PLUGIN/.git" ]]; then
  plugin_sha="$(git -C "$PLUGIN" rev-parse HEAD 2>/dev/null || true)"
fi

blob_url() {
  local rel="$1"
  if [[ -n "$plugin_sha" ]]; then
    printf '%s/%s/%s\n' "$BLOB_ROOT" "$plugin_sha" "$rel"
  else
    printf '(no git SHA in plugin clone)\n'
  fi
}

drift=0

report_diff() {
  local host_rel="$1"
  local pack_rel="$2"
  echo "lefthook: pack hook copy differs from plugin. Read the incoming file; this check does not copy it."
  echo "  host:     ${ROOT}/${host_rel}"
  echo "  incoming: ${PLUGIN}/${pack_rel}"
  echo "  source:   $(blob_url "$pack_rel")"
  drift=1
}

compare_pair() {
  local host_rel="$1"
  local pack_rel="$2"
  local host_path="${ROOT}/${host_rel}"
  local pack_path="${PLUGIN}/${pack_rel}"

  if [[ ! -f "$pack_path" ]]; then
    echo "lefthook: plugin is missing ${pack_rel} (host still has ${host_rel})."
    echo "  host:     ${host_path}"
    echo "  incoming: ${pack_path} (missing)"
    drift=1
    return
  fi
  if [[ ! -f "$host_path" ]]; then
    echo "lefthook: host is missing ${host_rel}."
    echo "  host:     ${host_path} (missing)"
    echo "  incoming: ${pack_path}"
    echo "  source:   $(blob_url "$pack_rel")"
    drift=1
    return
  fi
  if [[ "$(file_hash "$host_path")" != "$(file_hash "$pack_path")" ]]; then
    report_diff "$host_rel" "$pack_rel"
  fi
}

compare_pair "scripts/git-hooks/default-branch-refuse.sh" "lefthook/scripts/default-branch-refuse.sh"
compare_pair "scripts/git-hooks/go-format-staged.sh" "lefthook/scripts/go-format-staged.sh"
compare_pair "lefthook/lefthook-go-standalone.yml" "lefthook/lefthook-go-standalone.yml"

copied_scripts="default-branch-refuse.sh go-format-staged.sh"
for pack_path in "$PLUGIN"/lefthook/scripts/*.sh; do
  [[ -f "$pack_path" ]] || continue
  base="$(basename "$pack_path")"
  case " $SKIP_SCRIPTS " in
    *" $base "*) continue ;;
  esac
  case " $copied_scripts " in
    *" $base "*) continue ;;
  esac
  rel="lefthook/scripts/${base}"
  echo "lefthook: plugin has a hook script this repo has not copied."
  echo "  would add: ${rel}"
  echo "  incoming:  ${pack_path}"
  echo "  source:    $(blob_url "$rel")"
  drift=1
done

if [[ "$drift" -ne 0 ]]; then
  echo "lefthook: stop. Copy only after you have read the incoming files."
  exit 1
fi

exit 0
