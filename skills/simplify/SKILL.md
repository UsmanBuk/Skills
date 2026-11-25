---
name: simplify
description: Simplify existing code without changing its intended behavior. Use when the user invokes $simplify, asks to simplify or clean up the current diff, reduce unnecessary complexity or duplication, improve reuse/readability/efficiency, or requests behavior like Claude's /simplify workflow. Default to uncommitted changes unless the user names another scope. Do not use for net-new feature work, broad redesigns, or formatting-only requests.
---

# Simplify

Make the smallest behavior-preserving improvements that leave the selected code easier to
understand, maintain, and execute. Treat a smaller diff as a constraint, not an objective by
itself: do not trade correctness or clarity for fewer lines.

## Establish scope and baseline

1. Read applicable repository instructions before evaluating code.
2. Resolve the scope in this order:
   - Use the files, commit, branch, or PR explicitly named by the user.
   - Otherwise use staged, unstaged, and untracked code in the current repository.
   - If the working tree is clean, ask for a scope instead of simplifying unrelated code.
3. Inspect the full changed functions and their important callers, not only diff hunks.
4. Preserve pre-existing user changes and exclude generated, vendored, and unrelated files.
5. Identify the narrowest relevant validation commands. Run a baseline check when practical;
   record unrelated failures instead of silently absorbing them into the task.

## Review in three lanes

When subagents are available, run these lanes in parallel as read-only reviewers. Give each
reviewer the raw diff and relevant files, not proposed answers. Keep all editing in the main
agent. When subagents are unavailable, perform the same lanes sequentially.

### Reuse

- Find new logic that duplicates an existing helper, constant, type, query, component, or
  established project pattern.
- Prefer a well-matched existing abstraction over adding another one.
- Consolidate duplication only when the shared concept is stable and the result is clearer.
- Do not create generic helpers for a single speculative future use.

### Quality

- Look for avoidable branches, nesting, state, indirection, weak names, stale comments, leaky
  abstractions, and error handling that obscures the main path.
- Preserve public contracts, error semantics, authorization boundaries, persistence behavior,
  and user-visible behavior unless the user explicitly authorizes a change.
- Prefer direct control flow and explicit data shapes over clever compression.
- Remove dead code only when the selected scope proves it unreachable or unused.

### Efficiency

- Find repeated I/O, duplicate queries, unnecessary renders or allocations, redundant passes,
  and obviously poor algorithmic work introduced or exposed by the selected changes.
- Optimize only where the benefit is concrete. Avoid caching, concurrency, batching, or data
  model changes without evidence that they are safe and useful.
- Do not turn a simplification pass into a performance project.

## Decide what to change

For every finding, require all of the following:

- The current code provides concrete evidence of the issue.
- The proposed edit reduces complexity, duplication, or unnecessary work.
- Intended behavior and external contracts remain unchanged.
- The improvement is proportionate to the risk and diff size.
- A relevant check can verify the result, or the limitation can be stated clearly.

Skip subjective rewrites, broad renames, dependency swaps, architecture changes, style churn,
and abstractions justified only by possible future needs. If nothing meets the bar, make no
code changes and report that the code is already appropriately simple.

## Implement

1. State the simplifications worth making and the behavior that must remain invariant.
2. Apply one surgical group of edits at a time.
3. Keep comments only for non-obvious intent; update comments that no longer match the code.
4. Do not modify generated files or unrelated lint/test failures.
5. Do not commit, push, open a PR, or mutate tickets unless the user separately requests it.

## Verify

1. Re-read the final diff and confirm every changed line serves the simplification.
2. Run focused tests for changed behavior, followed by broader checks in proportion to risk.
3. Run formatter, type, lint, and diff-whitespace checks applicable to touched files.
4. Compare against the baseline and distinguish new failures from existing failures.
5. If behavior preservation cannot be demonstrated, revert or revise the risky simplification.

## Report

Lead with whether the code was simplified and is ready for review. Summarize:

- Simplifications applied and why they are clearer or cheaper.
- Validation performed and exact outcomes.
- Findings deliberately not changed because they were speculative, behavioral, or out of scope.
- Any remaining risk or pre-existing failure.

Keep the report concise. Do not praise churn or report line-count reduction as proof of quality.
