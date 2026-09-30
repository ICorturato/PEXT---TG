param(
    [string]$DeviceId
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$flutter = Join-Path $projectRoot '.flutter-sdk\bin\flutter.bat'

if (-not (Test-Path $flutter)) {
    throw "Flutter was not found at $flutter."
}

if (Test-Path 'C:\platform-tools') {
    $env:PATH = "C:\platform-tools;$env:PATH"
}

# Auto-detect real LAN/Wi-Fi IPv4 address, excluding VPNs (Radmin 26.*, ZeroTier, etc.), virtual adapters, and loopbacks
$ipAddress = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.InterfaceAlias -notmatch 'Loopback|vEthernet|Radmin|Virtual|VMware|Teredo|Tailscale|Hamachi' -and
        $_.IPAddress -notmatch '^(127\.|169\.254\.|26\.)'
    } |
    Select-Object -ExpandProperty IPAddress -First 1

if ([string]::IsNullOrWhiteSpace($ipAddress)) {
    $ipAddress = ipconfig |
        ForEach-Object {
            if ($_ -match 'IPv4.*?:\s*(\d{1,3}(?:\.\d{1,3}){3})') {
                $matches[1]
            }
        } |
        Where-Object { $_ -notmatch '^(127|169\.254|26)\.' } |
        Select-Object -First 1
}

if ([string]::IsNullOrWhiteSpace($ipAddress)) {
    throw 'No active Wi-Fi/LAN IPv4 connection was found. Connect this computer and the phone to the same network.'
}
$apiBaseUrl = "http://${ipAddress}:3000/api/v1"

# Auto-detect connected Android device if none provided
$adbCmd = if (Test-Path 'C:\platform-tools\adb.exe') { 'C:\platform-tools\adb.exe' } else { 'adb' }
if ([string]::IsNullOrWhiteSpace($DeviceId)) {
    try {
        $connectedDevices = & $adbCmd devices 2>$null | Where-Object { $_ -match '\tdevice$' }
        if ($connectedDevices) {
            $DeviceId = ($connectedDevices[0] -split '\t')[0].Trim()
            Write-Host "Auto-detected Android device: $DeviceId" -ForegroundColor Green
        }
    } catch {}
}

# Setup adb reverse port forwarding if an Android device is connected
if ($DeviceId) {
    try {
        & $adbCmd -s $DeviceId reverse tcp:3000 tcp:3000 2>$null | Out-Null
        Write-Host "Configured ADB reverse port forwarding (port 3000) for $DeviceId" -ForegroundColor Green
    } catch {}
}

try {
    $null = Invoke-WebRequest -Uri 'http://127.0.0.1:3000/health' -TimeoutSec 1 -UseBasicParsing
    Write-Host 'PEXT API is already running.' -ForegroundColor Green
} catch {
    Write-Host 'Starting PEXT API in a separate PowerShell window...' -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList @(
        '-NoExit',
        '-ExecutionPolicy', 'Bypass',
        '-File', (Join-Path $PSScriptRoot 'start-backend.ps1')
    )

    $ready = $false
    # Node and Windows Defender can take longer than 15 seconds after a reboot.
    for ($attempt = 0; $attempt -lt 45; $attempt++) {
        Start-Sleep -Seconds 1
        try {
            $null = Invoke-WebRequest -Uri 'http://127.0.0.1:3000/health' -TimeoutSec 1 -UseBasicParsing
            $ready = $true
            break
        } catch {
            # The Node watcher is still starting.
        }
    }
    if (-not $ready) {
        throw 'The PEXT API did not respond within 45 seconds. Check the backend PowerShell window for an npm or Node error.'
    }
}

Write-Host "Using Wi-Fi/LAN API endpoint: $apiBaseUrl" -ForegroundColor Cyan
Write-Host 'Keep the backend window open while testing. Press r for Flutter hot reload; press R for a hot restart.' -ForegroundColor Cyan

$flutterArguments = @('run', "--dart-define=API_BASE_URL=$apiBaseUrl")
if ($DeviceId) {
    $flutterArguments += @('-d', $DeviceId)
}

Set-Location $projectRoot
& $flutter @flutterArguments

