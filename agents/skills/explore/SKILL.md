---
name: explore
description: Explore uncertain product or technical ideas through the smallest realistic, reversible implementation. Use when learning from working software matters more than production hardening.
---

# Explore

Treat implementation as an experiment that should answer a concrete unknown.

Infer the unknown, relevant constraints, and useful success signals from the request and codebase. Ask only for product decisions that cannot be answered through inspection or a cheap experiment.

Build the smallest vertical slice that exercises the real system. Prefer the actual runtime, integrations, and UI over mocks when they affect what must be learned. Exercise the result and report observed evidence.

Keep the experiment reversible. Avoid premature generalization, compatibility layers, broad migrations, polished abstractions, exhaustive tests, documentation, commits, or pull requests unless they are necessary for the experiment or explicitly requested. Temporary diagnostics are welcome; do not preserve speculative behavior with low-value regression tests.

Stop after the experiment answers the useful question. Report:

- What was built and exercised
- What was learned
- Assumptions invalidated
- Remaining unknowns
- Prototype debt introduced

Recommend `$stop-exploring` when the user is ready to decide whether to discard, continue, or harden the result.
