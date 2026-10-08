# Runs one measurement mod (tools\<probe>) inside a copy of one of the player's saves, in the
# save-reading setup (tools\save-env.ps1, C:\tmp\cf-save: the player's current mods): mirrors the
# mods, copies the save, adds the probe (it gets on_init when the save loads, like
# tools\save-inspector), runs the save headlessly for the given ticks, prints the probe's log
# lines ("CF-<TAG> ...") and removes the probe again. The player's save is only copied.
# -Variant is written into the probe as variant.lua (`return "<Variant>"`), so one probe can run
# several versions of an experiment.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\save-probe.ps1 -Save <name|latest|path.zip>
#          -Probe steel-probe [-Ticks 43200] [-Variant as-built]
param(
    [Parameter(Mandatory = $true)][string]$Save,
    [Parameter(Mandatory = $true)][string]$Probe,
    [int]$Ticks = 3600,
    [string]$Variant = '',
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-save'
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'save-env.ps1') -Work $Work

$saves = Join-Path $env:APPDATA 'Factorio\saves'
$source = if ($Save -eq 'latest') {
    Get-ChildItem $saves -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1
} elseif ($Save -like '*.zip') { Get-Item $Save } else { Get-Item (Join-Path $saves "$Save.zip") }
Write-Host "save: $($source.Name), written $($source.LastWriteTime); probe $Probe $Variant"
$copy = "$Work\probe.zip"
Copy-Item $source.FullName $copy -Force

$from = Join-Path $PSScriptRoot $Probe
$name = (Get-Content "$from\info.json" -Raw | ConvertFrom-Json).name
$mod = "$Work\mods\$name"
try {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
    Copy-Item -Recurse $from $mod
    Set-Content "$mod\variant.lua" "return `"$Variant`"" -Encoding ascii
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods", `
            '--benchmark', $copy, '--benchmark-ticks', "$Ticks", '--benchmark-runs', '1' `
        -RedirectStandardOutput "$Work\probe.txt" -RedirectStandardError "$Work\probe.err.txt"
    Get-Content "$Work\probe.txt" | Where-Object { $_ -cmatch 'CF-[A-Z]+ |Error' } |
        ForEach-Object { $_ -creplace '^.*CF-[A-Z]+ ', '' }
    if ($p.ExitCode -ne 0) { throw "run failed; see $Work\probe.txt" }
}
finally {
    if (Test-Path $mod) { Remove-Item -Recurse -Force $mod }
}
