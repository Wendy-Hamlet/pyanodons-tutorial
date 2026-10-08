# Snapshots a save without touching it: refreshes the save-reading setup (tools/save-env.ps1,
# C:\tmp\cf-save: the player's current mods), copies the save there, adds tools/save-inspector,
# runs it headlessly and leaves save-report.json, entities.json and outposts.json (mining outposts
# with blueprint strings) in C:\tmp\cf-save\data\script-output\cellforge. With -Ticks 3700 or more
# it also runs the save for a minute and writes outpost-measure.json (real mining rates, drill
# status samples) and production-measure.json (what the whole base made and used per second).
#
# Consistency check: the inspector records what the game reports as changed when the save is
# loaded (mods added, removed or updated, startup settings, game version). Any mod or settings
# change other than the inspector itself means the snapshot is not the save as it was played;
# the script then fails (exit 2) unless -AllowModChanges is given.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\inspect-save.ps1 -Save <name|latest|path.zip> [-Ticks 3700]
#        node tools\summarize-save.js
param(
    [Parameter(Mandatory = $true)][string]$Save,
    [int]$Ticks = 10,
    [switch]$AllowModChanges,
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-save'
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'save-env.ps1') -Work $Work

$saves = Join-Path $env:APPDATA 'Factorio\saves'
$source = if ($Save -eq 'latest') {
    Get-ChildItem $saves -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1
} elseif ($Save -like '*.zip') { Get-Item $Save } else { Get-Item (Join-Path $saves "$Save.zip") }
Write-Host "save: $($source.Name), written $($source.LastWriteTime)"
$copy = "$Work\inspect.zip"
Copy-Item $source.FullName $copy -Force

$inspector = "$Work\mods\cf-save-inspector"
Copy-Item -Recurse (Join-Path $PSScriptRoot 'save-inspector') $inspector
$out = "$Work\data\script-output\cellforge"
Remove-Item -Recurse -Force $out -ErrorAction SilentlyContinue

$proc = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
    -ArgumentList '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods", `
        '--benchmark', $copy, '--benchmark-ticks', "$Ticks", '--benchmark-runs', '1' `
    -RedirectStandardOutput "$Work\inspect.txt" -RedirectStandardError "$Work\inspect.err.txt"
Remove-Item -Recurse -Force $inspector

Get-Content "$Work\inspect.txt" | Where-Object { $_ -cmatch 'CF-INSPECT|Error' } | Select-Object -First 10
if ($proc.ExitCode -ne 0) { Write-Host "factorio exited with $($proc.ExitCode); see $Work\inspect.txt"; exit 1 }

$config = (Get-Content "$out\save-report.json" -Raw | ConvertFrom-Json).config
if (-not $config) { Write-Host 'consistency check did not run (no configuration data in the report)'; exit 1 }
$problems = @()
foreach ($p in $config.mod_changes.PSObject.Properties) {
    $problems += "mod $($p.Name): $(if ($p.Value.old) { $p.Value.old } else { 'absent' }) in the save -> $(if ($p.Value.new) { $p.Value.new } else { 'absent' }) here"
}
if ($config.startup_settings_changed) { $problems += 'startup mod settings differ from the save' }
# A newer game version is what the player's own game would load the save with too: a note only.
if ($config.game_old) { Write-Host "note: game version $($config.game_old) in the save -> $($config.game_new) here" }
if ($problems.Count -eq 0) { Write-Host 'consistency: the save loaded with exactly the mods and settings it was played with'; exit 0 }
$problems | ForEach-Object { Write-Host "MISMATCH $_" }
if ($AllowModChanges) { Write-Host 'continuing (-AllowModChanges): the snapshot shows the save as loaded here' }
else { Write-Host 'snapshot is not the save as played; rerun with -AllowModChanges to accept it'; exit 2 }
