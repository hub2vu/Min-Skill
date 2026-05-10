Citation Ledger Contract

When manuscript work is still exploratory, bibliography and source-log records may remain provisional. Once connected-manuscript integration or final-manuscript closing is active, citation identity must move to one canonical ledger.

Preferred ledger location:

- `research-archive/citations/master-ledger.md`
- optional parallel machine-friendly file: `research-archive/citations/master-ledger.csv`

If both files exist, they must describe the same records.

Minimum canonical fields:

- `canonical_id`
- `first_author`
- `year`
- `title`
- `journal_or_source`
- `doi_or_url`
- `source_type`
- `checked_status`
- `used_in_manuscript`

Recommended supporting fields:

- `full_author_list`
- `volume`
- `issue`
- `pages_or_article_number`
- `checked_against`
- `checked_at`
- `notes`

When `used_in_manuscript` is true, these fields become required rather than merely recommended:

- `full_author_list` or an equivalent author-list integrity field
- `volume` when the source family uses volume numbering
- `issue` when the source family uses issue numbering
- `pages_or_article_number`

Identity rules:

- verify canonical identity against the direct original, publisher page, journal page, DOI landing page, or official index page when source precision matters
- bibliography, source log, and manuscript references may differ in explanatory prose, but they must not disagree on core identity fields for the same record
- every source used in the manuscript must map one-to-one to a ledger record
- provisional placeholders, snippet titles, guessed journals, or surrogate labels are acceptable only before manuscript use
- once `used_in_manuscript` is true, the record must stop being provisional and must carry resolved canonical identity
- once `used_in_manuscript` is true, locator identity must also be resolved so that volume, issue, and pages or article number no longer drift across derived artifacts

Closing rules:

- if the manuscript cites a source inline, the corresponding record must already exist in the ledger
- if bibliography or source-log entries are regenerated or rewritten, derive them from the ledger or update them against the same canonical record set
- if a citation record changes materially, preserve the prior version under an archival path and record the update in chronology
- if the runtime cannot regenerate derived files, state that boundary and do not pretend citation closure

Drift failure includes:

- the same cited work appearing with conflicting title, journal, or year across the ledger, bibliography, source log, and manuscript references
- a manuscript-used source having no canonical record
- a bibliography entry remaining at a provisional placeholder state after final-manuscript closing has begun
- a source-log entry and manuscript reference pointing to different papers under one apparent citation name
