# Runs the blueprint bench (tools\bp-bench): builds one blueprint of blueprints\ on an empty map
# with unlimited power, full input belts and emptied output belts, and prints whether every
# machine reaches its recipe's full speed (see tools\bp-bench\control.lua). Benches are
# tools\bp-bench\benches\<name>.json: the blueprint file, sources {x, y, item} (tiles in the
# blueprint's own coordinates), sinks {x, y}, fluid_sinks {x, y[, rate]} (a pipe tile; its segment emptied, or at most rate per second), items to prime machines with, the technologies to
# count as researched, the technology labs research, warm-up and measuring time in seconds, and
# variants that add sources or sinks.
# Runs in the save-reading setup (tools\save-env.ps1, C:\tmp\cf-save: the player's current mods),
# because the fixed setup C:\tmp\cf-dump no longer loads in this game version. The bench mod is
# removed again afterwards.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\bp-bench.ps1 -Bench ash-separation [-Variant both-belts]
param(
    [Parameter(Mandatory = $true)][string]$Bench,
    [string]$Variant = '',
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-save'
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'save-env.ps1') -Work $Work

$from = Join-Path $PSScriptRoot 'bp-bench'
$specText = Get-Content "$from\benches\$Bench.json" -Raw -Encoding utf8
$spec = $specText | ConvertFrom-Json
$blueprint = (Get-Content (Join-Path $PSScriptRoot "..\blueprints\$($spec.blueprint).txt") -Raw).Trim()
$ticks = ([int]$spec.warm + [int]$spec.measure) * 60 + 2
$mod = "$Work\mods\cf-bp-bench"
$save = "$Work\bench.zip"
$utf8 = New-Object Text.UTF8Encoding $false
try {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
    Copy-Item -Recurse $from $mod
    [IO.File]::WriteAllText("$mod\bench-data.lua",
        "return { name = `"$Bench`", variant = `"$Variant`", spec = [==[$specText]==], blueprint = `"$blueprint`" }`n", $utf8)
    $common = '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods"
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru -ArgumentList ($common + '--create', $save) `
        -RedirectStandardOutput "$Work\bench-create.txt" -RedirectStandardError "$Work\bench-create.err.txt"
    if ($p.ExitCode -ne 0) { throw "map creation failed; see $Work\bench-create.txt" }
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList ($common + '--benchmark', $save, '--benchmark-ticks', "$ticks", '--benchmark-runs', '1') `
        -RedirectStandardOutput "$Work\bench-run.txt" -RedirectStandardError "$Work\bench-run.err.txt"
    Get-Content "$Work\bench-create.txt", "$Work\bench-run.txt" -Encoding utf8 |
        Where-Object { $_ -cmatch 'CF-[A-Z]+ |Error|UPS' } | ForEach-Object { $_ -creplace '^.*CF-[A-Z]+ ', '' }
    if ($p.ExitCode -ne 0) { throw "run failed; see $Work\bench-run.txt" }
}
finally {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
}
