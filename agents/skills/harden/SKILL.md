---
name: harden
description: Turn a proven exploration or prototype into a durable implementation. Use when observed behavior is understood and the code should become maintainable, tested, and production-ready.
---

# Harden

Use evidence from the exploration as the design input. Do not restart speculative architecture discussion unless a material unknown remains.

Identify the behavior and constraints that proved essential. Then:

- Remove abandoned paths, duplicated mechanisms, temporary diagnostics, and prototype-only affordances
- Replace accidental structure with the simplest architecture justified by evidence
- Prefer deep modules, clear ownership, readable names, and one source of truth
- Preserve compatibility only when a real consumer requires it
- Capture stable, non-obvious product or architectural intent in the project's existing documentation
- Add or consolidate only high-signal tests for important behavior and invariants

Exercise the hardened implementation in its real runtime. Run repository checks and affected end-to-end flows. Treat failures as evidence; diagnose causes instead of patching around symptoms.

Do not commit, push, open a pull request, or broaden scope unless requested. Report the resulting architecture, removed prototype debt, verification, and remaining risks. Recommend `$deliver` when ready for review.
