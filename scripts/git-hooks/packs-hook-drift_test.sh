#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DRIFT="$ROOT/scripts/git-hooks/packs-hook-drift.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_exit() {
  local want="$1"
  local got="$2"
  local name="$3"
  if [[ "$got" != "$want" ]]; then
    fail "$name: exit $got want $want"
  fi
}

make_plugin() {
  local dir="$1"
  mkdir -p "$dir/lefthook/scripts"
  git -C "$dir" init -q
  git -C "$dir" config user.email "drift-test@example.com"
  git -C "$dir" config user.name "Drift Test"
  printf '%s\n' "refuse-a" >"$dir/lefthook/scripts/default-branch-refuse.sh"
  printf '%s\n' "format-a" >"$dir/lefthook/scripts/go-format-staged.sh"
  printf '%s\n' "yaml-a" >"$dir/lefthook/lefthook-go-standalone.yml"
  printf '%s\n' "pin" >"$dir/lefthook/scripts/pins-are-latest-release.sh"
  git -C "$dir" add lefthook
  git -C "$dir" commit -qm "seed"
}

make_host() {
  local dir="$1"
  mkdir -p "$dir/scripts/git-hooks" "$dir/lefthook"
  git -C "$dir" init -q
  git -C "$dir" config user.email "drift-test@example.com"
  git -C "$dir" config user.name "Drift Test"
  printf '%s\n' "refuse-a" >"$dir/scripts/git-hooks/default-branch-refuse.sh"
  printf '%s\n' "format-a" >"$dir/scripts/git-hooks/go-format-staged.sh"
  printf '%s\n' "yaml-a" >"$dir/lefthook/lefthook-go-standalone.yml"
  git -C "$dir" add scripts lefthook
  git -C "$dir" commit -qm "host copies"
}

PLUGIN="$TMP/plugin"
HOST="$TMP/host"
make_plugin "$PLUGIN"
make_host "$HOST"

set +e
CURSOR_PACKS_PLUGIN="$PLUGIN" git -C "$HOST" rev-parse --show-toplevel >/dev/null
(cd "$HOST" && CURSOR_PACKS_PLUGIN="$PLUGIN" bash "$DRIFT")
got=$?
set -e
assert_exit 0 "$got" "matching copies"

printf '%s\n' "refuse-b" >"$PLUGIN/lefthook/scripts/default-branch-refuse.sh"
set +e
out="$(cd "$HOST" && CURSOR_PACKS_PLUGIN="$PLUGIN" bash "$DRIFT" 2>&1)"
got=$?
set -e
assert_exit 1 "$got" "changed script"
printf '%s\n' "$out" | grep -q "incoming:" || fail "changed script missing incoming"
printf '%s\n' "$out" | grep -q "source:" || fail "changed script missing source"
printf '%s\n' "$out" | grep -q "github.com/xynova/cursor-packs/blob/" || fail "changed script missing GitHub blob"

printf '%s\n' "refuse-a" >"$PLUGIN/lefthook/scripts/default-branch-refuse.sh"
printf '%s\n' "extra" >"$PLUGIN/lefthook/scripts/surprise.sh"
set +e
out="$(cd "$HOST" && CURSOR_PACKS_PLUGIN="$PLUGIN" bash "$DRIFT" 2>&1)"
got=$?
set -e
assert_exit 1 "$got" "would add"
printf '%s\n' "$out" | grep -q "would add:" || fail "would add missing label"

set +e
(cd "$HOST" && CURSOR_PACKS_PLUGIN="$TMP/missing-plugin" bash "$DRIFT")
got=$?
set -e
assert_exit 0 "$got" "missing plugin skips"

echo "packs-hook-drift_test: ok"
