---
name: research-orchestrator
description: Use when the user asks for Research-Orchestrator, research workflow orchestration, manuscript-oriented literature review control, evidence-first research staging, or file-based research operating contracts.
---

# Research Orchestrator

## Overview

This is a wrapper skill for the bundled Research-Orchestrator archive. The archive keeps its own root `AGENTS.md`, modular research skills, and shared references together so its internal paths remain valid.

## How To Use

1. Read `AGENTS.md` in this folder first.
2. Use `skills/research-parent-orchestrator/SKILL.md` by default.
3. Use `skills/research-subagent-orchestrator/SKILL.md` only when the user explicitly requests `/sub`, delegated agents, or multi-agent research execution.
4. Load only the referenced files under `references/` that the selected research skill names.

## Contents

- `AGENTS.md`: archive-root operating contract
- `skills/`: Research-Orchestrator internal skills
- `references/`: shared contracts referenced by the internal skills
- `Research-Orchestrator.zip`: original compact archive for Knowledge-style upload workflows
