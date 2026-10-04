# Runs the agent's Factorio server in C:\tmp\cf-agent (built by setup.ps1).
#
#   server.ps1 new [-Seed N]  create saves\agent.zip with the player's own map generation settings
#                             (tools\agent\mapgen.json: Py recommended with cliffs off; no enemy
#                             bases) and a new seed; the agent mod applies the preset's advanced
#                             settings (no pollution...) in on_init, since --preset would override
#                             --map-gen-settings
#   server.ps1 start          start the headless server (RCON on 127.0.0.1:27115), detached
#   server.ps1 stop           save and quit
#   server.ps1 status         is it running, which save, last log lines
#
# The server never pauses for lack of players; `node a.js pause` pauses the game itself.
param(
    [Parameter(Mandatory = $true)][ValidateSet('new', 'start', 'stop', 'status')][string]$Action,
    [string]$Seed,
    [string]$Work = 'C:\tmp\cf-agent',
    [string]$Factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\factorio.exe'
)
$ErrorActionPreference = 'Stop'
$save = "$Work\saves\agent.zip"
$common = @('--config', "$Work\config\config.ini", '--mod-directory', "$Work\mods")
$a = Join-Path $PSScriptRoot 'a.js'

function Get-Server {
    Get-CimInstance Win32_Process -Filter "Name = 'factorio.exe'" |
        Where-Object { $_.CommandLine -like '*--start-server*' -and $_.CommandLine -like "*$Work*" }
}

switch ($Action) {
    'new' {
        if (Test-Path $save) { throw "$save exists; move it away first" }
        if (-not $Seed) { $Seed = Get-Random -Minimum 1 -Maximum 2147483647 }
        $log = "$Work\create.log"
        $p = Start-Process -FilePath $Factorio -NoNewWindow -Wait -PassThru -RedirectStandardOutput $log -RedirectStandardError "$Work\create.err.log" `
            -ArgumentList ($common + @('--create', $save, '--map-gen-settings', (Join-Path $PSScriptRoot 'mapgen.json'), '--map-gen-seed', $Seed))
        Get-Content $log | Where-Object { $_ -match 'Error|error|Saving' } | Select-Object -Last 5
        if ($p.ExitCode -ne 0 -or -not (Test-Path $save)) { throw "create failed ($($p.ExitCode)), see $log" }
        Write-Host "created $save with seed $Seed"
        "seed=$Seed created=$(Get-Date -Format s)" | Set-Content "$Work\saves\agent-seed.txt"
    }
    'start' {
        if (Get-Server) { Write-Host 'already running'; break }
        $pw = "$Work\rcon-password.txt"
        if (-not (Test-Path $pw)) { [guid]::NewGuid().ToString('N') | Set-Content $pw -Encoding ascii }
        $password = (Get-Content $pw -Raw).Trim()
        $log = "$Work\server.log"
        if (Test-Path $log) { Move-Item $log "$Work\server.previous.log" -Force }
        Start-Process -FilePath $Factorio -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError "$Work\server.err.log" `
            -ArgumentList ($common + @('--start-server', $save, '--server-settings', "$Work\server-settings.json",
                '--port', '34297', '--rcon-bind', '127.0.0.1:27115', '--rcon-password', $password)) | Out-Null
        $deadline = (Get-Date).AddMinutes(4)
        while ((Get-Date) -lt $deadline) {
            Start-Sleep -Seconds 3
            if (Select-String -Path $log -Pattern 'Starting RCON interface' -Quiet) { break }
            if (-not (Get-Server)) { Get-Content $log -Tail 20; throw 'server exited' }
        }
        Start-Sleep -Seconds 2
        & node $a status events=false
    }
    'stop' {
        if (-not (Get-Server)) { Write-Host 'not running'; break }
        & node $a raw /server-save | Out-Null
        Start-Sleep -Seconds 8
        & node $a raw /quit | Out-Null
        $deadline = (Get-Date).AddSeconds(60)
        while ((Get-Server) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 2 }
        if (Get-Server) { throw 'server did not quit' }
        Write-Host 'saved and stopped'
    }
    'status' {
        $s = Get-Server
        if ($s) { Write-Host "running, pid $($s.ProcessId)" } else { Write-Host 'not running' }
        if (Test-Path "$Work\server.log") { Get-Content "$Work\server.log" -Tail 5 }
    }
}
