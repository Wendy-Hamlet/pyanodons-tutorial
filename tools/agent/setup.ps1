# Builds the isolated setup the agent plays in, C:\tmp\cf-agent: the player's Py mods (zips
# hard-linked from %APPDATA%\Factorio\mods, never modified), the mod settings their Py save was
# played with (taken from C:\tmp\cf-save, which mirrors that session), the agent mod (a junction
# to tools\agent\mod, so edits apply on the next server start), server settings with RCON.
# Re-running keeps saves and data; it only refreshes config, mods and settings.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\agent\setup.ps1 [-Mirror]
#   -Mirror  for a copy of the player's save: exactly the player's current mods (every zip
#            hard-linked, folder mods copied, their mod-list.json and mod-settings.dat) plus the
#            agent mod, as tools\save-env.ps1 mirrors them for save reading
param(
    [switch]$Mirror,
    [string]$Work = 'C:\tmp\cf-agent',
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio',
    [string]$SettingsFrom = 'C:\tmp\cf-save\mods\mod-settings.dat'
)
$ErrorActionPreference = 'Stop'
$userMods = Join-Path $env:APPDATA 'Factorio\mods'

# The player's Py session (Py-exploration save): every Py mod plus their helper mods.
$mods = @(
    'pymodpack', 'pyalienlife', 'pyalienlifegraphics', 'pyalienlifegraphics2', 'pyalienlifegraphics3',
    'pyalternativeenergy', 'pyalternativeenergygraphics', 'pycoalprocessing', 'pycoalprocessinggraphics',
    'pyfusionenergy', 'pyfusionenergygraphics', 'pyhightech', 'pyhightechgraphics', 'pyindustry',
    'pyindustrygraphics', 'pypetroleumhandling', 'pypetroleumhandlinggraphics', 'pypostprocessing',
    'pyrawores', 'pyraworesgraphics', 'py_quick_start',
    'aotixpy', 'aotixzhcn', 'blueprint-sandboxes', 'cybersyn', 'DoingThingsByHand',
    'enable-all-feature-flags', 'even-distribution', 'factoryplanner', 'far-reach', 'flib', 'helmod',
    'informatron', 'Milestones', 'PipeVisualizer-2-1-Support', 'pump-anywhere-fork', 'RateCalculator'
)

foreach ($d in 'config', 'mods', 'data', 'saves') { New-Item -ItemType Directory -Force "$Work\$d" | Out-Null }

@"
[path]
read-data=__PATH__executable__/../../data
write-data=$($Work -replace '\\', '/')/data
[general]
locale=zh-CN
"@ | Set-Content "$Work\config\config.ini" -Encoding ascii

if ($Mirror) {
    # Copied folder mods are plain folders; pt-agent is a junction and never deleted recursively.
    Get-ChildItem "$Work\mods" -Filter *.zip | Remove-Item -Force
    Get-ChildItem "$Work\mods" -Directory | Where-Object { -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } |
        ForEach-Object { Remove-Item -Recurse -Force $_.FullName }
    Get-ChildItem $userMods -Filter *.zip | ForEach-Object {
        New-Item -ItemType HardLink -Path (Join-Path "$Work\mods" $_.Name) -Target $_.FullName | Out-Null
    }
    Get-ChildItem $userMods -Directory | ForEach-Object { Copy-Item -Recurse $_.FullName (Join-Path "$Work\mods" $_.Name) }
    $agent = Join-Path $PSScriptRoot 'mod'
    $link = "$Work\mods\pt-agent"
    if (-not (Test-Path $link)) { New-Item -ItemType Junction -Path $link -Target $agent | Out-Null }
    $list = @((Get-Content (Join-Path $userMods 'mod-list.json') -Raw | ConvertFrom-Json).mods |
            Where-Object { $_.name -ne 'pt-agent' } | ForEach-Object { @{ name = $_.name; enabled = [bool]$_.enabled } })
    $list += @{ name = 'pt-agent'; enabled = $true }
    @{ mods = $list } | ConvertTo-Json -Depth 3 | Set-Content "$Work\mods\mod-list.json" -Encoding ascii
    Copy-Item (Join-Path $userMods 'mod-settings.dat') "$Work\mods\mod-settings.dat" -Force
    $mods = @($list | Where-Object { $_.enabled })
}
else {
# Mods: hard links to the player's zips (same volume not required for reading, so fall back to copies).
Get-ChildItem "$Work\mods" -Filter *.zip | Remove-Item -Force
foreach ($m in $mods) {
    $zip = Get-ChildItem $userMods -Filter "${m}_*.zip" | Sort-Object Name | Select-Object -Last 1
    if (-not $zip) { throw "mod $m not found in $userMods" }
    $target = Join-Path "$Work\mods" $zip.Name
    try { New-Item -ItemType HardLink -Path $target -Target $zip.FullName -ErrorAction Stop | Out-Null }
    catch { Copy-Item $zip.FullName $target }
}
$agent = Join-Path $PSScriptRoot 'mod'
$link = "$Work\mods\pt-agent"
if (-not (Test-Path $link)) { New-Item -ItemType Junction -Path $link -Target $agent | Out-Null }

$list = @(@{ name = 'base'; enabled = $true }, @{ name = 'elevated-rails'; enabled = $true },
    @{ name = 'quality'; enabled = $false }, @{ name = 'recycler'; enabled = $false }, @{ name = 'space-age'; enabled = $false })
$list += $mods | ForEach-Object { @{ name = $_; enabled = $true } }
$list += @{ name = 'pt-agent'; enabled = $true }
@{ mods = $list } | ConvertTo-Json -Depth 3 | Set-Content "$Work\mods\mod-list.json" -Encoding ascii
Copy-Item $SettingsFrom "$Work\mods\mod-settings.dat" -Force
}

# Server: never paused for lack of players, not visible anywhere, autosaves every 10 minutes.
@{
    name = 'pt-agent'; description = 'Claude plays Py'; visibility = @{ public = $false; lan = $false }
    require_user_verification = $false; max_players = 0; game_password = 'pt-agent-local'
    autosave_interval = 10; autosave_slots = 6; autosave_only_on_server = $true; non_blocking_saving = $false
    auto_pause = $false; auto_pause_when_players_connect = $false; only_admins_can_pause_the_game = $true
} | ConvertTo-Json | Set-Content "$Work\server-settings.json" -Encoding ascii
Write-Host "setup ready in $Work ($($mods.Count) mods + pt-agent)"
