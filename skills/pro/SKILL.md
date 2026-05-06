---
name: pro
description: Use when the user enters /pro, asks to consult ChatGPT Pro, GPT-5.5 Pro, or Oracle browser mode from Codex IDE/CLI, or wants a second-opinion answer using a logged-in ChatGPT Pro browser session instead of OpenAI API billing. Runs Oracle through PowerShell with ChatGPT browser automation.
---

# Pro

## Overview

Use Oracle browser mode to send a prompt and optional files to a logged-in ChatGPT Pro browser session with `gpt-5.5-pro`. This is browser automation, not OpenAI API or OAuth, so it needs an interactive ChatGPT login once and can be affected by ChatGPT UI changes.

## Quick Start

When the user types `/pro <prompt>`, run:

```powershell
& "$PWD\.codex\skills\pro\scripts\invoke-pro.ps1" -Prompt "<prompt>"
```

If the user wants files included, pass them with `-File`:

```powershell
& "$PWD\.codex\skills\pro\scripts\invoke-pro.ps1" -Prompt "<prompt>" -File "src/**/*.ts","README.md"
```

For first-time setup, run:

```powershell
& "$PWD\.codex\skills\pro\scripts\invoke-pro.ps1" -FirstLogin
```

Oracle requires Node.js 24+. If the script reports an older Node version, tell the user to upgrade Node.js before retrying.

## Workflow

1. Strip the `/pro` prefix from the user's message and treat the rest as the prompt.
2. Include only files the user explicitly names, or the smallest relevant file set if they ask for context from the current task.
3. Use `scripts/invoke-pro.ps1` rather than retyping the Oracle command.
4. Tell the user if Oracle, Node.js, Chrome, or ChatGPT login blocks execution.
5. If browser automation fails, offer `-CopyOnly` or `-DryRun` as a fallback so the user can paste the rendered bundle manually.

## Script Behavior

The script calls:

```powershell
npx -y @steipete/oracle --engine browser --model gpt-5.5-pro --browser-manual-login --browser-thinking-time heavy
```

It also enables Oracle auto-reattach defaults for long Pro responses. Use script flags to override:

- `-Model`: defaults to `gpt-5.5-pro`
- `-ThinkingTime`: defaults to `heavy`
- `-File`: one or more file paths/globs
- `-FirstLogin`: opens the persistent browser profile and waits for manual ChatGPT login
- `-DryRun`: previews Oracle's browser plan without sending
- `-CopyOnly`: renders and copies the bundle for manual paste instead of browser automation
- `-PrintCommand`: prints the resolved command without running Oracle
- `-SkipEnvironmentCheck`: bypasses local Node version checks when only inspecting command generation

## Guardrails

Do not describe this as OAuth or API usage. Do not use it for bulk automated extraction, credential sharing, resale, or powering third-party services. For programmatic production use, use the official OpenAI API with `OPENAI_API_KEY` and separate API billing.
