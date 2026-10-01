# Snapshots a save without touching it: copies the save into the isolated setup made by
# tools/dump-data.ps1 (C:\tmp\cf-dump), adds tools/save-inspector, runs it headlessly and leaves
# save-report.json, entities.json and outposts.json (mining outposts with blueprint strings) in
# C:\tmp\cf-dump\data\script-output\cellforge. With -Ticks 3700 or more it also runs the save for
# a minute and writes outpost-measure.json (real mining rates, drill status samples).
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\inspect-save.ps1 -Save Pyanodons [-Ticks 3700]
#        node tools\summarize-save.js
param(
    [Parameter(Mandatory = $true)][string]$Save,
    [int]$Ticks = 10,
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-dump'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$Work\config\config.ini")) { throw "Run tools\dump-data.ps1 first to create $Work" }

$source = Join-Path $env:APPDATA "Factorio\saves\$Save.zip"
$copy = "$Work\inspect-$Save.zip"
Copy-Item $source $copy -Force

$inspector = "$Work\mods\cf-save-inspector"
if (Test-Path $inspector) { Remove-Item -Recurse -Force $inspector }
Copy-Item -Recurse (Join-Path $PSScriptRoot 'save-inspector') $inspector
Remove-Item -Recurse -Force "$Work\data\script-output\cellforge" -ErrorAction SilentlyContinue

$proc = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
    -ArgumentList '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods", `
        '--benchmark', $copy, '--benchmark-ticks', "$Ticks", '--benchmark-runs', '1' `
    -RedirectStandardOutput "$Work\inspect.txt" -RedirectStandardError "$Work\inspect.err.txt"
Remove-Item -Recurse -Force $inspector

Get-Content "$Work\inspect.txt" | Where-Object { $_ -match 'CF-INSPECT|Error|error' } | Select-Object -First 10
if ($proc.ExitCode -ne 0) { Write-Host "factorio exited with $($proc.ExitCode); see $Work\inspect.txt"; exit 1 }
