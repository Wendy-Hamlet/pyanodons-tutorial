# Checks the blueprint round trip of tools/companion in the isolated Py setup: pushes the book,
# imports it in the engine (through the companion's own code), exports it, and runs
# `bp-sync.js pull --dry` on the unchanged export (expect all "unchanged") and on an edited one
# (expect page 2 CHANGED, page 1 NEW under its new label and missing under the old one). Both mods are removed again afterwards.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\check-companion.ps1
param(
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-dump'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$Work\config\config.ini")) { throw "Run tools\dump-data.ps1 first to create $Work" }
$companion = "$Work\mods\py-tutorial-companion"
$check = "$Work\mods\cf-companion-check"
$save = "$Work\companion.zip"
$exports = "$Work\data\script-output\py-tutorial-companion"

node (Join-Path $PSScriptRoot 'bp-sync.js') push
if ($LASTEXITCODE -ne 0) { throw 'push failed' }
try {
    foreach ($m in $companion, $check) { if (Test-Path $m) { Remove-Item -Recurse -Force $m } }
    Copy-Item -Recurse (Join-Path $PSScriptRoot 'companion') $companion
    Copy-Item -Recurse (Join-Path $PSScriptRoot 'companion-check') $check
    Remove-Item -Recurse -Force $exports -ErrorAction SilentlyContinue

    $common = '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods"
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru -ArgumentList ($common + '--create', $save) `
        -RedirectStandardOutput "$Work\companion-create.txt" -RedirectStandardError "$Work\companion-create.err.txt"
    if ($p.ExitCode -ne 0) { throw "map creation failed; see $Work\companion-create.txt" }
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList ($common + '--benchmark', $save, '--benchmark-ticks', '3', '--benchmark-runs', '1') `
        -RedirectStandardOutput "$Work\companion-run.txt" -RedirectStandardError "$Work\companion-run.err.txt"
    Get-Content "$Work\companion-run.txt" | Where-Object { $_ -cmatch 'CF-COMPANION |Error' } |
        ForEach-Object { $_ -replace '^.*CF-COMPANION ', '' }
    if ($p.ExitCode -ne 0) { throw "run failed; see $Work\companion-run.txt" }
}
finally {
    foreach ($m in $companion, $check) { if (Test-Path $m) { Remove-Item -Recurse -Force $m } }
}
Write-Host '--- unchanged export'
node (Join-Path $PSScriptRoot 'bp-sync.js') pull --dry "$exports\export.txt"
Write-Host '--- edited export'
node (Join-Path $PSScriptRoot 'bp-sync.js') pull --dry "$exports\export-edited.txt"
