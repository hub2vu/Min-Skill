---
name: research-parent-orchestrator
description: Default single-session orchestration path for coding, research, drafting, verification, and review when the user has not explicitly requested delegated subagents.
---

# Research Parent Orchestrator

Use this skill by default after reading the archive root `AGENTS.md`.

## Read Next

- `references/authority-order.md`
- `references/runtime-bootstrap.md`
- `references/plan-contract.md` when coding may lead to writable work
- `references/research-workflow-contract.md` when substantive research is active
- `references/user-visible-language-contract.md` when research progress will be user-visible
- `references/chronology-audit-contract.md` when durable research artifacts are changing
- `references/evaluation-rubric-contract.md` when the request is evaluative
- `references/public-research-archive-contract.md` when user-facing archive delivery is in scope
- the smallest set of additional skills needed for the request

## Default Workflow

Keep execution inside one session unless the user explicitly asks for `/sub` or delegation.

Use this phase order when it fits:

1. inspect the relevant repository or files
2. decide whether the request is coding, research, or mixed
3. if coding can become writable, invoke `skills/research-coding-plan/SKILL.md`
4. if a question honestly requires substantive research, or if research state would become a visible trust surface, invoke `skills/research-stage-machine/SKILL.md` before substantive answering or evidence collection
5. if research or source precision matters, invoke `skills/research-evidence-loop/SKILL.md`
6. if source citation or link quality matters, invoke `skills/research-source-fidelity/SKILL.md`
7. if manuscript or long-form scholarly output is requested, or if the workflow has honestly reached writing readiness, invoke `skills/research-manuscript-assembly/SKILL.md`
8. if the request is evaluative, rubric-based, or quality-assessment oriented, invoke `skills/research-evaluation-rubric/SKILL.md`
9. if durable packaging or archive retention matters, or if the turn changes durable research artifacts, invoke `skills/research-packaging-retention/SKILL.md`

## Operating Rules

- keep summaries compact and delta-oriented
- prefer inspected files over remembered assumptions
- use positive operational prose rather than decorative prompt theater
- keep uncertainty explicit
- keep state in durable artifacts, not only in chat
- keep the attached Knowledge bundle separate from the user-facing public research archive
- keep the visible body substantive enough to explain what was learned, why the current research position is justified, and what advances or blocks the next move
- keep orchestration or contract-confirmation language out of the visible body unless the user is explicitly auditing the system itself
- keep the first visible paragraph and public-archive introductions free of archive, contract, skill, AGENTS, or bootstrap narration
- keep public-facing metadata labels and chronology verbs in the user's language when practical
- when durable artifacts change, keep chronology metadata and update-log discipline aligned
- when a turn changes durable public artifacts, do not stop at describing packaging intent; surface the refreshed public research ZIP artifact or state the exact packaging boundary
- do not begin substantive research work on an ordinary-looking question before the stage-machine path has opened the honest research workflow in plain language
- once writing readiness is honestly reached, treat manuscript writing as the default active mode and say that plainly in the body instead of staying in stage-only reporting mode
- if a request changes materially, refresh the active plan, archive status artifacts, or delegated `status.md` according to the authoritative workflow path instead of improvising from memory
- when a review or verification step finds a bounded issue, prefer a narrow fix followed by re-verify and, if useful, re-review
- when reusable and stable reference code can honestly reduce risk or maintenance burden, inspect that before inventing new structure

## Stop Rule

Stay in parent-session mode unless the user explicitly asks for `/sub`, subagents, delegation, or multi-worker execution and the runtime truly supports it.
