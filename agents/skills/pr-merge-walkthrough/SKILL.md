---
name: pr-merge-walkthrough
description: Walk through an author's open pull requests one at a time, oldest first, testing and preparing each for a human merge decision. Use when triaging or clearing a PR queue collaboratively. Do not use for autonomous bulk merging.
---

# PR merge walkthrough

Prepare one trustworthy merge decision at a time. Never merge the PR.

## Establish the queue

Infer or confirm the author, ordering, exclusions, and review preference from the conversation. Preserve these choices for later "next PR" requests.

- List open PRs by the selected author, oldest first.
- Apply exclusions such as billing work or experiments.
- Never include another author's PR without permission.
- Process exactly one eligible PR, then stop.
- Say when no eligible PR remains.

## Understand before changing

Read the PR, linked issues and acceptance criteria, full diff, current base, checks, and relevant surrounding code.

Check whether merged work already supersedes the PR. Compare behavior and implementation, not titles alone. If it is redundant, verify the overlap, show the user, recommend closing, and leave the remote branch untouched.

## Run the branch

Use the repository's workspace tooling to create and run an isolated checkout. In projects configured for `work`, use it for setup, services, URLs, logs, and teardown.

Integrate the current base using repository conventions. Distinguish:

- textual conflicts Git reports;
- semantic conflicts where both changes survive but produce duplicate or contradictory behavior;
- unrelated base changes that need no decision.

Before resolving a meaningful conflict, tell the user which behaviors compete and what to inspect. Preserve the current product behavior unless the PR intentionally replaces it.

## Verify the outcome

Use `test-guidance` for all test decisions.

- Exercise the intended behavior personally in the real runtime.
- Use focused automated coverage at the cheapest useful tier.
- For UI changes, inspect desktop and mobile and capture fresh screenshots.
- Follow the browser skill when controlling a browser.
- Use disposable test accounts when needed and delete them afterward.
- Remove temporary tests, fixtures, accounts, services, and screenshot files before finishing.

Do not treat passing tests as personal runtime verification. Report separately:

- what was personally exercised;
- what automated checks covered;
- what the user may still want to inspect.

If something fails, determine whether the PR caused it, current base caused it, or the local environment is broken. Fix only work within the PR's scope.

## Prepare a useful PR

If the PR still adds value, resolve its conflicts and remaining in-scope defects. Respect an explicit request to skip formal review. Otherwise use the repository's normal review gate.

After material changes:

1. Apply `pr-writing` and `unslop` to reconcile the description with the full diff.
2. Push the final commit.
3. Run `bun run ci` against that exact pushed commit when the repository uses this signoff command.
4. Confirm GitHub reports the PR mergeable and checks apply to the final commit.

Never claim a stale check or an unpushed local run as final CI signoff. Do not push or sign CI for a PR that should close as redundant.

## Hand back the decision

Explain concisely:

- what the PR adds or fixes;
- conflicts and their resolution;
- runtime and automated verification;
- fresh screenshots for UI work;
- remaining work or caveats;
- whether to merge, revise, skip, or close.

Stop before merging. Continue only after the user chooses or asks for the next PR.
