#!/usr/bin/env bash
# Create skills/<name>/SKILL.md with frontmatter that passes the Agent Skills spec.
set -euo pipefail

name="${1:?usage: scripts/new-skill.sh <name>}"
if [[ ${#name} -gt 64 || ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "name must be 1-64 characters: a-z, 0-9 and single hyphens between them" >&2
  exit 1
fi

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills/$name"
if [[ -e "$dir" ]]; then
  echo "$dir already exists" >&2
  exit 1
fi

mkdir -p "$dir"
cat > "$dir/SKILL.md" <<EOF
---
name: $name
description: TODO say what this skill does and when the agent should use it (1024 characters at most).
---

# $name

TODO instructions for the agent.
EOF
echo "created $dir/SKILL.md"
