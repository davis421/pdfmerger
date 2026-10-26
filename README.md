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

## Project layout

| Path | What it is |
|------|------------|
| `src/app.html` | The app: HTML, CSS and JavaScript. Edit this. |
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
