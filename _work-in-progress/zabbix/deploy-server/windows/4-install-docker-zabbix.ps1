# File: deploy-server/4.ps1
# Sends files to Linux, installs them

#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

$DISTRO_NAME = "Ubuntu"
$WindowsRootPath = $PSScriptRoot
$LinuxRootPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))


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


function ConvertTo-LinuxPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$WindowsPath
    )

    return $WindowsPath -replace '\\', '/'
}


function Test-DeploymentFiles() {
    $requiredFiles = @(
        "windows/setup-docker.sh",
        "run.sh",
        "Docker-compose.yaml",
        "Dockerfile.server",
        ".env",
        "configure/configure.py"
    )

    foreach ($file in $requiredFiles) {
        $path = Join-Path $LinuxRootPath $file

        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required file not found: $path"
        }
    }

    echo 'Deployment files were checked successfully.'
}

############################
# Start of the script body #
############################

$linuxLogin = Get-EnvValue -Key "LINUX_LOGIN" -EnvFile (Join-Path $WindowsRootPath '.env')
Test-DeploymentFiles

# Convert the Windows source directory to its WSL path
$LinuxFormatLinuxPath = ConvertTo-LinuxPath -WindowsPath $LinuxRootPath
$SourceDir = & wsl.exe -d $DISTRO_NAME -- wslpath -a $LinuxFormatLinuxPath
$ExitCode = $LASTEXITCODE

if ($ExitCode -ne 0) {
    throw "Could not convert deployment directory to WSL path (exit code $ExitCode): $SourceDir"
}

$SourceDir = ($SourceDir | Out-String).Trim()

if ([string]::IsNullOrWhiteSpace($SourceDir)) {
    throw "WSL returned an empty source directory path."
}

# Run the existing Linux installation script as root.
# It installs Docker, copies the deployment files into the Linux user's
# home directory, and starts the Zabbix deployment.
& wsl.exe -d $DISTRO_NAME -u root -- bash `
    "$SourceDir/windows/setup-docker.sh" `
    $linuxLogin `
    $SourceDir

if ($LASTEXITCODE -ne 0) {
    throw "Docker and Zabbix installation failed (exit code $LASTEXITCODE)."
}

Write-Host "Docker and Zabbix installation completed."
