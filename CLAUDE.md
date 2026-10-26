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

## Testing
- Browser file:// access may be blocked in the preview pane; serve the folder over localhost
  (e.g. a small PowerShell HttpListener) and drive `window.__merger` (addFiles, build, state, goPages)
  from the console. Use synthetic test PDFs made with pdf-lib, not real tenant documents.
- Keep text lines in synthetic PDFs short; text running off the page isn't extracted.
