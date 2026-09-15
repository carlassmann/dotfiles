---
name: deliver
description: Finish an implementation and hand it to humans through final runtime validation, review, checks, and a pull request. Use when the user says ship it, wrap up, finish, open a PR, make a PR, or prepare for review.
---

# Deliver

Prepare the implementation for a human merge decision. No new product scope unless correctness requires it. If the code is still prototype-grade, `$harden` first.

1. Resolve the target branch. Inspect full diff, working tree, linked issues, existing PR. Never guess a destructive or externally visible target.
2. Exercise affected behavior in the real runtime. For UI, test mobile and desktop and capture current screenshots.
3. Run all repository-required checks and affected E2E flows. Diagnose and fix failures.
4. Review the diff for defects (`code-review` or `counselors`). Confirm findings against code and runtime, fix valid ones, repeat until a fresh pass finds nothing.
5. Create or update the PR: why, decisions, scope, tradeoffs, visual evidence. Apply `unslop`. Remove stale claims and screenshots.
6. Confirm final branch, push, PR, CI, and mergeability state.

Never merge unless asked. Never claim success without runtime and check evidence. Report outcome, verification, PR state, unresolved risks.
