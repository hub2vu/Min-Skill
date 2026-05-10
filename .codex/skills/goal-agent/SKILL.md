---
name: goal-agent
description: Use when the user enters /goal, asks to run a goals-enabled Codex agent, or wants a Codex CLI child process to execute an objective with the experimental goals feature.
---

# Goal Agent

## Overview

Run `/goal ...` requests through a separate Codex CLI process with the experimental `goals` feature enabled. Keep all generated artifacts under the active project workspace unless the user explicitly gives another allowed path.

## Workflow

1. Treat the entire user message as the goal text.
2. If the text does not already start with `/goal`, prepend `/goal `.
3. Resolve the project workspace. For this PCI project, use the `ComfyUI/PCI` directory.
4. Run `scripts/run-goal-agent.ps1` with the goal text, workspace, and an output directory under `docs/goal_agent_runs`.
5. Read the generated `last_message.md` and summarize the result back to the user.

## Command

Use PowerShell:

```powershell
.\.codex\skills\goal-agent\scripts\run-goal-agent.ps1 `
  -Goal "/goal <objective>" `
  -Workspace "<absolute path to ComfyUI\PCI>"
```

The script writes a timestamped run folder containing:

- `last_message.md`: final response from the child Codex agent
- `console.log`: full Codex CLI output
- `metadata.json`: command metadata and exit code

The runner uses `codex exec --ephemeral` by default so session history is not persisted outside the workspace.

## Parallel Goals

For independent objectives, run separate script invocations with distinct `-RunName` values. Do not let child agents write to the same output directory.

## Guardrails

- Do not claim `/goal` is a stable native IDE slash command. It uses Codex CLI `--enable goals`, which is currently an under-development feature.
- Do not write outside the workspace unless the user explicitly permits that exact path.
- If Codex CLI is unavailable, report that the runner could not start.
- If the goal child exits nonzero, inspect `console.log` before deciding whether to retry.
- Use `-PersistSession` only when the user explicitly wants the child Codex session stored in the normal Codex session history.

## Reference

Read `references/codex-goals.md` only when you need details about the observed CLI behavior or current limitations.
