# File: deploy-server/4.ps1
# Sends files to Linux, installs them

#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

$DISTRO_NAME = "Ubuntu"
$WindowsRootPath = $PSScriptRoot
$LinuxRootPath = Split-Path -Parent $PSScriptRoot


function Get-EnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [string]$EnvFile
    )

    if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
        throw "Environment file not found: $EnvFile"
    }

    $line = Get-Content -LiteralPath $EnvFile |
        Where-Object { $_ -match "^\s*$([regex]::Escape($Key))\s*=" } |
        Select-Object -Last 1

    if (-not $line) {
        throw "Key '$Key' not found in $EnvFile"
    }

    $value = ($line -replace "^\s*$([regex]::Escape($Key))\s*=\s*", '').Trim()

    # Remove optional surrounding quotes
    if ($value.Length -ge 2 -and
        (($value.StartsWith('"') -and $value.EndsWith('"')) -or
         ($value.StartsWith("'") -and $value.EndsWith("'")))) {
        $value = $value.Substring(1, $value.Length - 2)
    }

    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Key '$Key' has an empty value in $EnvFile"
    }

    return $value
}


function ConvertTo-WSLPath {
    param (
        [Parameter(Mandatory)]
        [string]$WindowsPath
    )

    $AbsolutePath = [System.IO.Path]::GetFullPath($WindowsPath)
    $AbsolutePath = $AbsolutePath -replace '\\', '/'
    $Output = & wsl.exe -d $DISTRO_NAME -- wslpath -u "$AbsolutePath" 2>&1
    $ErrorCode = $LASTEXITCODE

    if ($ErrorCode -ne 0) {
        $ErrorMessage = $Output -join "`n"
        throw "Failed to convert path to WSL format: $AbsolutePath. Exit code: $ErrorCode. Error: $ErrorMessage"
    }

    return ($Output -join "").Trim()
}


function Test-DeploymentFiles() {
    $requiredFiles = @(
        "windows/setup-docker.sh",
        "run.sh",
        "docker-compose.yaml",
        "dockerfile.server",
        ".env",
        "configure/configure.py"
    )

    foreach ($file in $requiredFiles) {
        $path = Join-Path $LinuxRootPath $file

        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required file not found: $path"
        }
    }

    Write-Host 'Deployment files were checked successfully.'
}

############################
# Start of the script body #
############################

Test-DeploymentFiles
$LinuxLogin = Get-EnvValue -Key "LINUX_LOGIN" -EnvFile (Join-Path $WindowsRootPath ".env")

# Run the existing Linux installation script.
$WindowsWSLPath = ConvertTo-WSLPath (Join-Path $WindowsRootPath "setup-docker.sh")
$LinuxWSLPath = ConvertTo-WSLPath $LinuxRootPath

& wsl.exe -d $DISTRO_NAME -u root -- bash -x `
    "$WindowsWSLPath" `
    "$LinuxLogin" `
    "$LinuxWSLPath"

if ($LASTEXITCODE -ne 0) {
    throw "Docker and Zabbix installation failed (exit code $LASTEXITCODE)."
}

Write-Host "Docker and Zabbix installation completed."
