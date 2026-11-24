#!/usr/bin/env bash
# Roll call for agent chats that run in tmux. Run it from the leader's own pane,
# inside the project. It enrols every other agent session in the project as
# "worker N" of this session and asks each one to reply.
#
#   rollcall.sh          enrol and message the workers, then print the roster
#   rollcall.sh --list   print the roster without changing or sending anything
#
# The marks are tmux session options, so they go away when a session ends:
#   @leads <project dir>  on the leader
#   @worker_of <leader>   and  @worker_no <n>  on each worker
# A session that leads, or that works for another live leader, is left alone.
set -euo pipefail

[[ -n ${TMUX_PANE:-} ]] || { echo "rollcall: run this inside the leader's tmux pane" >&2; exit 1; }
list_only=""; [[ ${1:-} == --list ]] && list_only=1
me=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)

declare -A number=() note=()
sessions=() taken=" "
while IFS='|' read -r s path pid leads worker_of worker_no; do
  [[ $s == "$me" || -n ${note[$s]:-} ]] && continue
  [[ $path == "$root" || $path == "$root"/* ]] || continue
  sessions+=("$s")
  if ! pgrep -P "$pid" > /dev/null; then
    note[$s]="skipped: a bare shell, no agent running"
  elif [[ -n $leads ]]; then
    note[$s]="skipped: it leads its own roll call"
  elif [[ -n $worker_of && $worker_of != "$me" ]] && tmux has-session -t "=$worker_of" 2> /dev/null; then
    note[$s]="skipped: worker $worker_no of $worker_of"
  elif [[ $worker_of == "$me" && -n $worker_no ]]; then
    number[$s]=$worker_no; taken+="$worker_no "; note[$s]="already enrolled"
  else
    note[$s]="new"
  fi
done < <(tmux list-panes -a -F '#{session_name}|#{pane_current_path}|#{pane_pid}|#{@leads}|#{@worker_of}|#{@worker_no}')

n=1
for s in "${sessions[@]}"; do
  [[ ${note[$s]} == new ]] || continue
  while [[ $taken == *" $n "* ]]; do n=$((n + 1)); done
  number[$s]=$n; taken+="$n "
done

if [[ -z $list_only ]]; then
  call=$RANDOM   # in each reply, so an old reply still on screen is not counted
  tmux set-option -t "=$me:" @leads "$root"
  for s in "${sessions[@]}"; do
    [[ -n ${number[$s]:-} ]] || continue
    k=${number[$s]}
    tmux set-option -t "=$s:" @worker_of "$me"
    tmux set-option -t "=$s:" @worker_no "$k"
    msg="Roll call from the leader chat for this project (tmux session $me), sent at the user's request. You are worker $k for this leader. This is not a task and it changes nothing about what you are doing with the user: carry on, and expect briefs from session $me later. Confirm now with two separate commands, one second apart: tmux send-keys -t '=$me:' -l 'Worker $k ready ($s, call $call). ' and then: tmux send-keys -t '=$me:' Enter"
    tmux send-keys -t "=$s:" -l "$msg"
    sleep 1
    tmux send-keys -t "=$s:" Enter
  done
  # Replies are typed into this pane. Wait up to a minute for all of them to show.
  for _ in $(seq 30); do
    screen=$(tmux capture-pane -p -J -t "$TMUX_PANE")
    waiting=0
    for s in "${sessions[@]}"; do
      [[ -n ${number[$s]:-} ]] || continue
      if [[ $screen == *"Worker ${number[$s]} ready ($s, call $call)"* ]]; then
        note[$s]="replied"
      else
        note[$s]="no reply seen yet"; waiting=1
      fi
    done
    [[ $waiting == 1 ]] || break
    sleep 2
  done
fi

echo "leader: $me   project: $root"
for s in "${sessions[@]}"; do
  if [[ -n ${number[$s]:-} ]]; then
    echo "worker ${number[$s]}: $s (${note[$s]}${list_only:+, not messaged})"
  else
    echo "-: $s (${note[$s]})"
  fi
done
[[ ${#sessions[@]} -gt 0 ]] || echo "no other sessions in this project"
