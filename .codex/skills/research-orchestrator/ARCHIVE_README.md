Research-Orchestrator

This archive is meant to be attached as GPT Knowledge and loaded by a short bootstrap Instructions block.

Root layout:

- `AGENTS.md`: archive-root operating contract
- `skills/`: modular operating skills; each `SKILL.md` is kept below the per-file ceiling
- `references/`: stable reference files named by the skills

Default flow:

1. read root `AGENTS.md`
2. choose `skills/research-parent-orchestrator/SKILL.md` by default
3. switch to `skills/research-subagent-orchestrator/SKILL.md` only on explicit `/sub` or delegation requests
4. add `skills/research-coding-plan/SKILL.md` for writable coding work
5. add the research-operating skills and references needed for the current request

This revision uses standard research-process language for public reporting, keeps hidden control separate from user-facing research progress reports, preserves deep reasoning artifacts in the archive, and rebuilds cumulative ZIPs additively from preserved files.
