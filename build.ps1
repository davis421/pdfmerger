# Builds docs/index.html (served by GitHub Pages): src/app.html with the vendor libraries inlined, so the page is one
# self-contained file that also works offline when saved or emailed.
# Usage:  powershell -ExecutionPolicy Bypass -File build.ps1 [-Out path]
param([string]$Out = (Join-Path $PSScriptRoot 'docs\index.html'))
$utf8 = New-Object System.Text.UTF8Encoding($false)
$read = { param($p) [IO.File]::ReadAllText((Join-Path $PSScriptRoot $p), $utf8) }
$html = & $read 'src\app.html'
$html = $html.Replace('/*@@PDFLIB@@*/', (& $read 'vendor\pdf-lib.min.js'))
$html = $html.Replace('/*@@PDFJS@@*/', (& $read 'vendor\pdf.min.js'))
$html = $html.Replace('/*@@PDFJSWORKER@@*/', (& $read 'vendor\pdf.worker.min.js'))
if ($html.Contains('/*@@')) { throw 'A library placeholder was not replaced' }
[IO.File]::WriteAllText($Out, $html, $utf8)
"wrote $Out ($([math]::Round((Get-Item -LiteralPath $Out).Length / 1KB)) KB)"
