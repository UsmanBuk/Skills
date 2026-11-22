#!/usr/bin/env bash
# Copy every skill in this repo into the local agent skill folders.
# The repo is the source of truth; these folders are deploy targets.
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Codex reads ~/.agents/skills. It also still reads ~/.codex/skills and lists a
# skill found in both twice, so only one of them is a target.
TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
)

for skill in "$REPO_DIR"/skills/*/; do
  name="$(basename "$skill")"
  for target in "${TARGETS[@]}"; do
    mkdir -p "$target"
    rm -rf "${target:?}/$name"
    cp -r "$skill" "$target/$name"
    echo "synced $name -> $target/$name"
  done
done
