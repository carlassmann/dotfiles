---
name: issue-writing
description: Create or update GitHub issues with concise, reproducible context. Use before opening or materially rewriting an issue, especially for bugs, QA findings, tasks, ideas, and epics.
---

# Issue writing

Write issues that another engineer can pick up without reconstructing the author's investigation.

## Before writing

1. Read the repository's issue templates and choose the closest type.
2. Search open and closed issues for duplicates.
3. Verify facts from the codebase, runtime, logs, or other available evidence.
4. For bugs, reproduce the behavior and record exact steps. Do not open a bug without a working reproduction. Exhaust available environments first, then ask the user for access or help.

If an existing issue describes the same failure, add useful new evidence there. Create a separate issue only when the behavior or acceptance boundary differs materially.

## Content

Follow the selected template. Keep only sections that carry information.

- State why the issue matters.
- Use a title that names the observable problem or desired outcome.
- For bugs, include reproduction steps, expected and actual behavior, environment, evidence, and severity.
- For visible UI bugs, attach the affected viewport and state. Use video when a still cannot show the interaction failure.
- Define a testable outcome under `Expected` or `Definition of Done` without prescribing implementation.
- Separate settled `Decisions` from unresolved `Open questions`. Record each decision with a brief reason.
- Include likely code areas or causes under `Evidence` only when evidence supports them. Label uncertainty.
- State scope boundaries when they prevent the issue from growing during implementation.

Do not turn guesses into requirements. Do not create noise for behavior that cannot be reproduced.

When creating through an API or CLI, apply the selected template's issue type, labels, and parent relationship explicitly. Template frontmatter does not become part of the submitted issue body.

## Style

Use concrete, concise language. Apply `unslop`. Avoid ceremony, repeated context, speculative diagnosis, and implementation plans. Evidence beats adjectives.
