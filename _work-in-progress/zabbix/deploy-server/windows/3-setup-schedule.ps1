# File: deploy-server/windows/3.ps1
# Sets up the Windows task schedule to run WSL on Windows startup

$account = "$env:USERDOMAIN\$env:USERNAME"
Write-Host "Enter Windows user credentials:"

schtasks.exe /Create `
    /TN "Zabbix WSL" `
    /SC ONSTART `
    /TR "wsl.exe -d Ubuntu --exec /usr/bin/sleep infinity" `
    /RU $account `
    /RP *

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create the Zabbix WSL scheduled task. Error code=$LASTEXITCODE"
}

$settings = (Get-ScheduledTask -TaskName "Zabbix WSL").Settings
$settings.ExecutionTimeLimit = "PT0S"
Set-ScheduledTask -TaskName "Zabbix WSL" -Settings $settings
(Get-ScheduledTask -TaskName "Zabbix WSL").Settings.ExecutionTimeLimit
Write-Host "The prevous command should have returned 'PT0S' value"
