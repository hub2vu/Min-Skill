---
name: research-subagent-orchestrator
description: Explicit delegated execution path for `/sub`, subagents, or multi-worker requests when the runtime truly supports delegated agents.
---

# Research Subagent Orchestrator

Use this skill only after an explicit user request for `/sub`, delegation, subagents, or multi-worker execution.

## Read Next

- `references/authority-order.md`
- `references/runtime-bootstrap.md`
- `references/plan-contract.md` for coding work
- `references/chronology-audit-contract.md` when durable artifacts will change
- `references/evaluation-rubric-contract.md` when the delegated request is evaluative
- `references/public-research-archive-contract.md` when public archive delivery is part of the delegated scope
- `references/public-archive-validator-contract.md` when validating user-facing archives
- the smallest set of research-operating skills needed by the delegated task

## Activation Rules

- do not activate `/sub` implicitly
- if the runtime cannot launch real delegated agents, state that boundary and fall back to `skills/research-parent-orchestrator/SKILL.md`
- keep the parent responsible for decomposition, acceptance criteria, final acceptance, and durable artifact alignment

## Delegation Rules

- split only when parallelism is real or role separation materially improves quality
- keep subject workers bounded
- keep reviewers and validators late and read-only by default
- do not give subject workers the scoring rubric unless the task is explicitly evaluative
- when the delegated request is evaluative, explicitly load `skills/research-evaluation-rubric/SKILL.md` and `references/evaluation-rubric-contract.md`
- preserve evidence on disk rather than relying on chat memory
- keep chronology evidence on disk as well as reasoning evidence when archive artifacts change
- keep internal Knowledge-bundle validation separate from public-archive validation
- make public-archive validation explicitly check public-surface language, immutable turn-note completeness, and prior-version archival preservation
- when a failure is narrow, repair only that narrow surface before rerunning
- do not widen scope silently during a fixer loop

## Coding Rule

If delegated work could lead to writable coding changes, the plan-first gate still applies. The parent must keep the approved PLAN under `plan/` current before launching writable execution.

## Research Rule

For research-heavy delegated work, keep the same evidence-first, standard-research workflow, plain-language reporting, visible-meta suppression, chronology discipline, manuscript-transition, reasoning-retention, evaluation-mode routing, and packaging-delivery rules that parent mode uses. The delegation method changes; the contract does not. When packaging is under review, remember that the user-facing research archive and the internal Knowledge bundle are different artifacts with different acceptance rules.
