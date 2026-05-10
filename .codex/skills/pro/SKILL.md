---
name: pro
description: Use when the user enters /pro, asks to consult ChatGPT Pro, GPT-5.5 Pro, or Oracle browser mode from Codex IDE/CLI, or wants a second-opinion answer using a logged-in ChatGPT Pro browser session instead of OpenAI API billing. Runs Oracle through PowerShell with ChatGPT browser automation.
---

# Pro

## Overview

Use Oracle browser mode to send a prompt and optional files to a logged-in ChatGPT Pro browser session with `gpt-5.5-pro`. This is browser automation, not OpenAI API or OAuth, so it needs an interactive ChatGPT login once and can be affected by ChatGPT UI changes.

For this project, the only supported file upload path is: collect the requested files, compress them into one ZIP, then upload that single ZIP through the ChatGPT browser file picker. Do not use Oracle's direct multi-file/text bundling path, rendered copy/paste bundles, or any previous upload fallback. The wrapper enforces a maximum ZIP size of 100 MB before sending.

## Quick Start

When the user types `/pro <prompt>`, run:

```powershell
& "$PWD\.codex\skills\pro\scripts\invoke-pro.ps1" -Prompt "<prompt>"
```

If the user wants files included, pass them with `-File`:

```powershell
& "$PWD\.codex\skills\pro\scripts\invoke-pro.ps1" -Prompt "<prompt>" -File "src/**/*.ts","README.md"
```

The wrapper expands those paths/globs, writes one archive under `output\pro_uploads\pro-upload-*.zip`, and passes only that ZIP to Oracle with browser attachments enabled. This matches the manual ChatGPT UI flow of `+` -> add photos/files -> enter the file's absolute path.

For first-time setup, run:

```powershell
& "$PWD\.codex\skills\pro\scripts\invoke-pro.ps1" -FirstLogin
```

Oracle requires Node.js 24+. If the script reports an older Node version, tell the user to upgrade Node.js before retrying.

## Workflow

1. Strip the `/pro` prefix from the user's message and treat the rest as the prompt.
2. Include only files the user explicitly names, or the smallest relevant file set if they ask for context from the current task.
3. When files are needed, always pass them through `-File` and let the wrapper create one ZIP. Never pass the original files directly to Oracle.
4. If the prepared ZIP exceeds 100 MB, reduce the file set or prepare a smaller summary/extract before retrying.
5. Use `scripts/invoke-pro.ps1` rather than retyping the Oracle command.
6. Tell the user if Oracle, Node.js, Chrome, or ChatGPT login blocks execution.
7. Use `-DryRun` only to inspect the browser upload plan. Do not use manual paste/copy fallback for file context.

## Script Behavior

The script calls project-local Oracle when files are present, because the local copy is patched to treat archives such as `.zip` as browser-uploadable attachments:

```powershell
node .\.tools\oracle-local\node_modules\@steipete\oracle\dist\bin\oracle-cli.js --engine browser --model gpt-5.5-pro --browser-manual-login --browser-attachments always --file output\pro_uploads\pro-upload-*.zip
```

For prompt-only calls, the script can still use the same local Oracle if available. If the local Oracle package is missing and files are provided, the wrapper installs `@steipete/oracle@0.11.0` project-locally and patches archive extensions for browser upload.

For Pro models, the script intentionally does not pass `--browser-thinking-time` by default. Playwright verification on 2026-05-06 showed that passing `--browser-thinking-time heavy` can leave ChatGPT on `Thinking • Heavy` instead of selecting `Pro`. It also enables Oracle auto-reattach defaults for long Pro responses. Use script flags to override:

- `-Model`: defaults to `gpt-5.5-pro`
- `-ThinkingTime`: defaults to `heavy` for non-Pro models
- `-ForceThinkingTime`: also passes `-ThinkingTime` for Pro models, only after manually verifying the ChatGPT UI behavior
- `-File`: one or more file paths/globs; the wrapper always compresses them into a single ZIP and uploads only that ZIP
- `-FirstLogin`: opens the persistent browser profile and waits for manual ChatGPT login
- `-DryRun`: previews Oracle's browser plan without sending
- `-CopyOnly`: disabled in this project
- `-PrintCommand`: prints the resolved command without running Oracle
- `-SkipEnvironmentCheck`: bypasses local Node version checks when only inspecting command generation
- `-BrowserPort`: passes a fixed Chrome DevTools port for Playwright verification or debugging
- `-BrowserModelStrategy`: defaults to `auto`; for Pro models this resolves to Oracle's `ignore` strategy after the wrapper preselects the visible ChatGPT `Pro` option with Playwright. Use `select` only after verifying the picker labels match Oracle.
- `-NoBrowserLock`: bypasses the local browser-mode lock; use only when you intentionally manage isolated browser sessions yourself
- `-SkipBrowserModelPreselect`: skips the Playwright preselection step; use only when manually debugging ChatGPT UI state
- `-BrowserLockTimeoutSeconds`: maximum wait for another browser-mode `/pro` run to finish; defaults to `7200`

Browser-mode `/pro` calls are serialized by default. Parallel Oracle browser automation can race over the same ChatGPT browser profile/window, and one completed run can close a browser window before another run has finished. The wrapper also treats Oracle "Chrome window closed before oracle finished" / "Chrome disconnected before completion" messages as failures even if Oracle exits with code `0`.

## Guardrails

Do not describe this as OAuth or API usage. Do not use it for bulk automated extraction, credential sharing, resale, or powering third-party services. For programmatic production use, use the official OpenAI API with `OPENAI_API_KEY` and separate API billing.
