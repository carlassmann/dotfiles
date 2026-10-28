---
name: counselors
description: Get parallel second opinions from other AI harnesses and models. Use when the user wants independent reviews, feedback, or a sanity check.
---

# Counselors

Send the same question and context to other harnesses and models in parallel, then synthesize their feedback. Invoke their CLIs directly.

Default to Claude and Codex. Use those without asking and without confirming the reviewer set. Only reach for the OpenCode recipes below when the user asks for an open-source model, a third opinion, or a different family. When the user names reviewers, use theirs.

## Shared prompt

Create a run directory from the project root:

```bash
run_dir=".scratch/counselors/$(date +%s)-SLUG"
mkdir -p "$run_dir"
```

`.scratch/` is in the global gitignore, so outputs stay in the workspace without showing up as changes in the reviewed repo.

Replace `SLUG` with a short task name. Write `prompt.md` there with the user's question, relevant context, and these instructions:

> Give an independent second opinion. Inspect the relevant evidence, explain your reasoning, and recommend what you would do. State uncertainty where it matters. Do not modify files or delegate.

Use paths for local files. Include conversation context the reviewers cannot see. For change reviews, identify the relevant diff and save it in the run directory if a reviewer cannot run git. Let the question determine the response format. Keep first opinions independent, without sharing other reviewers' answers or assigning specialist roles.

## Dispatch

Run only the selected commands below, concurrently in a background session that survives tool calls. Keep the read-only restrictions. Run the Claude and Codex commands by default; the OpenCode block only when the user asks for it. That command uses the configured `counselor` agent.

```bash
ins="Read the file at $PWD/$run_dir/prompt.md and follow the instructions within it."

( claude -p --output-format text --model claude-opus-5-5 \
    --tools Read,Glob,Grep,WebFetch,WebSearch \
    --allowedTools Read,Glob,Grep,WebFetch,WebSearch \
    --strict-mcp-config "$ins" \
    > "$run_dir/claude.md" 2> "$run_dir/claude.stderr" ) & echo $! > "$run_dir/claude.pid"

( codex exec --sandbox read-only --skip-git-repo-check -m gpt-6.1-sol "$ins" \
    > "$run_dir/codex.md" 2> "$run_dir/codex.stderr" ) & echo $! > "$run_dir/codex.pid"

# Optional, on request. Choose from hy3, deepseek-v4-flash, glm-5.3-flash.
for m in hy3; do
  ( opencode run -m "opencode-go/$m" --agent counselor --auto "$ins" \
      > "$run_dir/$m.md" 2> "$run_dir/$m.stderr" ) & echo $! > "$run_dir/$m.pid"
done
wait
```

Runs can take 10–20 minutes. Check saved PIDs and logs periodically. Read every completed response; inspect stderr for failures or empty output. If a model or flag is rejected, consult that CLI's help and retry the affected reviewer without weakening read-only restrictions.

## Feedback

Save the synthesis as `summary.md` in the run directory and give the user a concise version with the report location. Identify who responded and who failed. Explain the useful agreements, meaningful disagreements, and your recommendation. Weigh evidence rather than votes; preserve well-supported minority opinions.

For a requested follow-up round, create a new run directory and reference prior responses in its prompt.

Written with gpt-6 in codex.
