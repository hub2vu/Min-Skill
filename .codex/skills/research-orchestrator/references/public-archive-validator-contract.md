Public Archive Validator Contract

Validation must distinguish the internal operating bundle from the user-facing public research archive.

Validator classes:

1. Internal Knowledge Bundle Validator
   - proves the operating ZIP contains the expected root contract files
   - checks `AGENTS.md`, `skills/`, `references/`, prompt coherence, path normalization, hashes, and control-file ceilings
2. Public Research Archive Validator
   - proves the user-facing archive excludes operating-bundle members
   - checks subject-centered layout, public language, public timestamps, cumulative retention, turn-trace completeness, and manuscript continuity

Public validator minimum checks:

- forbidden-member scan returns zero matches for:
  - `AGENTS.md`
  - `skills/**`
  - `references/**`
  - `*Research-Orchestrator*.zip`
  - prompt bootstrap files
  - validation notes and release reports
  - `plan/**`
  - `subagent-runs/**`
  - internal orchestration status files
- nested ZIP count is zero
- root layout is subject-centered rather than operating-centered
- public guide and public status prose avoid system-meta wording
- the first paragraph of the public guide and public status surface avoids archive, contract, skill, AGENTS, or bootstrap narration
- public substantive files preserve local and UTC time information or explicitly state a runtime boundary
- public-facing metadata labels and update-log verbs follow the active user language when practical
- cumulative retention preserves prior research files directly
- updated mutable public files preserve prior versions under archival paths
- each substantive represented turn has a dedicated turn-note artifact
- bounded manuscript accumulation is allowed without implying one-turn full completion
- when a full or connected manuscript is present, a canonical citation ledger exists
- when a full or connected manuscript is present, bibliography, source log, and manuscript references agree on author-list integrity, core identity fields, and locator fields for manuscript-used sources
- when a literature-based interpretive review manuscript is present, competing explanations and judgment criteria are visible in the manuscript rather than only in support notes
- when the runtime supports fixed-layout delivery for a final manuscript bundle, PDF is present; otherwise the archive records the exact format boundary

Fixture guidance:

- the bee mortality cumulative ZIP pair is a positive continuity exemplar for the public side
- turn two preserving turn one plus one new note plus one bounded section is good public-archive behavior
- the validator should use fixtures like that to test archive semantics, not to force identical filenames across all subjects
- legacy fixtures that predate the new public language or timestamp rules should be judged for continuity shape, bounded section behavior, and additive retention, not failed retroactively for missing later schema fields

Failure examples:

- a public archive contains the operating contract or internal archive references
- a public archive contains the Knowledge ZIP itself
- a public archive replaces prior files instead of preserving them
- a public archive updates mutable files without preserving the earlier versions under archival paths
- a public archive is missing a substantive turn-note that should exist for a represented turn
- a public archive explains bootstrapping instead of research
- a non-English user session leaves English metadata labels or update-log verbs as the default public-facing surface without a stated reason
- a public archive jumps from first section opening to implied full-paper completion without readiness
- a final-manuscript archive still carries citation drift across bibliography, source log, and manuscript references
- a final-manuscript archive still carries locator drift across bibliography, source log, and manuscript references for a manuscript-used source
- a final-manuscript archive emits editable manuscript output but silently omits PDF even though the runtime supports it
