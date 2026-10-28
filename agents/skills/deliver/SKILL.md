---
name: deliver
description: Finish an implementation and hand it to humans through final runtime validation, review, checks, and a pull request. Use when the user says ship it, wrap up, finish, open a PR, make a PR, or prepare for review.
---

# Deliver

Prepare the implementation for a human merge decision. No new product scope unless correctness requires it. If the code is still prototype-grade, `$harden` first.

1. Resolve the target branch. Inspect full diff, working tree, linked issues, existing PR. Never guess a destructive or externally visible target.
2. Exercise affected behavior in the real runtime. For UI, test mobile and desktop and capture current screenshots.
3. Run all repository-required checks and affected E2E flows. Diagnose and fix failures.
4. Review the diff. One bounded cycle, described below. Not a loop.
5. Clean up: delete the temporary tests, or promote the ones worth keeping into the suite. Run `simplify` once for quality and readability. Re-run repository checks.
6. Create or update the PR: why, decisions, scope, tradeoffs, visual evidence, known risks. Apply `unslop`. Remove stale claims and screenshots.
7. Confirm final branch, push, PR, CI, and mergeability state.

Never merge unless asked. Never claim success without runtime and check evidence. Report outcome, verification, PR state, unresolved risks.

## Step 4: the review cycle

Exactly one hunt, one fix pass, one scoped verification. The budget is fixed before you start and does not expand because a pass found something.

**Hunt — one round.** Run `code-review` at `max` once. Get breadth by fanning out dimensions in parallel inside this round. Do not schedule a second hunt; a second hunt is the failure mode this protocol exists to prevent.

**Prove — the admission bar.** A finding is admitted only with evidence you produced by running something:

- a temporary test that fails on current code and passes after the fix, or
- a runtime observation — log line, HTTP response, screenshot, database row, or
- an input traced through actual execution to a wrong output.

An argued finding is not a finding. "This could be null", "this may race", "this might not scale" are admitted only once you have reached the state they describe. Reproduce first, fix second.

Credible but expensive to reproduce is a third outcome, not a reason to widen the cycle: write it in the PR body as a flagged risk and move on.

Record every rejected finding and the reason in a scratch ledger file. The verification pass reads it.

**Fix.** Address admitted findings. Keep each fix minimal and local to what the evidence showed. Commit before verifying so the fix diff is addressable.

**Verify — one round, scoped to the fixes.** Re-run the temporary tests and the repository checks. Review only `git diff <sha-before-fixes>`, looking for regressions the fixes introduced. This pass may not reopen the original diff and may not resurface anything in the ledger. Its only outcomes are: the fixes hold, or a specific fix is wrong — then correct that fix and re-run the checks, without widening scope.

**Stop.** After verification the review is over, whatever nagging remains. Remaining doubts belong in the PR body as known risks, where a human decides. The next reviewer is the human on the PR.
