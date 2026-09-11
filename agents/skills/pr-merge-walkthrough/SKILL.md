---
name: pr-merge-walkthrough
description: Go through pull requests that need a decision, one at a time. Summarize what each one changes about the product, try it in the running app, and leave a browser open at the spot where the user can look at it. Do not use for autonomous bulk merging.
---

# PR merge walkthrough

Make it cheap for the user to decide on a PR. Never merge. Never push unless asked.

## Pick the PR

Default to PRs needing the user's attention: review-requested, assigned, or mentioned. Oldest first, drafts skipped. Use the user's own PRs instead when they say so, and keep that choice for later "next PR" requests.

List the queue once, one line each. Then take the first PR and stop there.

## Read it

Read the PR, its linked issue, the full diff, current base, and checks.

Say what it does in product terms, not file terms: what can a user now do, see, or stop hitting. If merged work already covers it, show the overlap and suggest closing.

Then decide which kind it is:

- Product-visible. UI, copy, flows, API responses. Try it and set up the browser.
- Internal only. Refactors, infra, types, tests. Reason about it, run the checks, and say there is nothing to look at.

## Run it

Work in the current worktree and reuse it for every PR in the walkthrough. Do not create one per PR.

Check out the PR branch here, and use `work` for the dev server, services, URLs, and logs. Leave those running between PRs and restart only when the branch needs it. Before switching branches, drop the last PR's local merge and leave the tree clean.

Merge current base in locally. Three things can turn up:

- conflicts git reports
- conflicts git does not report, where both changes survive and the result is duplicated or contradictory
- unrelated base changes that need no decision

Before resolving anything meaningful, say which behaviors collide. Keep current product behavior unless the PR means to replace it.

## Try it yourself

Confirm it works by watching it work. A green test suite is not that.

- Drive the app to the state the PR touches and do the thing a user would do.
- Do the same on base when the question is whether anything actually changed.
- For UI, check desktop and mobile, and take fresh screenshots.
- Follow the browser skill when driving a browser.
- Use `test-guidance` for test decisions, at the cheapest tier that helps.
- Use throwaway accounts and seed data when needed, and say what you created.

When something breaks, work out whether the PR, the base, or the local setup caused it. Report it instead of quietly fixing it.

Keep three things apart in the report: what you tried, what the checks covered, what nobody verified.

## Set up the browser

For product-visible changes, leave everything running and parked on the change.

- Keep the app and the browser up until the user moves on.
- Open the exact screen where the change shows, with the seed data or test account already in place.
- If it only shows up in a specific state, a flag, a role, an empty list, an error, set that state up instead of describing it.
- Then tell the user how to look: the URL, the account, the clicks from where they are, what to watch for, and what it looked like before.

Leave the screenshots, accounts, and services alone while the user still needs them. Clean up when leaving the PR.

## Hand it back

Keep it short:

- what the PR changes about the product
- conflicts and how you would resolve them
- what you tried and what you saw
- how to look at it
- what is left, risky, or unclear
- a call: merge, revise, skip, or close

Then stop. Offer to fix in-scope defects and conflicts, but only write code, push, or edit the PR description when asked. If asked:

1. Use `pr-writing` and `unslop` to match the description to the diff.
2. Push, then run the repo's signoff checks on that pushed commit.
3. Confirm GitHub calls the PR mergeable and the checks belong to the final commit.

A stale check or a local run is not CI signoff. Wait for the user to decide or ask for the next PR.
