---
name: pr-merge-walkthrough
description: Go through pull requests that need a decision, one at a time. Summarize what each one changes about the product, try it in the running app, and leave a browser open at the spot where the user can look at it. Do not use for autonomous bulk merging.
---

# PR merge walkthrough

Prepare one merge decision at a time. Never merge. Never push unless asked.

1. **Pick.** PRs awaiting the user (review-requested, assigned, mentioned), oldest first, drafts skipped. List the queue with URLs once, then take the first.
2. **Understand.** Read diff, linked issue, review comments, CI. Say what a user can now do, see, or stop hitting. Note overlap with merged work or other queued PRs.
3. **Check out.** Reuse the current worktree; check out the branch, merge base in locally, run checks via `work`. Name conflicting behaviors before resolving anything.
4. **Try it.** Product-visible change: drive the app through the touched flow, desktop and mobile, screenshots. Internal change: run checks and say there is nothing to look at. Report breakage, don't quietly fix it.
5. **Park.** Leave app and browser open on the exact screen and state where the change shows. Tell the user URL, account, clicks, and what to watch for.
6. **Hand back.** PR URL first, then: product change, conflicts, what you tried and saw, what nobody verified, a call (merge, revise, skip, close).

Then stop. Fix defects, push, or edit the description only when asked.
