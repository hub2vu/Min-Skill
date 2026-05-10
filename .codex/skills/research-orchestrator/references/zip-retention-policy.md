Zip Retention Policy

Read with `references/archive-retention-contract.md`.

Treat cumulative packaging as additive and auditable.

- keep the internal Knowledge ZIP and the user-facing public research ZIP as separate archive classes
- refresh the public research ZIP on every active turn that creates or updates durable public artifacts
- keep the refreshed public ZIP cumulative, not current-turn-only
- build it from preserved public source files rather than nested prior delivery ZIPs
- preserve prior mutable-file versions under archival paths before overwriting live public files
- keep plan records, rationale, notes, manifests, and evidence summaries aligned with the active workflow
- keep `manifest/update-log.md` aligned with created, updated, archived, and built events
- keep one immutable turn-note for every substantive public turn
- use a second-level timestamp token in active ZIP filenames
- surface the real public ZIP path or attachment when delivery is possible
- do not substitute prose-only ZIP status for delivery
- do not let helper state files displace the public cumulative ZIP as the visible delivery artifact
- keep operating files out of the public research ZIP
- if the runtime cannot create, rebuild, expose, or attach the ZIP, state that exact boundary and do not imply success
- if an artifact becomes obsolete or superseded, move it to an archival path instead of deleting it
- keep the archive source tree on disk so later turns can patch files and rebuild the ZIP cleanly
