---
name: context7-docs
description: Look up current, version-specific docs for a third-party library, framework, SDK, CLI or cloud service through the Context7 MCP before writing, configuring, upgrading or debugging code that uses it. Use it whenever the task touches an external package's API or config (FastAPI, SQLAlchemy, Pydantic, React, TanStack Query, Vite, TypeScript, Azure SDKs, Bicep and the like), and especially when a version is named or pinned, a major version changed, an option may have been renamed or removed, or an error comes from inside a library. Use it even when you feel sure of the API, because confident code against an older version is the usual failure. Skip it for language built-ins, plain algorithms, SQL, and code that only touches the project's own modules.
---

# Context7 documentation lookup

Library APIs move faster than training data. Code that looks right but targets an older version (a renamed option, a removed flag, a changed signature) is the most common way library code goes wrong, and it fails late. Context7 serves the library's current docs and examples, so check there before writing against the API.

## Steps

1. **Find the version in use.** Read the project's pin (`pyproject.toml`/`uv.lock`, `package.json`/lockfile, `go.mod`, etc.) or take it from the user's message. If nothing pins it, assume the latest release.
2. **Resolve the library.** Call the Context7 MCP tool `resolve-library-id` (in Claude Code: `mcp__context7__resolve-library-id`) with the library name and what you are trying to do. Pick the match by name, reputation and snippet count. If it lists versions, use the `/org/project/version` ID that matches step 1.
3. **Query the docs.** Call `query-docs` (in Claude Code: `mcp__context7__query-docs`) with that ID and a specific question, such as "async engine dispose in a FastAPI lifespan handler" rather than "lifespan".
4. **Write the code from what came back.** Where the docs and your memory disagree, the docs win. Mention briefly which version you checked.

If Context7 doesn't index the library, or the result is thin, fall back to web search, the package's changelog, or the installed source (e.g. `site-packages/<pkg>`, `node_modules/<pkg>`), which is ground truth for the installed version.

## Limits

- At most 3 Context7 calls per question; then use the best result you have.
- One lookup per library per task is usually enough. Don't re-query for every line.
- Skip it for language built-ins, standard algorithms, and code that only calls the project's own modules.
