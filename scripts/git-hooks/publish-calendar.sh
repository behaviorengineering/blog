#!/usr/bin/env bash
# Regenerate the publish calendar when staged changes touch content/.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if ! git diff --cached --name-only | grep -q '^content/'; then
  exit 0
fi

echo "lefthook: regenerating publish calendar (content/ staged)"
go tool task -d "$ROOT" calendar
git add -- "static/calendar/publish-calendar.json"
