#!/usr/bin/env bash
# Sync Continuereadable copies from Cursor canonical trees.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SKILLS=(
  claims-content video-content cognitive-memetics-content spanish-translation-content
  revise-post revise-flow revise-hooks revise-format revise-emphasis
  curiosity-title revise-score revise-post-es revise-spanish revise-prose
  linkedin-post facebook-post substack-post carousel-post
  tag-register tag-unify short-link-register ai-for-general-audience
  perplexity-browser-research
)
RULES=(
  always-rules-0-ai.mdc
  content-placement.mdc
  content-markdown-writing.mdc
  content-images-webp.mdc
)

mkdir -p content-ai/skills content-ai/rules
for s in "${SKILLS[@]}"; do
  src=".cursor/skills/$s"
  dst="content-ai/skills/$s"
  [[ -d "$src" ]] || { echo "skip missing $src"; continue; }
  mkdir -p "$dst"
  rsync -a --delete \
    --include='SKILL.md' --include='reference.md' --include='examples.md' \
    --include='*/' --exclude='*' \
    "$src/" "$dst/"
done
for r in "${RULES[@]}"; do
  cp ".cursor/rules/$r" "content-ai/rules/$r"
done

# Continue-safe paths: .cursor -> content-ai inside copies only
find content-ai -type f \( -name '*.md' -o -name '*.mdc' \) -print0 | while IFS= read -r -d '' f; do
  perl -i -pe 's/`\.cursor\//`content-ai\//g; s{(?<![`/\w])\.cursor/(skills|rules)/}{content-ai/$1/}g' "$f"
done

echo "Synced content-ai/ from .cursor/ (Continue-readable copies)."
