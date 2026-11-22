# skills

Agent skills I write and use in Claude Code, Codex CLI and any other agent that
reads `skills/<name>/SKILL.md`. Each skill follows the
[Agent Skills spec](https://agentskills.io/specification).

There are no skills here yet.

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
scripts/sync.sh                 # copies every skill into the Claude Code and Codex folders
```

`validate.sh` needs [uv](https://docs.astral.sh/uv/). It runs on every push and
pull request too.

`sync.sh` replaces any skill of the same name in `~/.claude/skills` and
`~/.agents/skills`. Codex reads the second one.

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
.claude-plugin/               plugin manifest, read by both Claude Code and Codex
scripts/                      new-skill.sh, validate.sh, sync.sh
.github/workflows/            runs validate.sh in CI
```

## License

MIT. See [LICENSE](LICENSE).
