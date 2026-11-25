# skills

Agent skills I write or adapt and use in Claude Code, Codex CLI and any other agent
that reads `skills/<name>/SKILL.md`. Each skill follows the
[Agent Skills spec](https://agentskills.io/specification).

## Skills

- [`leader`](skills/leader/SKILL.md): lead other agent sessions from one chat. When
  to hand work off, how to brief a worker, how to watch it and how to verify its
  result. Includes a roll call script for chats that run in tmux, and a Claude Code
  start-up hook that tells a chat it is the leader.
- [`gauntlet`](skills/gauntlet/SKILL.md): verify a finished code change with the full
  check stack (tests, types, lint, changed-line coverage, review).
- [`create-verification-skill`](skills/create-verification-skill/SKILL.md) and
  [`maintain-verification-skill`](skills/maintain-verification-skill/SKILL.md): give a
  project its own skill for driving the app the way a user does, and keep it honest.
- [`old-coder`](skills/old-coder/SKILL.md): evidence-first development, with an
  executable spec and checks around the implementation.
- [`bugfix`](skills/bugfix/SKILL.md): ticket to verified fix for one bug.
- [`simplify`](skills/simplify/SKILL.md): simplify code without changing what it does
  (for Codex; Claude Code has its own `/simplify`).
- [`deslop`](skills/deslop/SKILL.md) and [`unslop`](skills/unslop/SKILL.md): remove
  AI slop from code and AI tells from writing.
- [`claude-fable-review`](skills/claude-fable-review/SKILL.md): have Codex ask Claude to
  review its work.
- [`context7-docs`](skills/context7-docs/SKILL.md): look up current library docs
  through the Context7 MCP before using a library.
- [`isolated-worktree-db`](skills/isolated-worktree-db/SKILL.md): a git worktree with
  its own database and Docker Compose project, cleaned up safely.

### Credits

`create-verification-skill`, `maintain-verification-skill`, `deslop` and `unslop` are by
Lauren Tan ([poteto/plugins](https://github.com/poteto/plugins)), MIT; each folder keeps
its licence or source note. `old-coder` and parts of `gauntlet` are adapted from
[AmazingAng/old-coder](https://github.com/AmazingAng/old-coder), MIT.

### Leader start-up hook

`skills/leader/scripts/session-start.sh` is a Claude Code SessionStart hook that tells
an interactive chat it is the leader, so you don't have to type `/leader`. Register it
in `~/.claude/settings.json`, with the path your install method gave the skill:

```json
{ "hooks": { "SessionStart": [ { "hooks": [
  { "type": "command", "command": "bash ~/.claude/skills/leader/scripts/session-start.sh" }
] } ] } }
```

Add part of a model id as an argument (`session-start.sh opus`) and only chats on that
model lead. Start a worker with `LEADER_ROLE=worker` in its environment and the hook
stays quiet for it. A chat that a roll call enrolled is told it is that leader's
worker instead, including after `/clear`. Headless runs (`claude -p`) never get the note.

## Install

With the [`skills` CLI](https://github.com/vercel-labs/skills), which asks which
skills and which agents you want:

```bash
npx skills add UsmanBuk/skills
```

Add `--skill <name>` for one skill, or `-a codex` to target one agent.

As a Claude Code plugin:

```
/plugin marketplace add UsmanBuk/skills
/plugin install usmanbuk@usmanbuk-skills
```

As a Codex plugin, from the same manifest:

```bash
codex plugin marketplace add UsmanBuk/skills
codex plugin add usmanbuk@usmanbuk-skills
```

Or copy a skill folder by hand into `~/.claude/skills/` for Claude Code or
`~/.agents/skills/` for Codex.

Use one method per machine. Codex lists a skill twice if it finds it in two
places.

## Add a skill

```bash
scripts/new-skill.sh my-skill   # creates skills/my-skill/SKILL.md
scripts/validate.sh             # checks every skill against the spec
scripts/sync.sh                 # links every skill into the Claude Code and Codex folders
```

`validate.sh` needs [uv](https://docs.astral.sh/uv/). It runs on every push and
pull request too.

`sync.sh` replaces any skill of the same name in `~/.claude/skills` and
`~/.agents/skills` (Codex reads the second one) with a symlink into this repo, so an
edit here is live at once. `targets.conf` limits a skill to one tool; an unlisted skill
goes to both. It also links skills from `private-skills/`, which is git-ignored, for
skills that stay on your own machine.

The spec rules that trip people up:

- `name` is lowercase letters, digits and hyphens, 64 characters at most, and
  equal to the folder name.
- `description` is 1024 characters at most. Say what the skill does and when
  the agent should use it, because the agent reads only this line when it
  decides whether to load the skill.
- Keep `SKILL.md` under 500 lines. Put long material in `references/`, code in
  `scripts/` and templates in `assets/`, and link to them from `SKILL.md`.

## Layout

```
skills/<name>/SKILL.md        one folder per skill
private-skills/<name>/        your own unpublished skills (git-ignored)
targets.conf                  which tools sync.sh links a skill into
.claude-plugin/               plugin manifest, read by both Claude Code and Codex
scripts/                      new-skill.sh, validate.sh, sync.sh
.github/workflows/            runs validate.sh in CI
```

## License

MIT. See [LICENSE](LICENSE).
