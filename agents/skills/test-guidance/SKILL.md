---
name: test-guidance
description: "Use whenever work may add, change, run, review, merge, consolidate, or delete tests, including incidental test work while implementing or debugging, or when choosing E2E versus unit/integration coverage. Keeps temporary diagnostics cheap and committed tests high-signal and worth their runtime."
---

# Test Guidance

Temporary tests may be redundant or implementation-coupled while debugging.
Before finishing, delete them or rewrite them as durable tests.

Durable tests run forever. Optimize for distinct product contracts per unit of
executed work, not test count or coverage percentage.

## Durable-test gate

Every committed test must:

1. Protect behavior a user or caller relies on—not a fixture, mock, framework,
   copy string, CSS class, or implementation detail.
2. Fail for a plausible production-code mutation.
3. Add signal no neighboring test already provides. Read sibling tests and
   trace the production path before adding or retaining it.
4. Use the cheapest tier that catches the regression.
5. Justify its harness boots, fixtures, browser mounts, actions, mutations,
   scheduled work, media/network calls, waits, and retries.

Delete fixture/mock tautologies, runtime-language tests, trivial wrapper tests,
dead-code tests, and assertions strictly weaker than existing coverage.

Keep distinct auth/authz, tenant-isolation, race, atomicity, failure, recovery,
and state-machine branches. Verbosity alone is not redundancy.

## Choose the tier

- **E2E smoke:** critical cross-system customer journeys only. Assert durable
  state and user-visible outcomes, not LLM wording or incidental UI structure.
- **Integration:** domain behavior across handlers, persistence, permissions,
  boundaries, and failures.
- **Unit/component:** pure decisions and focused UI behavior.

UI involvement alone does not justify E2E.

## Work efficiently

- Extend an existing lifecycle or matrix when it preserves clear failures.
- Reuse state when scenarios progress naturally; do not merge independent
  security, tenancy, concurrency, or destructive workflows.
- Measure actual work. A loop with three browser mounts still performs three
  mounts; nested fresh harnesses do not save harness cost.
- Before finishing, apply the gate to every touched test and remove temporary
  scaffolding.

## Delete, review, and merge

Delete a durable test only when a specific stronger test catches the same bug,
or the test cannot fail because of a production bug. Preserve useful assertions
when consolidating. Never delete to meet a quota; keep uncertain load-bearing
contracts and state the uncertainty.

Apply the same gate to tests arriving from `main`. Preserve new semantics while
folding redundant cases into the leaner suite, and report any upstream tests
pruned during conflict resolution.
