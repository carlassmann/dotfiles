---
name: prototype
description: Spike, prototype, or proof-of-concept an uncertain idea through the smallest realistic, reversible implementation, then harvest what it taught. Use when the user says spike, prototype, POC, try it quickly, see if this works, or asks what a prototype taught us and whether to keep, continue, or harden it.
---

# Prototype

Implementation is an experiment that answers one concrete unknown.

Infer the unknown, constraints, and success signals from the request and codebase. Ask only product questions that inspection or a cheap experiment can't answer.

Build the smallest vertical slice through the real system. Prefer the actual runtime, integrations, and UI over mocks wherever they affect what must be learned. Exercise it and report observed evidence.

Keep it reversible. Skip generalization, compatibility layers, migrations, polished abstractions, exhaustive tests, docs, commits, and PRs unless the experiment needs them or the user asks. Temporary diagnostics are fine; low-value regression tests for speculative behavior are not.

## Checkpoint

Stop once the question is answered, or when the user asks to wrap up a prototype built without this skill. Report:

- Built and exercised
- Learned; assumptions confirmed or invalidated
- Essential choices vs prototype accidents
- Prototype debt, risks, remaining unknowns; cheapest next experiment for each
- Architecture now justified by evidence
- Recommendation: discard, continue, or harden

No redesign beyond what the evidence supports. No hardening, docs, commits, or PRs unless asked. Recommend `$harden` when the user chooses to keep it.
