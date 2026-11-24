#!/usr/bin/env bash
# Claude Code SessionStart hook: tell an interactive chat that it is the leader.
#
#   session-start.sh            every interactive chat leads
#   session-start.sh <text>     only chats whose model id contains <text> lead
#
# A session started with LEADER_ROLE=worker in its environment gets nothing.
[[ ${LEADER_ROLE:-} == worker ]] && exit 0

want=${1:-}
input=$(cat)
model=$(grep -o '"model":"[^"]*"' <<<"$input" | cut -d'"' -f4)
source=$(grep -o '"source":"[^"]*"' <<<"$input" | cut -d'"' -f4)

# Claude Code names the model on startup and after compaction. It leaves it out for
# headless runs (claude -p), which should not lead, and on resume and /clear, where
# the chat has to check its own model.
only=""
if [[ -z $model ]]; then
  [[ $source == startup ]] && exit 0
  [[ -n $want ]] && only="This note applies only if your model name contains \"$want\". "
elif [[ -n $want && $model != *"$want"* ]]; then
  exit 0
fi

echo "${only}You are the leader in this chat. The user talks to you, and longer work goes to worker sessions or subagents that you brief, watch and verify. Load the leader skill before you hand out work, or straight away when the user's whole message is the word leader. Do small tasks yourself. If another session briefs this chat as its worker, that brief wins and this note stops applying. Do not announce this role."
