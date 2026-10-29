# Builds the pages GitHub Pages serves from docs/, each one self-contained so it also works offline when saved or emailed:
#   docs/index.html  - PDF Merger: src/app.html with the vendor libraries inlined
#   docs/renew.html  - RS Renewal Forms: src/renew.html with pdf-lib, pdf.js and the blank DHCR forms + PREF template inlined
# Usage:  powershell -ExecutionPolicy Bypass -File build.ps1 [-OutDir path]
param([string]$OutDir = (Join-Path $PSScriptRoot 'docs'))
$utf8 = New-Object System.Text.UTF8Encoding($false)
$read = { param($p) [IO.File]::ReadAllText((Join-Path $PSScriptRoot $p), $utf8) }
function Write-Page($name, $html) {
  if ($html.Contains('/*@@')) { throw "A placeholder was not replaced in $name" }
  $out = Join-Path $OutDir $name
  [IO.File]::WriteAllText($out, $html, $utf8)
  "wrote $out ($([math]::Round((Get-Item -LiteralPath $out).Length / 1KB)) KB)"
}

$html = & $read 'src\app.html'
$html = $html.Replace('/*@@PDFLIB@@*/', (& $read 'vendor\pdf-lib.min.js'))
$html = $html.Replace('/*@@PDFJS@@*/', (& $read 'vendor\pdf.min.js'))
$html = $html.Replace('/*@@PDFJSWORKER@@*/', (& $read 'vendor\pdf.worker.min.js'))
Write-Page 'index.html' $html

# Renewal forms: blank PDFs as base64, the PREF Word template as [name, base64] entries the page re-zips after filling
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead((Join-Path $PSScriptRoot 'vendor\forms\pref-rider-template.docx'))
try {
  $entries = foreach ($e in $zip.Entries) {
    if ($e.FullName.EndsWith('/')) { continue }
    $ms = New-Object IO.MemoryStream; $s = $e.Open(); $s.CopyTo($ms); $s.Close()
    '["' + $e.FullName + '","' + [Convert]::ToBase64String($ms.ToArray()) + '"]'
  }
} finally { $zip.Dispose() }
$forms = '{"rtp8":"' + (& $read 'vendor\forms\rtp-8-06-2026-fillable.pdf.b64').Trim() + '",' +
         '"ralr1":"' + (& $read 'vendor\forms\ra-lr1-06-2026-fillable.pdf.b64').Trim() + '",' +
         '"prefDocx":[' + ($entries -join ',') + ']}'
$html = & $read 'src\renew.html'
$html = $html.Replace('/*@@PDFLIB@@*/', (& $read 'vendor\pdf-lib.min.js'))
$html = $html.Replace('/*@@PDFJS@@*/', (& $read 'vendor\pdf.min.js'))
$html = $html.Replace('/*@@PDFJSWORKER@@*/', (& $read 'vendor\pdf.worker.min.js'))
$html = $html.Replace('/*@@FORMS@@*/', $forms)
Write-Page 'renew.html' $html
