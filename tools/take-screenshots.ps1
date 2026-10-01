# Takes the tutorial's in-game screenshots: builds the design-lab map headlessly, then runs it with
# graphics (--benchmark-graphics), where tools/design-lab calls game.take_screenshot after the
# designs have run for a minute. The game exits by itself; the JPGs are copied to images/.
#
# The Steam build of the graphical client asks Steam to relaunch it; Steam then shows a dialog
# about launching with custom arguments. Confirm it. Headless runs never need Steam.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\take-screenshots.ps1
param(
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe',
    [string]$Work = 'C:\tmp\cf-dump',
    [string]$Shot = 'C:\tmp\cf-shot',
    [int]$WaitMinutes = 15
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$Work\config\config.ini")) { throw "Run tools\dump-data.ps1 first to create $Work" }
$images = Join-Path (Split-Path -Parent $PSScriptRoot) 'images'
$lab = "$Work\mods\cf-design-lab"
$save = "$Work\lab.zip"

New-Item -ItemType Directory -Force "$Shot\config", "$Shot\data", $images | Out-Null
Set-Content "$Shot\config\config.ini" "[path]`nread-data=__PATH__executable__/../../data`nwrite-data=C:/tmp/cf-shot/data`n[general]`nlocale=en`n[graphics]`nfull-screen=false" -Encoding ascii
Remove-Item -Recurse -Force "$Shot\data\script-output" -ErrorAction SilentlyContinue

try {
    if (Test-Path $lab) { Remove-Item -Recurse -Force $lab }
    Copy-Item -Recurse (Join-Path $PSScriptRoot 'design-lab') $lab

    Write-Host 'Building the lab map (headless)...'
    $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru `
        -ArgumentList '--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods", '--create', $save `
        -RedirectStandardOutput "$Work\lab-create.txt" -RedirectStandardError "$Work\lab-create.err.txt"
    if ($p.ExitCode -ne 0) { throw "map creation failed; see $Work\lab-create.txt" }

    Write-Host 'Starting the game with graphics. If Steam asks about launch arguments, confirm it.'
    Start-Process -FilePath $Factorio -ArgumentList '--config', "$Shot\config\config.ini", '--mod-directory', "$Work\mods",
        '--benchmark-graphics', $save, '--benchmark-ticks', '3700', '--disable-audio', '--window-size', '1280x720' | Out-Null

    # Steam relaunches the game as a separate process; follow it by its command line.
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $seen = $false
    while ($clock.Elapsed.TotalMinutes -lt $WaitMinutes) {
        $running = @(Get-CimInstance Win32_Process -Filter "Name='factorio.exe'" | Where-Object { $_.CommandLine -like '*cf-shot*' })
        if ($running.Count -gt 0) { $seen = $true } elseif ($seen) { break }
        Start-Sleep -Seconds 3
    }
    if (-not $seen) { throw "the game never started (Steam dialog not confirmed?)" }

    $shots = Get-ChildItem "$Shot\data\script-output\cellforge\shots" -Filter *.jpg -ErrorAction SilentlyContinue
    if (-not $shots) { throw "no screenshots written; see $Shot\data\factorio-current.log" }
    $shots | Copy-Item -Destination $images -Force
    $shots | Select-Object Name, Length
    Write-Host "Copied $($shots.Count) screenshots to $images"
}
finally {
    if (Test-Path $lab) { Remove-Item -Recurse -Force $lab }
}
