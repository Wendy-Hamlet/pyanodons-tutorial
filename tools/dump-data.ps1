# Dumps data.raw for the player's exact mod set (mod-list.json + mod-settings.dat) into
# $Work\data\script-output\data-raw-dump.json, and the prototypes' localised names into
# *-locale.json beside it (zh-CN) and in $Work\data-en\script-output (en). Mods are hard-linked,
# not copied; the player's own config and mods folder are only read.
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
New-Item -ItemType Directory -Force "$Work\config", "$Work\config-en", "$Work\data", "$Work\data-en", "$Work\mods" | Out-Null
Get-ChildItem $mods -Filter *.zip | ForEach-Object {
    New-Item -ItemType HardLink -Path (Join-Path "$Work\mods" $_.Name) -Target $_.FullName | Out-Null
}
Copy-Item (Join-Path $mods 'mod-list.json'), (Join-Path $mods 'mod-settings.dat') "$Work\mods\"
$base = $Work -replace '\\', '/'
Set-Content "$Work\config\config.ini" "[path]`nread-data=__PATH__executable__/../../data`nwrite-data=$base/data`n[general]`nlocale=zh-CN" -Encoding ascii
Set-Content "$Work\config-en\config.ini" "[path]`nread-data=__PATH__executable__/../../data`nwrite-data=$base/data-en`n[general]`nlocale=en" -Encoding ascii

function Run([string]$config, [string]$what, [string]$log) {
    $proc = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList '--config', $config, '--mod-directory', "$Work\mods", $what `
        -RedirectStandardOutput "$Work\$log.txt" -RedirectStandardError "$Work\$log.err.txt"
    if ($proc.ExitCode -ne 0) { Write-Host "$what failed; see $Work\$log.txt"; exit 1 }
}
Run "$Work\config\config.ini" '--dump-data' 'dump'
Run "$Work\config\config.ini" '--dump-prototype-locale' 'locale'
Run "$Work\config-en\config.ini" '--dump-prototype-locale' 'locale-en'
Get-Item "$Work\data\script-output\data-raw-dump.json", "$Work\data\script-output\item-locale.json",
    "$Work\data-en\script-output\item-locale.json" | Select-Object FullName, Length, LastWriteTime
