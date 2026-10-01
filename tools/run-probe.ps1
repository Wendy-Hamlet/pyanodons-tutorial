# Runs one measurement mod (tools\<probe>) in the fixed Py setup: copies it into the setup's mods
# folder, creates a map, runs the map for the given ticks, prints the mod's log lines ("CF-<TAG> ...")
# and removes the mod again (a mod left there would run its on_init in every later run).
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\run-probe.ps1 inserter-probe [-Ticks 4000]
param(
    [Parameter(Mandatory = $true)][string]$Probe,
    [int]$Ticks = 4000,
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-dump'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$Work\config\config.ini")) { throw "Run tools\dump-data.ps1 first to create $Work" }
$source = Join-Path $PSScriptRoot $Probe
$name = (Get-Content "$source\info.json" -Raw | ConvertFrom-Json).name
$mod = "$Work\mods\$name"
$save = "$Work\$Probe.zip"
try {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
    Copy-Item -Recurse $source $mod
    $common = '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods"
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru -ArgumentList ($common + '--create', $save) `
        -RedirectStandardOutput "$Work\$Probe-create.txt" -RedirectStandardError "$Work\$Probe-create.err.txt"
    if ($p.ExitCode -ne 0) { throw "map creation failed; see $Work\$Probe-create.txt" }
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList ($common + '--benchmark', $save, '--benchmark-ticks', "$Ticks", '--benchmark-runs', '1') `
        -RedirectStandardOutput "$Work\$Probe-run.txt" -RedirectStandardError "$Work\$Probe-run.err.txt"
    Get-Content "$Work\$Probe-create.txt", "$Work\$Probe-run.txt" | Where-Object { $_ -cmatch 'CF-[A-Z]+ |Error' } |
        ForEach-Object { $_ -creplace '^.*CF-[A-Z]+ ', '' }
    if ($p.ExitCode -ne 0) { throw "run failed; see $Work\$Probe-run.txt" }
}
finally {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
}
