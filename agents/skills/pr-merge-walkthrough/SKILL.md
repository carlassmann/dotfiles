---
name: pr-merge-walkthrough
description: Go through pull requests that need a decision, one at a time. Summarize what each one changes about the product, try it in the running app, and leave a browser open at the spot where the user can look at it. Do not use for autonomous bulk merging.
---

# PR merge walkthrough

Prepare one merge decision at a time. Never merge. Push only the base merge from step 4, unless asked.

1. **Pick.** PRs awaiting the user (review-requested, assigned, mentioned), oldest first, drafts skipped. List the queue with URLs once, then take the first.
2. **Understand.** Read diff, linked issue, review comments, CI. Say what a user can now do, see, or stop hitting. Note overlap with merged work or other queued PRs.
3. **Weigh.** Every merged line is a burden we maintain forever; a PR must be worth it. Count product and test lines (`git diff --numstat`, generated files apart). Estimate what the smallest version with the same user value would need, and name each part that doesn't pay for itself (speculative cases, duplicate paths, legacy handling, extra UI states, persisted fields). Note what is hard to undo after merge (schema fields, public API). Question whether the feature is worth having at all. A working PR that is much heavier than its value is a revise, not a merge.
4. **Check out.** Reuse the current worktree; check out the branch, merge base into it, resolve conflicts, push the merge commit to the PR branch (follow repo push rules, e.g. CI signoff), run checks via `work`. Conflicts are routine, never a reason to revise. Stop and ask only when both sides change the same behavior differently.
5. **Try it.** Product-visible change: drive the app through the touched flow, desktop and mobile, screenshots. Internal change: run checks and say there is nothing to look at. Report breakage, don't quietly fix it.
6. **Park.** Leave app and browser open on the exact screen and state where the change shows. Tell the user URL, account, clicks, and what to watch for.
7. **Hand back.** PR URL, then in this order, plain language, no check logs:
   - **Conclusion:** merge, revise, skip, or close, in one sentence with the main reason. Correctness alone is not enough to merge: the weight from step 3 must fit the value.
   - **Weight:** lines (product / tests) against the estimated minimal version, and the parts to cut.
   - **Why it exists:** one sentence: "This PR solves <problem> by changing <approach>."
   - **Why this call:** the few findings that decide it (breakage seen, failing gates, what nobody verified). Link evidence; skip passing checks unless they matter.
   - **Look:** parked URL, account, clicks, what to watch for.

Then stop. Fix defects, push, or edit the description only when asked.
