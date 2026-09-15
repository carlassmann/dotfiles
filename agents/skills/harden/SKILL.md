---
name: harden
description: Turn a proven prototype or spike into a durable, production-ready implementation. Use when the user says clean this up, make it proper, productionize, production ready, make it real, or wants to keep prototype code and make it maintainable and tested.
---

# Harden

Prototype evidence is the design input. Don't reopen architecture debate unless a material unknown remains.

Identify what proved essential, then:

- Remove abandoned paths, duplicate mechanisms, temporary diagnostics, prototype-only affordances
- Replace accidental structure with the simplest architecture the evidence justifies
- Prefer deep modules, clear ownership, readable names, one source of truth
- Keep compatibility only for real consumers
- Record stable, non-obvious intent in the project's existing docs
- Add or consolidate only high-signal tests for important behavior and invariants

Exercise the result in the real runtime. Run repository checks and affected E2E flows. Failures are evidence: diagnose causes, don't patch symptoms.

No commit, push, PR, or scope expansion unless asked. Report resulting architecture, removed debt, verification, remaining risks. Recommend `$deliver` when ready for review.
