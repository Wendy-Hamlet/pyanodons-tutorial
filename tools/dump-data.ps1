# Dumps data.raw for the player's exact mod set (mod-list.json + mod-settings.dat) into
# $Work\data\script-output\data-raw-dump.json. Mods are hard-linked, not copied; the player's
# own config and mods folder are only read.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\dump-data.ps1
#        node --max-old-space-size=4096 tools\analyze-py.js
param(
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-dump'
)
$ErrorActionPreference = 'Stop'
$mods = Join-Path $env:APPDATA 'Factorio\mods'

if (Test-Path $Work) { Remove-Item -Recurse -Force $Work }
New-Item -ItemType Directory -Force "$Work\config", "$Work\data", "$Work\mods" | Out-Null
Get-ChildItem $mods -Filter *.zip | ForEach-Object {
    New-Item -ItemType HardLink -Path (Join-Path "$Work\mods" $_.Name) -Target $_.FullName | Out-Null
}
Copy-Item (Join-Path $mods 'mod-list.json'), (Join-Path $mods 'mod-settings.dat') "$Work\mods\"
$writeData = ($Work -replace '\\', '/') + '/data'
Set-Content "$Work\config\config.ini" "[path]`nread-data=__PATH__executable__/../../data`nwrite-data=$writeData" -Encoding ascii

$proc = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
    -ArgumentList '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods", '--dump-data' `
    -RedirectStandardOutput "$Work\dump.txt" -RedirectStandardError "$Work\dump.err.txt"
if ($proc.ExitCode -ne 0) { Write-Host "dump failed; see $Work\dump.txt"; exit 1 }
Get-Item "$Work\data\script-output\data-raw-dump.json" | Select-Object FullName, Length
