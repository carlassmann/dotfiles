---
name: syntwin-bug-issue-fixer
description: Run the scheduled syntwin-mono issue triage and bug-fix workflow. Invoke only via $syntwin-bug-issue-fixer.
disable-model-invocation: true
---

Triage GitHub issues and PRs several times each day. Fix at most three issues per run and open one PR per issue.

## Work in this order

1. Revisit Codex PRs with new human feedback, requested changes, unresolved review comments, or CI failures.
2. Revisit issues labeled `codex-needs-human` when a human commented after the blocker comment.
3. Inspect open issues labeled `bug` or `small`, plus issues of type `Bug`. QA bugs do not need the `small` label.
4. Claim and fix up to three eligible issues.

## Prepare the workspace

1. Create a fresh worktree with `work`.
2. Run `work setup`.
3. Run `work up`.

Keep each fix focused. Avoid unrelated refactors.

## Handle feedback first

Read unresolved review threads, requested changes, PR comments, and current CI results on Codex PRs.

Address clear feedback in the existing PR. Run the local CI equivalent, push the update, and reply with the change and verification. Ask a concise question on the PR when feedback is unclear.

For `codex-needs-human` issues, resume work only when a human has commented after the blocker. Remove the label and cite the new information. Otherwise skip the issue.

## Select and claim issues

Skip issues that have:

- `codex-needs-review`
- `codex-in-progress`
- `codex-pr-opened`
- an open linked PR
- a recent Codex reproduction or fix comment

Only the explicit `codex-needs-review` label blocks an otherwise eligible issue. Do not infer that review is required from size, risk, ambiguity, authorship, or scope.

Before reproducing an issue:

1. Add `codex-in-progress`.
2. Add a comment containing `<!-- codex-bug-job-claim: issue-number -->`.
3. Create missing automation labels when needed.

## Reproduce thoroughly

Reproduce UI-visible bugs through the UI. Server tests are supporting evidence and cannot disprove a UI bug. Create representative local data for failures tied to old or unusual accounts.

Capture useful screenshots, console output, network or server errors, and terminal logs.

If reproduction fails after a serious attempt, remove `codex-in-progress` and comment with the steps and evidence. Add `codex-needs-human` only when user information is required.

## Complete authentication

Sign-in is not a stopping point.

1. Inspect repository docs, scripts, Playwright setup, auth helpers, seed scripts, tests, and env conventions.
2. Treat `/Users/carlassmann/Developer/syntwin-mono` as the source of truth for local test configuration.
3. Copy or load only the values the worktree needs. Never commit env files.
4. Prefer environment WorkOS API keys for disposable test users and organizations.
5. Use existing test credentials, magic links, dev auth, session seeding, API login, or test helpers when available.

Never print secrets. Mention missing variable names, not values.

If authentication still fails, comment with the attempted methods, missing variable names, and next unblocker. Add `codex-needs-human`.

## Fix and verify

For each reproduced issue:

1. Comment once with exact steps, observed behavior, environment, logs, and screenshots.
2. Implement a focused fix.
3. Inspect workflows and package scripts to identify the local CI equivalent.
4. Run relevant tests, type checks, lint and format checks, builds, and focused E2E or smoke tests.
5. Open a ready-for-review PR that links the issue and contains reproduction evidence and verification.
6. Confirm GitHub reports `isDraft=false`.
7. Remove `codex-in-progress` and add `codex-pr-opened`.

Do not open or update a PR when the change breaks local checks. If a failure predates the change, prove that and record it in the issue comment and PR.

Add a regression test only when it protects meaningful behavior through a stable, fast, deterministic seam and catches a plausible recurrence. Prefer existing coverage when it already exercises the failure. The PR must say whether a regression test was added and, if not, why.

A local fix is not complete. Continue through commit, push, PR creation, labels, and cleanup. Retry safe alternatives when a completion step fails. If still blocked, report the exact failure and next unblocker.

## Finish the run

Before responding, verify every successful fix has:

- a commit and pushed branch
- a ready-for-review PR
- the `codex-pr-opened` label
- stopped processes
- a removed temporary worktree

List every created or updated PR URL. If there are none, name each skip or blocker.

Stop every process started with `work`. Preserve required evidence, commits, branches, PRs, and issue comments. Remove the exact temporary worktree through `work`, even on no-op, skip, or failure runs. Never remove the main workspace or another run's worktree.

Verify the directory and Git registration are gone. If removal fails, retry safe cleanup, then report the remaining path, disk state, and manual cleanup command.

## Set the task title

After cleanup and before the final response, call `codex_app__set_thread_title`. Retry once on failure, then report the error.

Use one of these formats:

- `Bugfix: PR #123 issue #456 short scope; #789 issue #101 short scope`
- `Bugfix: updated PR #123 short scope`
- `Bugfix: no PR, concise reason`
- `Bugfix: blocked, concise reason`

Mention only PRs opened or updated in this run.
