#!/usr/bin/env bash
# Link every skill in this repo into the local agent skill folders.
# The repo is the source of truth: the folders get symlinks, so an edit here is live at once.
# skills/ is public; private-skills/ is git-ignored and deployed the same way.
# targets.conf limits a skill to some tools; an unlisted skill goes to both.
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Codex reads ~/.agents/skills. It also still reads ~/.codex/skills and lists a
# skill found in both twice, so only one of them is a target.
declare -A DIRS=([claude]="$HOME/.claude/skills" [codex]="$HOME/.agents/skills")

targets_for() {
  local t
  t="$(awk -v n="$1" '$1 == n { for (i = 2; i <= NF && $i !~ /^#/; i++) printf "%s ", $i }' \
    "$REPO_DIR/targets.conf" 2>/dev/null)"
  echo "${t:-claude codex}"
}

for skill in "$REPO_DIR"/skills/*/ "$REPO_DIR"/private-skills/*/; do
  skill="${skill%/}"
  name="$(basename "$skill")"
  want=" $(targets_for "$name") "
  for tool in claude codex; do
    dest="${DIRS[$tool]}/$name"
    if [[ $want == *" $tool "* ]]; then
      mkdir -p "${DIRS[$tool]}"
      rm -rf "$dest"
      ln -s "$skill" "$dest"
      echo "linked $name -> $dest"
    elif [[ -L $dest && "$(readlink "$dest")" == "$REPO_DIR"/* ]]; then
      rm "$dest"
      echo "removed $dest (not a target)"
    fi
  done
done
