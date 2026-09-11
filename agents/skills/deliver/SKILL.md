---
name: deliver
description: Deliver a completed code implementation through final runtime validation, quality review, checks, and pull-request handoff. Use when the user asks to finish, ship, or prepare work for human review.
---

# Deliver

Prepare the implementation for a human merge decision. Do not introduce new product scope unless required for correctness.

1. Resolve the intended target branch and inspect the full diff, working tree, linked issues, and existing pull request. Never guess a destructive or externally visible target.
2. Exercise affected behavior in the real runtime. For UI changes, test relevant mobile and desktop states and capture current visual evidence.
3. Run all repository-required checks and affected end-to-end flows. Diagnose and fix failures.
4. Use the applicable `pr-review` quality gate. Validate findings, fix confirmed issues, and repeat fresh heterogeneous review passes until no confirmed actionable findings remain.
5. Use `pr-writing` to create or update a concise pull request centered on why, meaningful decisions, scope, tradeoffs, and visual evidence. Remove stale claims and screenshots.
6. Confirm the final branch, push, pull-request, CI, and mergeability state.

Never merge unless explicitly requested. Never claim success without runtime and check evidence. Report delivered outcome, verification, pull-request state, and unresolved risks.
