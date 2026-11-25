---
name: claude-fable-review
description: Invoke Claude Fable 5 reliably for code review and verification. Use this skill whenever the user asks to ask Claude, get a Claude review, use Claude for verification, invoke Fable or Fable 5, compare another review with Claude, or diagnose an incomplete Claude CLI review. Force the canonical Fable route, validate the resolved model, allow enough time for substantive review, and reject opening-only responses.
---

# Claude Fable 5 review

Use Claude as an independent reviewer, then verify its claims against the
repository before reporting or implementing them. The objective is a complete
Fable 5 verdict, not merely a successful CLI exit.

## Preflight

1. Read the repository's own agent and project instructions first.
2. Check `claude --version` and `claude auth status`. Report only authentication
   method/provider and login state; never print tokens or credential values.
3. Do not infer the model from a friendly or internal route name. Validate the
   canonical model through structured usage metadata.

Run a low-cost routing probe when the model route has not already been verified
in the current environment:

```bash
timeout --signal=TERM --kill-after=10s 60s \
  claude --print --safe-mode --model fable --effort low \
  --no-session-persistence --output-format json \
  "Reply exactly FABLE5_OK. Do not use tools."
```

Treat the probe as successful only when:

- the result is `FABLE5_OK`;
- `subtype` is `success` and `is_error` is false; and
- at least one `modelUsage` entry reports `canonicalModel` as
  `claude-fable-5`. Confirm the expected provider as well when relevant.

Helper-model entries such as Haiku may also appear in `modelUsage`; they do not
invalidate the run as long as the substantive model is canonical Fable 5.

## Prepare the review input

Prefer supplying a frozen patch directly on stdin. This avoids plugin, hook,
workspace, and database side effects while ensuring Claude reviews exactly the
intended scope.

- For committed work, use the exact commit patch (`git show --stat --patch
  <sha>`).
- For uncommitted work, include `git diff --no-ext-diff`, the staged diff, and
  the contents of every relevant untracked file. `git diff` alone omits
  untracked files.
- Include the task intent, authoritative constraints, and the areas Claude
  should assess. Do not include secrets or client data that is outside the
  review scope.
- Tell Claude: "Return the final review in this turn; do not announce a plan."

## Invoke the substantive review

Use canonical Fable 5 explicitly even when a user setting already defaults to
Fable:

```bash
timeout --signal=TERM --kill-after=10s 300s \
  claude --print --safe-mode --model fable --effort medium \
  --no-session-persistence --tools "" --output-format json
```

Pass the review prompt and complete patch on stdin. Allow 180–300 seconds for a
real review; 30–60 second timeouts can terminate a healthy agentic review before
it produces a verdict. Poll long-running commands frequently enough to keep the
user informed.

Use high effort only when the user requests it or the review genuinely needs
the extra reasoning time. Medium effort is the reliable default for code
review.

## Accept or retry the result

A completed process is not automatically a completed review. Accept the result
only when all of these hold:

- structured output reports success without an error;
- `modelUsage` confirms canonical `claude-fable-5`;
- the visible result contains a verdict or findings, not just hidden reasoning;
  and
- the response addresses the requested review dimensions.

A response such as "I'll review this patch, starting with..." is incomplete,
even if the API ended normally. Retry once with the patch supplied directly,
safe mode, tools disabled, and an explicit same-turn final-answer instruction.
Do not describe an opening-only response as a successful review.

If the process times out, distinguish a caller timeout from authentication,
connectivity, or installation failure by checking CLI debug/session evidence
without exposing credentials.

## Triage Claude's findings

Claude's output is review input, not ground truth.

1. Verify each claimed issue against the actual repository and project scope.
2. Separate confirmed defects from incorrect assumptions and optional
   hardening.
3. Do not implement review suggestions unless the user requested fixes or the
   active task already authorizes them.
4. Report the model used, whether the review completed, confirmed findings, and
   any rejected findings with a short reason.

## Persistent default model

Only change a user's persistent Claude configuration when they ask for Fable 5
to be the default. Preserve every unrelated setting, set the model value to
`fable`, validate the JSON, and run a plain invocation without `--model` to prove
it resolves to canonical `claude-fable-5`.

Per-command `--model fable` remains the review standard because it makes the
model choice explicit and auditable.
