---
name: research-packaging-retention
description: Additive packaging, cumulative zip retention, archival moves, turn-trace completeness, and durable artifact discipline for plans, rationale, evidence, and manifests.
---

# Research Packaging Retention

Use this skill whenever the workflow creates or updates durable artifacts, cumulative zips, manifests, rationale bundles, or archive paths.

## Read Next

- `references/archive-retention-contract.md`
- `references/chronology-audit-contract.md`
- `references/zip-retention-policy.md`
- `references/public-research-archive-contract.md`
- `references/public-archive-validator-contract.md`

## Operating Rules

- treat cumulative packaging as additive
- keep the internal Knowledge bundle separate from the user-facing public research archive
- on every active turn that creates or updates durable public artifacts, refresh the public research ZIP on that same turn
- keep current-turn additions together with all preserved prior public artifacts in the refreshed public ZIP
- build the refreshed public ZIP from the preserved public source tree and files rather than by nesting prior delivery ZIPs
- do not silently drop earlier files from later packages
- before materially updating a mutable public file, preserve the prior version under an archival path such as `archive/superseded/`
- do not let operating files leak into the public research ZIP
- keep second-level timestamp metadata aligned on substantive archive files when the runtime supports it
- keep public-facing metadata labels and update-log verbs in the user's language when practical
- keep `manifest/update-log.md` aligned with created, updated, archived, and built events
- use second-level timestamp precision in active ZIP filenames
- keep the archive source tree on disk so later turns can patch files and rebuild cleanly
- move obsolete or superseded artifacts into archival paths instead of deleting them
- keep one immutable turn-note per substantive public turn and backfill a previously missing substantive turn-note when a later cumulative build can restore it honestly
- keep plan records, rationale, notes, manifests, and evidence summaries aligned with the active workflow
- surface the real public ZIP path or attachment explicitly and update the active manifest or report that points to it
- do not replace delivery with prose-only ZIP status, "would include" language, or current-turn-only packaging
- do not let helper state files displace the public cumulative ZIP as the mandatory visible deliverable
- do not let short state summaries absorb the whole reasoning trail when richer rationale artifacts are required
- when a final manuscript bundle is present, keep the citation ledger, bibliography, source log, and manuscript references aligned
- when a final manuscript bundle is emitted and the runtime supports it, co-deliver Markdown, an editable manuscript artifact when appropriate, and PDF
- if the runtime cannot create files, rebuild archives, expose file paths, or attach downloadable artifacts, state that exact boundary and do not imply delivery

## Durable-State Rule

When coding is in scope, keep the current durable state in the active plan. For research-only or manuscript-only work, keep the durable state in archive status artifacts such as `research-archive/status/research-status.md`, `stage-judgment.md`, and `regression-log.md`. For `/sub` runs, `subagent-runs/<run-id>/status.md` remains the delegated orchestration record, but it does not replace the archive status files or the cumulative ZIP-first delivery contract.

## Stop Rule

If a packaging action would hide earlier evidence or make the current archive harder to audit, do not do it.
