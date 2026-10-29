# Notes for Claude

Internal tool for City Skyline Realty staff (non-developers). The owner vibe-codes with Claude;
explain changes in plain language.

## How it works
- Single page app in `src/app.html`; no framework, no npm. `build.ps1` inlines the three vendor
  libraries into `docs/index.html`, which GitHub Pages serves (branch `main`, folder `/docs`,
  custom domain pdf.cityskyline.nyc via `docs/CNAME`; DNS is a CNAME at IONOS). The owner wants
  only GitHub + IONOS, no other hosting. Always run `build.ps1` and commit `docs/index.html` with
  source changes.
- Privacy is a core promise: tenant documents (SSNs, bank statements) must never leave the browser.
  No analytics, no network calls with file data, no external scripts at runtime.
- pdf.js worker is inlined as `<script type="text/plain" id="pdfjs-worker">` and loaded via a Blob URL.
  Vendor files must not contain `</script` (checked when they were added).
- Merging uses pdf-lib. RC4 (V1/V2, R2/R3) edit-restricted PDFs are decrypted in `decryptDoc`;
  anything pdf-lib can't copy falls back to rendering pages as JPEGs via pdf.js.
- Auto-sorting (`classify`, `autoGroup`) is tuned to City Skyline/Docuverus application reports
  ("Last Name X Suffix … First Name Y Middle Name") and NTN Decision Point screening reports
  ("Applicant Information Last, First"). If those layouts change, update the regexes there.
- Images: EXIF orientation is applied, plus a manual `turn`. Pages are US Letter with an 18pt margin.

## RS Renewal Forms (`src/renew.html` → `docs/renew.html`)
- Flow: drop the current term's RTP-8, DHCR rider and PREF rider → `readDoc` reads them in the browser
  (pdf.js field values, or text by position on the blank RTP-8 for older/flattened copies; .docx via
  DecompressionStream) → `suggest` picks values and flags disagreements → user approves every row
  (approval is tied to the exact value; any change unapproves) → download 3 files. No AI service, no storage.
- RGB orders are the `RGB` table in the page; add the new order each June and rebuild (check it against the
  RGB's Apartment Orders chart). Split orders get a 6th entry `[lease term, starts after N months, %]`
  (#52, #53, #55); the step is applied to the first-step rent. The RGB row in the approval suite fills the step
  from the order and lets it be added or changed by hand (with a warning when it differs from the order).
- The RTP-8 has no boxes for a step, so its boxes show first-step amounts and `addStepPage` appends an addendum
  page. Its "N-year lease, months a-b (...): legal rent $x; preferential rent $y" lines, the PREF rider's
  "$a (first year) and $b (second year, from date)" wording, and "a / b" in a rent box are read back next term
  (the later amount is the current rent). Keep those formats in sync with `parseRtp8` / `parsePref`.
- Fills DHCR RTP-8 (06/26) and RA-LR1 (06/26) with pdf-lib by field name (`rtp8Values`, `riderValues`);
  fields stay editable. Checkbox meanings: Check Box13 = Column C rate unknown, Check Box14 = Column F
  different rent, Check Box1/2 = item 5 agreement Yes/No, Check Box4/3 = item 10 sprinkler does/does not.
  Part B and signature dates are left blank. A new DHCR revision means re-checking these names.
- Money is integer cents and rates are parts per 100,000 so rounding is exact (half-up to the cent).
  Pref = current pref × (1 + RGB %), capped at the new legal rent (HSTPA).
- Offers can't be dated before today or more than 150 days before the lease ends; late offers warn.
- PREF rider: `vendor/forms/pref-rider-template.docx` has `{{PLACEHOLDERS}}`; `build.ps1` embeds its zip
  entries and the page re-zips them (stored) after replacing text in `word/document.xml`.
- No tenant data is built into the page and nothing is saved (no localStorage). Test with synthetic
  forms made from `FORMS` via `window.__renew.fillPdf`, never real tenant files.

## Testing
- Browser file:// access may be blocked in the preview pane; serve the folder over localhost
  (e.g. a small PowerShell HttpListener) and drive `window.__merger` (addFiles, build, state, goPages)
  from the console. Use synthetic test PDFs made with pdf-lib, not real tenant documents.
- Keep text lines in synthetic PDFs short; text running off the page isn't extracted.
