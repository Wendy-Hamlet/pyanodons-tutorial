# Mirrors the player's current mods into an isolated setup for reading saves (C:\tmp\cf-save):
# zip mods hard-linked, folder mods (such as junctioned development mods) copied, mod-list.json
# and mod-settings.dat copied. Unlike C:\tmp\cf-dump (a fixed snapshot that measurements run
# against), this setup is refreshed before every save inspection, so a save loads with exactly the
# mods the player's game would load it with. The player's folders are only read.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\save-env.ps1
param([string]$Work = 'C:\tmp\cf-save')
$ErrorActionPreference = 'Stop'
$mods = Join-Path $env:APPDATA 'Factorio\mods'

New-Item -ItemType Directory -Force "$Work\config", "$Work\data" | Out-Null
if (Test-Path "$Work\mods") {
    # Only plain files and copied folders live here (never links to folders), so a recursive
    # delete cannot reach into the player's mods.
    $linked = Get-ChildItem "$Work\mods" -Directory | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }
    if ($linked) { throw "unexpected folder link in $Work\mods: $($linked.Name -join ', ')" }
    Remove-Item -Recurse -Force "$Work\mods"
}
New-Item -ItemType Directory "$Work\mods" | Out-Null
Get-ChildItem $mods -Filter *.zip | ForEach-Object {
    New-Item -ItemType HardLink -Path (Join-Path "$Work\mods" $_.Name) -Target $_.FullName | Out-Null
}
Get-ChildItem $mods -Directory | ForEach-Object {
    Copy-Item -Recurse $_.FullName (Join-Path "$Work\mods" $_.Name)
}
Copy-Item (Join-Path $mods 'mod-list.json'), (Join-Path $mods 'mod-settings.dat') "$Work\mods\"
$writeData = ($Work -replace '\\', '/') + '/data'
Set-Content "$Work\config\config.ini" "[path]`nread-data=__PATH__executable__/../../data`nwrite-data=$writeData" -Encoding ascii
$folders = @(Get-ChildItem "$Work\mods" -Directory).Name
Write-Host "save setup: $(@(Get-ChildItem "$Work\mods" -Filter *.zip).Count) zip mods, folder mods: $($folders -join ', ')"
