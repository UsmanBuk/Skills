#!/usr/bin/env bash
# Check every skill against the Agent Skills spec (https://agentskills.io/specification)
# with the reference validator, and the plugin manifest with Claude Code if it is installed.
set -euo pipefail
shopt -s nullglob
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail=0
skills=(skills/*/)
for dir in "${skills[@]}"; do
  uvx --quiet --from skills-ref==0.1.1 agentskills validate "$dir" || fail=1
done
echo "checked ${#skills[@]} skill(s)"

if command -v claude > /dev/null; then
  claude plugin validate . --strict || fail=1
fi
exit "$fail"
