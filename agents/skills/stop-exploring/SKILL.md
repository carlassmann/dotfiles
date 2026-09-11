---
name: stop-exploring
description: End an implementation-led exploration, harvest its evidence, and decide whether to discard, continue exploring, or harden the result.
---

# Stop Exploring

Turn the prototype into an explicit decision checkpoint.

Inspect the implementation, relevant conversation decisions, and available runtime or test evidence. Exercise the result in its real runtime when that evidence is missing and doing so remains within the user's request.

Report concisely:

- What the implementation taught us
- Which assumptions were confirmed or invalidated
- Which choices are essential versus prototype accidents
- Prototype debt, risks, and unresolved unknowns
- The architecture now justified by evidence
- Recommendation: discard, continue exploring, or ready to harden

For unresolved unknowns, propose the cheapest useful experiment.

Do not invent a broad redesign unsupported by the exploration. Do not harden, refactor, document, commit, or open a PR unless the user separately requests it.
