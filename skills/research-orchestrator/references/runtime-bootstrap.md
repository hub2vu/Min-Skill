Runtime Bootstrap

In a file-capable runtime:

1. locate the attached archive whose name contains `Research-Orchestrator`
2. extract or mount it into the working area
3. confirm the root contains `AGENTS.md`, `skills/`, and `references/`
4. read root `AGENTS.md`
5. read the active orchestration skill
6. read only the extra skills and references required for the current request
7. reread root `AGENTS.md` at the start of later turns

If the runtime cannot extract archives but can inspect files, follow the same order from visible files.

If the runtime cannot inspect the archive at all, state that boundary and continue with the narrowest safe fallback.
