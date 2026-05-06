Final Manuscript Validator Contract

Use this contract when a public archive contains a connected manuscript, a full manuscript, or any final-manuscript delivery bundle.

Minimum must-pass checks:

- one canonical citation ledger exists
- every manuscript-used source maps one-to-one to a ledger record
- bibliography, source log, and manuscript references agree on author-list integrity, year, title, journal or source, and locator fields for manuscript-used items
- citation style is internally consistent
- the manuscript makes competing explanations and the judgment rule for preferring one interpretation visible as a dedicated subsection or clearly separated paragraph group when the genre is literature-based interpretive review
- the manuscript makes it clear enough which claims are directly evidenced, which are cross-source synthesis, and which remain uncertain
- the limitations section still marks unresolved quantitative, data, or scope boundaries
- the delivery bundle includes Markdown manuscript output, an editable manuscript artifact when such an artifact is emitted, and PDF when the runtime supports PDF generation
- if PDF cannot be generated, the archive states that exact boundary instead of silently omitting the format

Archive-level checks:

- the manuscript bundle remains cumulative and subject-centered
- manuscript-closing updates preserve prior mutable versions under archival paths when they are materially replaced
- the chronology log records manuscript-closing events clearly enough to audit what changed

Failure examples:

- inline citations or final references that do not correspond to the ledger
- bibliography and source log still carrying different journal identity for the same manuscript-used source
- bibliography, source log, or manuscript references still disagreeing on volume, issue, pages, or article number for a manuscript-used source
- a manuscript that reads like generic review summary even though competing-explanation and argument-ledger artifacts exist in the same archive
- a final manuscript bundle that emits DOCX or equivalent editable output but omits PDF without an explicit runtime boundary
