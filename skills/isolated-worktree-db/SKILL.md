---
name: isolated-worktree-db
description: Create, run, and safely clean up an isolated Git worktree with its own local database, Docker Compose project, ports, and runtime configuration. Use whenever experimental or parallel development must start from committed main without inheriting another agent's uncommitted changes, especially when the work needs database migrations, seeded/cloned data, a local server, or disposable containers.
---

# Isolated Worktree and Database

Create a disposable development environment that cannot modify the primary worktree's uncommitted files or share its database accidentally. Adapt commands to the repository's existing tooling; isolation guarantees matter more than a particular Compose layout.

## Establish the boundary

1. Read the repository's agent/project instructions before acting.
2. Resolve the primary worktree, repository common directory, current branch, requested base, and all existing worktrees with read-only Git commands.
3. Inspect the primary worktree status. Treat every local modification there as belonging to someone else: do not stash, copy, commit, reset, or base the experiment on it.
4. Default the base to the committed `main` HEAD unless the user names another committed ref. Resolve and record the exact commit SHA.
5. Choose unique, explicit identifiers for the worktree path, branch, Compose project, database name, container resources, and host ports. Never reuse the primary environment's identifiers.

Use a sibling worktree path such as `<repo>-<slug>` and a branch such as `experiment/<slug>`. Create it from the recorded commit, not from working-tree contents:

```bash
git worktree add -b experiment/<slug> /absolute/path/<repo>-<slug> <base-commit>
```

Do not force, overwrite, or delete an existing path or branch to make this command succeed. Pick a new slug or stop and explain the collision.

## Isolate the database

Inspect the project first, then use its native database tooling where possible.

- Give Docker Compose a unique project name. Avoid fixed `container_name` values.
- Bind database and application ports to `127.0.0.1` on confirmed-free host ports.
- Use a dedicated database name and dedicated volume or `tmpfs`; never point the experimental app or tests at the primary database.
- Keep the isolation configuration in the experimental worktree. Do not edit the primary worktree to support the experiment.
- Reuse local secrets only through an existing ignored environment mechanism. Never copy secrets into tracked files or print them.
- Prefer migrations plus project seeds for an empty database. If representative local data is required, clone only an authorized local development database with the database's dump/restore tooling. Never infer permission to copy production data.
- Set both application and test database URLs explicitly. Verify them before migrations, jobs, tests, or servers run.

Create a small untracked `.codex-isolation.json` manifest in the worktree containing the non-secret identifiers needed for exact cleanup: primary path, worktree path, branch, base commit, Compose file/project, service names, database name, host ports, and any server PID/session identifier. Do not store passwords or full credential-bearing URLs.

## Verify before development

Confirm all of the following and report the useful endpoints to the user:

- the new worktree HEAD equals the recorded base commit;
- primary uncommitted files do not appear in the new worktree;
- the dedicated database is healthy and reachable only through its chosen local port;
- application and test configuration resolve to the dedicated database;
- the chosen application port is free before starting the server;
- repository instructions, migrations, and proportionate smoke tests pass.

When serving the experiment, keep the process identifier in the manifest and use a separate application port. Do not stop or replace an unknown process occupying a desired port; select another port.

## Work safely

Make experimental edits only inside the new worktree. Before commands that can enqueue jobs or start workers, confirm they cannot consume the primary environment's queue, storage, or database. Disable background workers when they are unnecessary for review.

Keep the work local unless the user separately asks to commit, push, open a PR, or deploy. A request to experiment does not authorize publication.

## Clean up exactly

Clean up only when the user asks. Read the manifest and independently verify each target before deletion.

1. Stop only the server processes recorded for this worktree.
2. Run Compose `down` using the exact worktree Compose file and exact project name. Include volumes only when the user has asked to discard the isolated database.
3. Verify that no containers or volumes carrying that Compose project label remain.
4. Inspect the experimental worktree status and state clearly if uncommitted work will be irrecoverably discarded. Preserve or commit it only if the user requests that.
5. Remove the exact absolute worktree path through `git worktree remove`; use `--force` only when explicit deletion includes uncommitted experiment files.
6. Prune stale worktree metadata and verify the primary worktree status is unchanged.
7. Keep the experiment branch by default. Delete it only when the user explicitly requests branch deletion.

Never use broad recursive deletion, unresolved variables, globs, the repository root, or the home directory as cleanup targets. Finish with a concise inventory of what was removed, what remains (especially the branch), and whether discarded data is recoverable.

## Example requests

- “Try this in another worktree with a separate Docker database, based on committed main.”
- “Set up an isolated local environment so you do not include the other agent's edits.”
- “Remove the experiment worktree and its database container when you are done.”
