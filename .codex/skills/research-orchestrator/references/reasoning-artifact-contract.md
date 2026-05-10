Reasoning Artifact Contract

Reasoning artifacts are part of research integrity, not optional notes.

The cumulative archive should preserve at least these families when relevant:

- `research-archive/manifest/`
- `research-archive/status/`
- `research-archive/scope/`
- `research-archive/literature/`
- `research-archive/citations/`
- `research-archive/evidence/`
- `research-archive/analysis/`
- `research-archive/manuscript/`
- `research-archive/logs/turn-notes/`
- `research-archive/archive/superseded/`

Substantive archive artifacts should carry a compact metadata block when the runtime can write files. At minimum preserve:

- `Created_at`
- `Updated_at`
- `Timezone`
- `Turn_id`

Apply that metadata discipline to substantive turn notes, stage judgments, research-status artifacts, regression logs, citation ledgers, source logs, evidence tables, argument ledgers, claim-evidence maps, manuscript section files, archive manifests, and other durable reasoning files that materially change the research record.

Each substantive turn note should let an independent reviewer reconstruct:

1. what exact question or sub-question was examined
2. what sources or materials were reviewed
3. why those sources mattered
4. what was learned
5. what conflict, ambiguity, or competing explanation mattered
6. why the current research position is justified
7. why advancement is not yet justified, or why regression was necessary
8. how the argument, concept frame, or writing readiness changed

Each new substantive turn should normally create a new turn-note artifact rather than overwriting a prior turn-note in place.

If a later cumulative build can restore a missing earlier substantive turn-note from preserved durable state, restore that note and record the restoration in the chronology log rather than leaving the trace incomplete.

Use explicit claim typing in analysis artifacts:

- confirmed evidence
- interpretive inference
- working hypothesis
- open issue

Before writing readiness, preserve at least these generative artifacts:

- `competing-explanations.md`
- `conceptual-refinement.md` or `gap-and-contribution.md`
- `claim-evidence-map.md`
- `argument-ledger.md`
- `citations/master-ledger.md` when manuscript-closing work is active
- `research-archive/manifest/update-log.md`

If stage movement or regression happens, update:

- `stage-judgment.md`
- `regression-log.md` when regression occurred

If a mutable public reasoning file such as a status note, source log, evidence table, argument ledger, or guide changes materially, preserve the prior version under an archival path before updating the live file.

Thin-note failure includes:

- a few bullets with no explanatory prose
- source lists with no selection rationale
- no explanation of why the current position is justified
- no explanation of what remains insufficient
- no explanation of why movement or regression occurred
- archive growth without reconstructable reasoning

Chronology failure includes:

- missing second-level timestamps in substantive artifacts when the runtime can provide them
- a changed file with no meaningful `Updated_at` change
- a chronology log that does not show created, updated, archived, or built events clearly enough to audit turn order
- a ZIP build with no corresponding chronology entry

For major long-form artifacts such as approved plans, version reports, validation notes, review verdicts, and dedicated rationale bundles, keep them auditably detailed and normally at or above 8000 characters unless the artifact is inherently smaller and the reason is stated explicitly.
