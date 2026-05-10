# Min-Skill

Personal Codex skill bundle.

## Layout

- `.codex/skills/pro`: Runs Oracle browser mode from PowerShell to consult ChatGPT Pro GPT-5.5 Pro through a logged-in ChatGPT browser session.
- `.codex/skills/goal-agent`: Runs `/goal` requests through a goals-enabled Codex CLI child agent and stores run artifacts under the active workspace.
- `.codex/skills/research-orchestrator`: Bundles Research-Orchestrator as a file-based research workflow archive with its internal skills and references preserved.
- `.tools/oracle-local`: Project-local Oracle package metadata used by the `pro` skill. The script installs and patches `node_modules` locally when needed.
- `.tools/playwright-check`: Project-local Playwright package metadata used by the `pro` skill to verify/select the ChatGPT Pro browser mode.

## Use

This repository is meant to be placed at a workspace root so `.codex/skills` and `.tools` remain siblings. The checked-in `.tools` files are package manifests only; generated `node_modules` folders are intentionally ignored and can be recreated with npm.
