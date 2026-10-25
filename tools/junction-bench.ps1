# Runs the junction bench (tools\junction-bench): builds the rails and signals of one blueprint of
# blueprints\ on an empty map and measures it (see tools\junction-bench\control.lua).
#   -Mode map      writes script-output\junction-bench\<name>-map.json in the setup's data folder
#                  (render it with: node tools\junction-bench.js render <name>)
#   -Mode traffic  sends trains through it; -Options is JSON, e.g. '{"scenario":"mix","minutes":30}'
#   -Mode run      one train round a grid block until its fuel is gone
#   -Mode station  builds the whole blueprint (every entity and its settings) and sends trains to
#                  its train stop (see tools\junction-bench\control.lua)
# Runs in the save-reading setup (tools\save-env.ps1, C:\tmp\cf-save: the player's current mods, so
# the rolling stock is Py's). The bench mod is removed again afterwards.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\junction-bench.ps1 -Blueprint blueprint-2 -Mode map
param(
    [Parameter(Mandatory = $true)][string]$Blueprint,
    [string]$Mode = 'map',
    [string]$Options = '{}',
    [string]$Name = '',
    [int]$Ticks = 2,
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-save'
)
$ErrorActionPreference = 'Stop'
# -Options @file.json reads them from a UTF-8 file (labels in Chinese survive that, not a command line).
if ($Options.StartsWith('@')) { $Options = [IO.File]::ReadAllText($Options.Substring(1), [Text.Encoding]::UTF8) }
& (Join-Path $PSScriptRoot 'save-env.ps1') -Work $Work
if (-not $Name) { $Name = $Blueprint }

$from = Join-Path $PSScriptRoot 'junction-bench'
$bpFile = if (Test-Path $Blueprint) { $Blueprint } else { Join-Path $PSScriptRoot "..\blueprints\$Blueprint.txt" }
$entities = node (Join-Path $PSScriptRoot 'junction-bench.js') entities $bpFile
if ($LASTEXITCODE -ne 0) { throw "could not read $bpFile" }
$bpString = (Get-Content $bpFile -Raw).Trim()
$mod = "$Work\mods\cf-junction-bench"
$save = "$Work\junction.zip"
$utf8 = New-Object Text.UTF8Encoding $false
try {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
    Copy-Item -Recurse $from $mod
    [IO.File]::WriteAllText("$mod\bench-data.lua",
        "return { name = [==[$Name]==], mode = `"$Mode`", options = [==[$Options]==], entities = [==[$entities]==], blueprint = [==[$bpString]==] }`n", $utf8)
    $common = '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods"
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru -ArgumentList ($common + '--create', $save) `
        -RedirectStandardOutput "$Work\junction-create.txt" -RedirectStandardError "$Work\junction-create.err.txt"
    if ($p.ExitCode -ne 0) { throw "map creation failed; see $Work\junction-create.txt" }
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList ($common + '--benchmark', $save, '--benchmark-ticks', "$Ticks", '--benchmark-runs', '1') `
        -RedirectStandardOutput "$Work\junction-run.txt" -RedirectStandardError "$Work\junction-run.err.txt"
    Get-Content "$Work\junction-create.txt", "$Work\junction-run.txt" -Encoding utf8 |
        Where-Object { $_ -cmatch 'CF-[A-Z]+ |Error' } | ForEach-Object { $_ -creplace '^.*CF-[A-Z]+ ', '' }
    if ($p.ExitCode -ne 0) { throw "run failed; see $Work\junction-run.txt" }
}
finally {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
}
