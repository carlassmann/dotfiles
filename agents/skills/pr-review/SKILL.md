---
name: pr-review
description: Review and remediate an implementation as an internal quality gate before creating or materially updating a GitHub pull request. Use when the agent owns the implementation and PR update, including repeated remediation passes and hands-on UI review. Do not use for review-only feedback.
---

# PR review

Find actionable problems before asking humans to review the PR.

This workflow assumes the agent is authorized to update the implementation and PR. For review-only requests, report findings without writes or a remediation loop.

## Review context

Review the full diff against the target branch and enough of the surrounding codebase to judge whether the change belongs:

- affected flows, callers, consumers, and tests
- shared abstractions and neighboring patterns
- relevant `CONTEXT.md`, ADRs, and repository instructions
- runtime behavior and integration boundaries

Stop at unrelated boundaries. The goal is architectural fit, not indiscriminate scanning.

Flag code that looks patched in: duplicated paths, one-off abstractions, inconsistent naming, unnecessary comments, or local conventions ignored by the change. Prefer structure, function boundaries, and names that explain the code. Keep comments only for rationale or constraints the code cannot express.

Before model review, run the checks required by repository instructions. In this repository, run `bun run lint`, `bun run format:check`, `bun run check`, and `bun run test`; run `bun run e2e` for covered flows and `/pre-pr-check` for data-pipeline changes. Keep routine check output out of the PR description.

## Independent reviewers

Use multiple independent reviewers with different models or harnesses. Prefer this order:

1. The adapters from a configured `counselors` group
2. Direct parallel calls to available agent CLIs such as `codex`, `claude`, and `opencode`
3. Different models available through the current harness

Expand and confirm the reviewer set with the user once per review session, then reuse it across remediation passes without asking again. This supersedes `counselors` agent-selection confirmation on later passes; dispatch the confirmed adapters directly. Prefer cross-harness diversity. Do not split reviewers into narrow roles; independent broad reviews expose different blind spots.

Create one isolated disposable worktree at the reviewed HEAD for each reviewer. In this repository, first create a temporary branch at the exact reviewed commit, then use `work create`; verify each worktree's HEAD before dispatch. Install only the capabilities the review needs. Use `bun install --frozen-lockfile` for local checks and `work setup` when the real app or its services are required.

Before setup, inspect the hook for external resources and require automatic expiration or a working teardown path. This repository's setup hook creates persistent Convex dev deployments that the CLI cannot delete. Do not run it for disposable reviewers until expiration or teardown is configured; use reviewer-safe staging access or ask the user for help instead.

Run one Counselor adapter or direct CLI from each reviewer's worktree instead of fanning the group out from the main worktree. Dispatch Counselor reviewers with `--read-only off` so they can run checks and the real app. Reviewers may run apps, tests, scripts, and experiments and may modify only their disposable worktree. They must not push or commit. Only the main agent applies findings.

After collecting reports, run `work down` for started workspaces, remove their worktrees and temporary branches, prune stale process records, and delete external resources created by setup. Never create an external resource without a known cleanup or expiration path.

Run reviewers concurrently when their harnesses and infrastructure permit it. Serialize tools that share a locked local store. Serialize hands-on LiveKit reviews and stop unrelated workspace agents first so they cannot steal each other's jobs.

For UI changes, every reviewer must run the real app and exercise the affected flow. Use the access order and credential rules from `pr-writing`; never include credentials in saved reports. Every report must state the URL, viewport, account source, and exercised flow. Missing runtime evidence fails the review. A diff-only UI review does not count.

## Findings

Each finding must include:

- severity
- confidence
- evidence
- a concrete failure scenario

Reject unsupported style preferences. A suggested fix may guide the main agent but must not prescribe a patch without justification.

The main agent confirms findings against the code and runtime, applies its own judgment, fixes valid findings, and records a concrete reason for rejections.

After fixes, start a fresh review pass against the new implementation. Prefer repeated `counselors run` passes over `counselors loop` because the code changes between passes. Continue until a full pass produces no confirmed actionable findings.

Review is an internal quality gate. Keep reviewer identities and process metadata out of the PR description. Mention only unresolved risks or deliberate tradeoffs.
