# deploy-server/windows.ps1
$ErrorActionPreference = "Stop"

$ProjectDir = (Resolve-Path "$PSScriptRoot\").Path
Set-Location $ProjectDir

Write-Host "======================================"
Write-Host " ZABBIX DEPLOYMENT"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI not found. Install Docker Desktop."
}

docker compose version
if ($LASTEXITCODE -ne 0) {
    throw "Docker Compose v2 is required."
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Docker Engine is unavailable. Start Docker Desktop."
}

if (-not (Test-Path ".env")) {
    Write-Host "Generating environment configuration..."

    $Bytes = New-Object byte[] 32
    $RNG = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $RNG.GetBytes($Bytes)
    $RNG.Dispose()

    $Password = [Convert]::ToHexString($Bytes)

    $Content = Get-Content ".env.example" -Raw
    $Content = $Content.Replace(
        "REPLACE_WITH_RANDOM_PASSWORD",
        $Password
    )

    Set-Content -Path ".env" -Value $Content -NoNewline
}

New-Item -ItemType Directory -Force -Path "backups" | Out-Null

Write-Host "Pulling external container images..."
docker compose pull --ignore-buildable
if ($LASTEXITCODE -ne 0) { throw "Image download failed." }

Write-Host "Building custom Zabbix Server image..."
docker compose build zabbix-server
if ($LASTEXITCODE -ne 0) { throw "Zabbix Server image build failed." }

Write-Host "Starting Zabbix..."
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw "Container deployment failed." }

Write-Host "Running initial configuration..."
docker compose run --rm configure
if ($LASTEXITCODE -ne 0) { throw "Zabbix configuration failed." }

Write-Host "======================================"
Write-Host " DEPLOYMENT COMPLETED"
Write-Host "Web UI: http://localhost:8080"
Write-Host "Remote URL: http://SERVER-IP:8080"
Write-Host "Zabbix Server: SERVER-IP:10051"
Write-Host ""
Write-Host "Check status: docker compose ps"
Write-Host "View logs: docker compose logs -f"
