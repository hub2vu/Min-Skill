Public Research Archive Contract

The public research archive is a user-facing deliverable. It is not the GPT operating bundle.

Archive classes:

1. Internal Knowledge ZIP
   - audience: GPT runtime
   - purpose: operating contract
   - allowed to contain `AGENTS.md`, `skills/`, `references/`, prompt bootstrap files, validation notes, and release metadata
2. Public Research ZIP
   - audience: user
   - purpose: cumulative research archive for the active subject
   - must contain subject artifacts only

Public Research ZIP forbidden members:

- `AGENTS.md`
- `skills/**`
- `references/**`
- `*Research-Orchestrator*.zip`
- prompt bootstrap files such as `prompt-en.md` or `prompt-ko.md`
- release reports and validation notes
- `plan/**`
- `subagent-runs/**`
- internal orchestration files such as `current-run.md` or delegated `status.md`
- internal operating `README.md`

Public Research ZIP allowed zones should stay subject-centered. Preferred categories are:

- `manifest/`
- `status/`
- `scope/`
- `literature/`
- `citations/`
- `evidence/`
- `analysis/`
- `manuscript/`
- `logs/`
- `archive/superseded/`
- a public archive guide when useful

The root of the public archive should look like a research subject archive, not like a GPT bundle.

Public-facing language rules:

- public archive prose should default to the user's language unless the user chooses another language
- public-facing metadata labels and update-log verbs should default to the user's language unless the user chooses another language
- file names may stay ASCII and stable
- public archive prose must not narrate contract files, skill files, bootstrapping, archive unpacking, or similar operating machinery
- the first paragraph of a public guide or public status document should read like research reporting, not like operating preparation

Public timestamp rules:

- when the runtime can write substantive public artifacts, preserve user-facing labels for these semantic fields:
  - local created time
  - UTC created time
  - local updated time
  - UTC updated time
  - timezone
  - turn identifier
- use the user's timezone for the local fields when available
- keep UTC explicit for auditability
- active public ZIP names should normally use local-first naming with a UTC token as well, for example `subject-20260420-093037-KST__003037Z.zip`

Public retention rules:

- refresh the public research ZIP on every active turn that creates or updates public research artifacts
- keep the ZIP cumulative and additive
- preserve earlier files directly rather than nesting earlier delivery ZIPs
- before materially updating a mutable public file, preserve the prior version under `archive/superseded/` or an equivalent archival lane with a timestamped filename
- move obsolete or superseded files into archival paths rather than deleting them
- every substantive public turn must create a durable turn-note file
- if a previously missing substantive turn-note can be restored from preserved public state during a later cumulative build, restore it rather than leaving the trace incomplete
- surface the real public ZIP path or attachment when delivery succeeds
- if delivery cannot happen, state the exact boundary and do not imply success

Public manuscript rules:

- bounded section accumulation belongs in the public archive
- the first opened section does not imply final connected-manuscript readiness
- final full-manuscript assembly should appear only after honest readiness or explicit completion request
- when final-manuscript delivery is active, keep one canonical citation ledger in the public archive
- align bibliography, source log, and manuscript references to that ledger for manuscript-used sources
- when the runtime supports it, co-deliver Markdown manuscript output, an editable manuscript artifact when appropriate, and PDF
- if PDF or another expected format cannot be produced, state the exact boundary in the public archive instead of silently omitting the format
