---
name: syntwin-dependency-bot
description: Run the scheduled syntwin-mono dependency upgrade workflow. Invoke only via $syntwin-dependency-bot.
disable-model-invocation: true
---

Find worthwhile dependency updates, adopt useful package features, and open focused PRs. Do not bump versions without understanding the change.

Use `/Users/carlassmann/Developer/syntwin-mono`.

## Scope

Inspect:

- root `package.json` and `bun.lock`
- `livekit/package.json` and `livekit/bun.lock`
- direct dependencies
- important transitive or security updates
- local dependency patches
- existing GitHub dependency PRs

Treat these ecosystems as groups when their versions move together:

- LiveKit agents and plugins
- Astro, Vite, and Cloudflare
- TanStack Router and its plugin
- AI SDK packages and providers
- React and React types
- Effect platform packages

`@livekit/agents` has a local patch. After an update, test whether it still applies and whether upstream made it obsolete. Remove or revise it only after validation.

## Research

1. Read `AGENTS.md`, relevant project docs, automation memory, and open PRs.
2. Skip updates already covered by a PR.
3. Skip versions unchanged since a previous failed analysis unless new evidence exists.
4. Find available updates and classify them as security, patch, minor, or major.
5. Read official release notes, changelogs, migration guides, and advisories.
6. Search every relevant import, configuration, workaround, adapter, and test.
7. Record compatibility risks, peer dependency constraints, runtime changes, and lockfile effects.

Look for concrete code changes enabled by the update:

- delete obsolete workarounds, wrappers, polyfills, or compatibility code
- replace custom code with package features
- remove redundant dependencies
- improve types, performance, reliability, or readability
- resolve related TODOs or deprecations

Do not invent a cleanup when the update offers none.

## Choose work

Prioritize security fixes, meaningful bug fixes, useful capabilities, and code deletion.

Version-only PRs are acceptable for security and meaningful bug fixes. Batch routine patches with no code benefit. Take major updates only when the migration is bounded and understood. Report broad, risky, or unclear migrations instead of forcing them.

Open at most two PRs. Never auto-merge or duplicate an existing dependency PR.

## Implement

1. Create a fresh worktree with `work`.
2. Run `work setup`.
3. Handle one cohesive dependency group per PR.
4. Implement only improvements unlocked by the update.
5. Avoid unrelated refactors and formatting churn.
6. Prefer deleting obsolete code over adding compatibility layers.
7. Keep the version update and adoption work in separate commits when practical.
8. Follow repository commit conventions. Never add AI attribution.

## Verify

Run focused tests plus:

- `bun run lint`
- `bun run format`
- `bun run check`
- `bun run test`
- `bun run build`

For changes to user-facing, auth, realtime, AI, or LiveKit flows, run the app with `work up` and exercise the affected browser or E2E flow.

Do not open a PR when the update causes failures. Prove and document any baseline failure that predates it.

Each PR must state:

- packages and versions changed
- whether code changes were required
- affected code paths
- improvements or deletions
- useful work considered but deferred

Use a focused title that names the dependency group.

## Finish the run

Report:

- PRs opened
- updates skipped and why
- blocked or risky migrations
- security findings
- verification results
- updates worth reconsidering later

Open no PR when no update earns one.

Stop every process started with `work`. Preserve required evidence and pushed work, then remove the exact temporary worktree through `work`. Do this on success, no-op, skip, and failure runs. Never remove the main workspace or another run's worktree.

Verify the directory and Git registration are gone. A clean worktree is not enough. If removal fails, retry safe cleanup, then report the remaining path, disk state, and manual cleanup command.

## Set the task title

After cleanup and before the final response, call the task-title tool.

Use one of these formats:

- `Dependencies: PR #123 short scope; #456 short scope`
- `Dependencies: no PR, concise reason`
- `Dependencies: blocked, concise reason`

Mention only PRs opened in this run.
