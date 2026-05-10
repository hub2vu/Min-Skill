# Min-Skill

Personal Codex skill bundle.

This repository is a project-local Codex skill bundle. It is intended to be
copied or cloned as a workspace root so `.codex/skills` and `.tools` remain
siblings.

## Layout

- `.codex/skills/pro`: Runs Oracle browser mode from PowerShell to consult ChatGPT Pro GPT-5.5 Pro through a logged-in ChatGPT browser session.
- `.codex/skills/goal-agent`: Runs `/goal` requests through a goals-enabled Codex CLI child agent and stores run artifacts under the active workspace.
- `.codex/skills/research-orchestrator`: Bundles Research-Orchestrator as a file-based research workflow archive with its internal skills and references preserved.
- `.tools/oracle-local`: Project-local Oracle package metadata used by the `pro` skill. The script installs and patches `node_modules` locally when needed.
- `.tools/playwright-check`: Project-local Playwright package metadata used by the `pro` skill to verify/select the ChatGPT Pro browser mode.

## Install / Use

Preferred project-local use:

```powershell
git clone https://github.com/hub2vu/Min-Skill.git <workspace>
cd <workspace>
codex
```

For an existing workspace, copy both `.codex` and `.tools` into that workspace
root, then restart Codex.

The checked-in `.tools` directories are package manifests only. Generated
`node_modules` folders are intentionally ignored and can be recreated with
`npm install` by the `pro` wrapper when needed.

## Notes

- A plain Codex skill only requires a `SKILL.md` file.
- This bundle's `pro` skill also expects `.tools` to remain available as a
  sibling of `.codex`, because browser upload and ChatGPT Pro preselection use
  project-local Node packages.
- Installing only `.codex/skills/pro` with a generic skill installer can load
  the skill instructions, but it will not copy the sibling `.tools` package
  manifests. For `/pro`, use the project-local bundle layout above.
- Requirements for `/pro`: Windows PowerShell, Node.js 24+, Chrome or Edge,
  and a logged-in ChatGPT Pro browser session.
- Requirements for `/goal`: Codex CLI available on `PATH`.

After cloning or copying into a workspace, restart Codex so it can discover the
project-local skills.
