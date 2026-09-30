$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $projectRoot 'backend')

Write-Host 'Starting PEXT API on port 3000...'
npm run dev
