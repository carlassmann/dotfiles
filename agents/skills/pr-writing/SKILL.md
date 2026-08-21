---
name: pr-writing
description: Create or update focused GitHub pull requests with concise rationale, decisions, scope, and UI evidence. Use before opening a PR and after every material update to an open PR.
---

# PR writing

Own the PR lifecycle, not only its prose.

## Establish scope

Read the full diff against the target branch, the repository's PR template, surrounding code, and any linked issues.

Keep the PR focused on its main goal. Expand it only when required for correctness or to make the change fit the codebase naturally. Open follow-up issues for worthwhile independent work so it can proceed in smaller parallel increments.

Search for existing issues the PR may close. Link confirmed matches, but do not require an issue before opening a PR.

For every issue the PR closes, confirm its Definition of Done or Launch Criteria. Keep unmet items in scope or state them explicitly as exclusions; do not close an issue whose required outcome is incomplete.

## Review gate

Before opening a PR, use `pr-review`. The main agent confirms findings, fixes valid ones, and repeats fresh review passes until no confirmed actionable findings remain.

Repeat this gate after every material implementation update. Changes to behavior, APIs, schemas, dependencies, infrastructure, enforced test coverage, or UI are material. Description-only updates do not require another implementation review.

## UI gate

Do not open an agent-authored UI PR until the main agent has run the real app, exercised the affected flow, and reviewed it at desktop and mobile viewports.

Resolve access in this order:

1. Use an existing authenticated browser session.
2. Create a disposable staging user through established E2E or WorkOS tooling.
3. Ask the user for temporary staging access.

Never print, commit, or retain credentials. Clean up disposable users when practical. If the real UI still cannot be tested, stop and ask the user to take over PR creation.

For changed UI, include before-and-after screenshots. For new UI, after screenshots are enough. Always include desktop and mobile, name the viewport sizes, and capture the tested state.

Wrap visual evidence in `<details>` blocks. Prefer direct image upload. If tooling cannot upload images:

1. Add the screenshots in a dedicated commit.
2. Push it and record commit-pinned image URLs.
3. Remove the screenshots in the next commit.
4. Verify the commit-pinned images still render for intended reviewers.
5. Verify the final tree contains none of this PR's temporary screenshot assets.

Keep both commits in PR history so the pinned images remain available.

## Description

Use only relevant sections:

- Issue-closing links near the top
- `Why`
- `Approach and decisions`
- `Scope`
- `Visual evidence` for UI changes

Explain intent, root cause when useful, meaningful choices, tradeoffs, and boundaries. The code should explain its mechanics. Do not narrate files, list routine commands, add CI checklists, or mention reviewer models.

Use a title that states the delivered change. Apply `unslop` and keep the description concise.

When updating an open PR, reconcile these sections against the full current diff after every material push. Remove stale claims. Preserve human-authored notes and decisions unless explicitly superseded.
