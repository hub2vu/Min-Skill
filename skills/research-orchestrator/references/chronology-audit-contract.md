Chronology Audit Contract

Chronology is part of research integrity.

When the runtime can create or update durable research artifacts, internal substantive files should preserve these metadata fields near the top:

- `Created_at`
- `Updated_at`
- `Timezone`
- `Turn_id`

When the runtime can create or update public research artifacts, user-facing substantive files should normally preserve user-facing labels for:

- local created time
- UTC created time
- local updated time
- UTC updated time
- timezone
- the turn identifier

Rules:

- `Created_at` is set when the file first becomes a durable artifact and should remain stable afterward
- `Updated_at` changes when the file content changes materially
- `Timezone` should match the active user timezone when available
- `Turn_id` should let related files from the same substantive turn be grouped together
- use second-level precision for these timestamps when the runtime can provide it
- use the user's timezone for local public-facing timestamps when available
- keep UTC explicit for public-facing auditability
- keep public-facing metadata labels and chronology verbs in the user's language when practical

Chronology log:

- preserve `research-archive/manifest/update-log.md` as the turn-by-turn chronology surface
- append created, updated, archived, and built events in time order
- include enough detail that an auditor can tell what changed and when
- keep ZIP-build events explicit

Filename precision:

- active deliverable ZIP names should include a filesystem-safe second-level timestamp token such as `20260420-083843`
- date-only ZIP names are not sufficient when multiple same-day updates can happen

Failure cases include:

- files that materially changed but show no `Updated_at` movement
- chronology logs that skip major created, updated, archived, or built events
- timestamp fields with missing timezone while a user timezone is known
- cumulative ZIP deliverables with only date-level precision when second-level precision is available
