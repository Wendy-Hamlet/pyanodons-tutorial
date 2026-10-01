# Checks the companion's recorder in the isolated Py setup, with tools/recorder-check driving it
# (300-byte segments, 3 kept, simulated production, research finished by script at minutes 5
# and 28). Run 1 plays the new map for 60 minutes: expect 3 activity segments left and both
# research lines. Run 2 plays the SAME save again for 20 minutes, which is what loading an earlier
# save looks like: expect the summary to cover 0:00-0:20 with only the minute-5 research, and
# the leftover segments of run 1 to be ignored. Both mods are removed again afterwards.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\check-recorder.ps1
param(
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-dump'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$Work\config\config.ini")) { throw "Run tools\dump-data.ps1 first to create $Work" }
$companion = "$Work\mods\py-tutorial-companion"
$check = "$Work\mods\cf-recorder-check"
$save = "$Work\recorder.zip"
$recorded = "$Work\data\script-output\py-tutorial-companion\recorder"
$common = '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods"

function Invoke-Factorio($name, $extra) {
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru -ArgumentList ($common + $extra) `
        -RedirectStandardOutput "$Work\recorder-$name.txt" -RedirectStandardError "$Work\recorder-$name.err.txt"
    if ($p.ExitCode -ne 0) { throw "$name failed; see $Work\recorder-$name.txt" }
}

function Show-Run($title) {
    Write-Host "--- $title"
    Get-ChildItem $recorded -Recurse -File | ForEach-Object { '{0,-22} {1,6} bytes' -f $_.Name, $_.Length }
    node (Join-Path $PSScriptRoot 'recorder-summary.js') --minutes 600 $recorded
}

try {
    foreach ($m in $companion, $check) { if (Test-Path $m) { Remove-Item -Recurse -Force $m } }
    Copy-Item -Recurse (Join-Path $PSScriptRoot 'companion') $companion
    Copy-Item -Recurse (Join-Path $PSScriptRoot 'recorder-check') $check
    Remove-Item -Recurse -Force $recorded -ErrorAction SilentlyContinue

    Invoke-Factorio 'create' @('--create', $save)
    Invoke-Factorio 'run1' @('--benchmark', $save, '--benchmark-ticks', '216000', '--benchmark-runs', '1')
    Show-Run 'run 1: 60 minutes from the new map'
    Invoke-Factorio 'run2' @('--benchmark', $save, '--benchmark-ticks', '72000', '--benchmark-runs', '1')
    Show-Run 'run 2: 20 minutes from the same save (an earlier save loaded)'
}
finally {
    foreach ($m in $companion, $check) { if (Test-Path $m) { Remove-Item -Recurse -Force $m } }
}
