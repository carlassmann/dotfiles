---
name: syntwin-nightly-qa
description: Run the scheduled syntwin-mono exploratory QA workflow. Invoke only via $syntwin-nightly-qa.
disable-model-invocation: true
---

Test the latest remote `main` as a real user. File GitHub issues only for new, confirmed findings.

## Prepare a current workspace

1. Read automation memory. Rotate toward recent changes and areas with weak coverage.
2. Fetch `origin` and resolve the current `origin/main`.
3. Create a fresh worktree from that exact commit with `work`.
4. Confirm `HEAD` equals `origin/main`, the worktree is clean, and record the full commit SHA.
5. If fetch, checkout, or verification fails, report it. Never test stale code.
6. Run `work setup`, then `work up`.
7. Use the URL from `work urls`. Treat a broken work subdomain, proxy, or redirect as a finding. Use plain localhost only as a documented fallback.
8. Authenticate fully. Sign-in is not a stopping point.

Inspect repository docs, scripts, tests, Playwright setup, auth helpers, seed scripts, and env conventions. Use `/Users/carlassmann/Developer/syntwin-mono` as the source of truth for local test configuration. Copy or load only what the worktree needs. Never commit env files.

Prefer environment WorkOS API keys for disposable test users and organizations. Use configured reusable test credentials when appropriate.

## Explore the product

Spend at least 30 minutes actively using the app in the in-app browser. Setup, tests, retries, GitHub triage, and log review do not count.

Cover basic health across the authenticated shell, dashboard, deployments, interactions, sources and rules, people and sessions, and settings. Then go deep on one rotating area.

Exercise realistic flows, edge cases, validation, reloads, empty states, loading states, failures, keyboard use, and at least one mobile viewport. Capture screenshots or other evidence for reproducible findings.

This run is report-first. Document an issue before attempting a small fix. Do not let fixes replace exploration.

After exploration, run targeted tests plus `bun run lint`, `bun run format`, `bun run check`, and `bun run test`. Run E2E tests when relevant and time allows.

## Triage findings

Before filing, search open and closed issues, issue types, epics, tasks, bug reports, linked PRs, discussions, and comments. Search by symptoms, flows, UI copy, errors, and likely code areas. Exact-title search is insufficient.

Treat an item as a duplicate when it describes the same underlying defect or requested improvement. Add a comment only when this run contributes a new reproduction path, regression, environment detail, screenshot, logs, or severity change.

Create one issue per new, actionable finding. Do not file suspicions, test-infrastructure noise, vague observations, or suggestions without a clear user outcome and acceptance criteria.

Use the repository's existing issue types and labels. Create automation labels only when required.

- Give confirmed product bugs the `bug` label or Bug issue type.
- Add `small` only when a bug is reproducible, bounded, low-risk, and has clear acceptance criteria. Do not add `codex-needs-review`.
- Add `codex-needs-review` to larger, ambiguous, high-risk, architectural, UX, or accessibility work that needs product judgment. Do not add `small`.
- When uncertain, use `codex-needs-review`.

A short report does not make a bug small.

## Write useful issues

Use a title that names the symptom and affected flow.

Include:

- QA date and tested `origin/main` SHA
- category, severity, and confidence
- affected flow
- exact reproduction steps
- expected and actual behavior
- evidence and environment
- likely code area when supported by evidence
- acceptance criteria

Add the smallest concrete example needed to reproduce the failure. For model behavior, include the relevant transcript and tool activity. For validation or runtime failures, include exact safe inputs, status codes, response payloads, and reload behavior. For remediation regressions, include the relevant before and after excerpts.

Attach screenshots when they materially show the failure. Upload them to GitHub. A local path alone is not useful to collaborators. Skip screenshots and long transcripts that add no diagnostic value.

Redact secrets and sensitive production data. Use disposable identities and safe values. Never expose machine-only sensitive paths.

Include every created or updated issue URL in the final report.

## Report and clean up

Report the tested SHA, active exploration time, automated-test time, areas covered, and confidence. Order findings by severity.

For each finding, include its title, severity, confidence, affected flow, reproduction, expected and actual behavior, evidence path, likely code area when known, GitHub disposition, and issue URL.

Separate product bugs, reliability or test-infrastructure failures, and improvement ideas. Summarize searches, duplicate matches, updated issues, created issues, and findings not filed. Name setup failures, remaining risks, untested areas, and the best next focus. If no bugs were found, list the exact flows, states, and edge cases tested. Report every check result.

Update automation memory with coverage, findings, tested SHA, issue URLs and dispositions, and runtime.

Stop every process started with `work`. Preserve useful artifacts, then remove the exact temporary worktree through `work`. Do this on success, no-op, skip, and failure runs. Never remove the main workspace or another run's worktree.

Verify the directory and Git registration are gone. A clean worktree is not enough. If removal fails, retry safe cleanup, then report the remaining path, disk state, and manual cleanup command.
