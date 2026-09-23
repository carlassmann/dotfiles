## Communication

Be extremely (!!!) concise. Sacrifice grammar for concision.

In the CLI, print full URLs as plain text. Never hide them behind markdown link text; I can't see or click those.

When writing on my behalf (Slack, GitHub, commits, anywhere), sign with harness and model, e.g. `written with claude-opus-5 in opencode`.

## Product development

Learn through small, realistic implementations, not extended speculative design.

When architecture is uncertain, build the smallest reversible vertical slice and exercise it in the real runtime.

Never block implementation on a question a cheap experiment can answer. Never let exploratory code become production architecture without a conscious review.

## Code

Optimize for readability. Prefer descriptive names and small functions over comments; code should show WHAT it does. Add a comment only to explain WHY, when that isn't obvious.

## Tooling

- `work`: manages project processes (dev servers, watchers) and sets up worktrees via the configured setup hook.
- `agent-browser`: the only browser to use, always in the background, unless told otherwise.

## Reference repositories

Read-only reference repos live in `.reference/` or `.references/`. When asked for examples or patterns not in this project, search there first.

- `jazz`: local-first synced database
- `tilly`: mobile-optimized PWA built with jazz and the AI SDK
- `alkalye`: offline-capable PWA built with jazz
- `blog`: my personal blog
