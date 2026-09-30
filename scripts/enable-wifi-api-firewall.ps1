$ErrorActionPreference = 'Stop'

$ruleName = 'PEXT local API (TCP 3000)'
if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3000 -Profile Private | Out-Null
    Write-Host 'Windows Firewall now allows the PEXT API on private Wi-Fi networks.' -ForegroundColor Green
} else {
    Write-Host 'The PEXT API firewall rule already exists.' -ForegroundColor Green
}
