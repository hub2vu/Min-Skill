Archive Retention Contract

Archive retention now has two surfaces:

1. internal Knowledge bundle retention
   - preserves the operating archive used by the GPT
2. public research archive retention
   - preserves the user-facing cumulative research ZIP

The public cumulative archive is the live user-facing audit surface.

Core rules:

- on every active research, manuscript, or delegated validation turn that creates or updates durable public artifacts, refresh the public research ZIP on that same turn
- keep current-turn additions together with all preserved prior-turn public files
- build the refreshed public ZIP from the preserved public source tree, not from nested prior delivery ZIPs
- do not silently drop earlier files
- before materially updating a mutable public file, preserve the prior version under an archival path such as `archive/superseded/`
- move obsolete or superseded files into archival paths instead of deleting them
- update the archive manifest whenever files are added, changed, or archived
- update `manifest/update-log.md` with created, updated, archived, and built events in time order
- require second-level timestamp precision in substantive archive files when the runtime can write timestamps
- keep one immutable turn-note for every substantive public turn represented by the cumulative archive
- use second-level timestamp precision in active ZIP filenames through a filesystem-safe token such as `20260420-083843`
- run an extraction smoke test after rebuilding the ZIP
- surface the real public ZIP path or attachment in the visible response when delivery succeeds
- if delivery cannot happen, state the exact boundary and do not imply success
- keep the internal Knowledge ZIP separate from the public research ZIP
- do not let operating files leak into the public research archive

Nested prior delivery ZIPs are not cumulative retention. They are packaging failure.

State files may exist for run coordination, but they do not replace the cumulative ZIP as the visible deliverable. Keep visible delivery centered on the refreshed cumulative archive.
