# Tenant PDF Merger

Combines tenant application documents (ID photos, City Skyline application reports, NTN screening
reports, bank statements) into one PDF, grouped by tenant and in a standard order.

- Live site: https://pdf.cityskyline.nyc (once hosting is set up)
- Everything runs in the browser. Documents are never uploaded anywhere.
- The built page is a single self-contained file, so it also works saved locally or emailed.

## Using it

1. Drop the files in. It groups them by tenant and orders each tenant:
   ID photo → application report → screening report → bank statement → pay stub → other.
2. Assign each ID photo to a tenant. Drag the ⋮⋮ handles to move files or whole tenants.
3. Click **Preview pages** to see every page in final order; drag, rotate or remove pages.
4. Name the file and click **Download PDF**.

## RS Renewal Forms (renew.html)

Makes next term's DHCR renewal lease form (RTP-8), lease rider (RA-LR1, Section 2) and preferential
rent rider for a rent-stabilized apartment. Open it from the link at the top of the merger page, or go to
`/renew.html`. Nothing is uploaded or saved.

1. Drop the current term's three files: RTP-8, DHCR rider and PREF rider (PDF or Word).
2. The page reads the tenant, address, owner, lease dates, legal rent, preferential rent, deposit and
   sprinkler answer from them, works out next term with the RGB rates, and lists each item.
   Where the files disagree it says so.
3. Check each item and click **Approve** (edit it first if it's wrong). Changing anything unapproves it.
4. When every item is approved, click **Download 3 files**.

The RGB rates are built into the page (`RGB` in `src/renew.html`). Each June, add the new order and
rebuild. Until then, renewals starting after the last order are offered with the "rate unknown" box checked.

**Second-step (split) increases.** Some orders raise the rent in two steps, such as Order #55's 2-year lease:
2.75% for the first year, then 3.2% on top of the first-year rent. Add the step as the last entry of the order's
row, e.g. `[2, 12, '3.2']` (2-year lease, after 12 months, 3.2%). The RGB rates item in the approval list fills
it in automatically, and a step can also be added or changed there by hand. When there's a step:
- The RTP-8 boxes show the first-step rents, and a signed addendum page listing both steps is added to the RS file.
- The PREF rider states both amounts.
- Next term, the page reads the second-step rent back as the current rent.
The blank forms are DHCR's June 2026 versions; when DHCR revises a form, replace the file in
`vendor/forms/` and check the field names still match.

## Project layout

| Path | What it is |
|------|------------|
| `src/app.html` | The app: HTML, CSS and JavaScript. Edit this. |
| `src/renew.html` | RS Renewal Forms page. |
| `vendor/forms/` | Blank DHCR RTP-8 and RA-LR1 (base64) and the PREF rider Word template. |
| `vendor/` | pdf-lib 1.17.1 (MIT) and pdf.js 3.11.174 (Apache-2.0), from cdnjs. |
| `build.ps1` | Inlines `vendor/` into `src/app.html` and writes `docs/index.html`. |
| `docs/` | What GitHub Pages serves. `index.html` is generated, don't edit it by hand. `CNAME` holds the custom domain. |

## Making an update

```powershell
# 1. Edit src/app.html
# 2. Rebuild the deployed page
powershell -ExecutionPolicy Bypass -File build.ps1
# 3. Commit and push; GitHub Pages redeploys automatically in a minute or two
git add -A
git commit -m "Describe the change"
git push
```

## Hosting (GitHub Pages + IONOS DNS)

- GitHub repo → Settings → Pages: Source "Deploy from a branch", branch `main`, folder `/docs`.
  Custom domain `pdf.cityskyline.nyc`, Enforce HTTPS on.
- IONOS DNS for cityskyline.nyc: CNAME record, host `pdf`, points to `davis421.github.io`.
- A `<meta name="robots" content="noindex">` tag keeps the site out of search engines.
