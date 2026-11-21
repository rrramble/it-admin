# Detailed instruction to install Zabbix in Windows 10/11

## Script 1: Sets up WSL

1.1. Define a dedicated Windows login to own WSL. Add it to the local Administrators group. Log in using it.

1.2. Run the following commands **as Administrator**:

Whenever Windows asks you to restart, do so and continue with the installation.
If updating fails, try native Windows Update feature.
When Ubuntu asks to create a username and a password do so.

```cmd
wsl --install --no-distribution
wsl --update
wsl --set-default-version 2
wsl --install -d Ubuntu
```

## Script 2: Checks WSL

Verify that Ubuntu is using version 2 of WSL.
Ensure that Ubuntu's `/etc/wsl.conf` contains `systemd=true` inside `[boot]` section.

```cmd
wsl --list --verbose

:: Example response:
:: NAME   STATE   VERSION
:: Ubuntu Running 2

wsl.exe -d Ubuntu --exec cat /etc/wsl.conf

:: Example result:
:: ...
:: [boot]
:: systemd=true
:: ...
```

Note:
`mirrored` networking is available on Windows 11 version 22H2 or later, with a sufficiently recent WSL version.


## Script 3: Sets up Windows scheduler to run WSL

Create a scheduler task, enter password of the Windows account when asked:

```PowerShell
$account = "$env:USERDOMAIN\$env:USERNAME"

schtasks.exe /Create `
    /TN "Zabbix WSL" `
    /SC ONSTART `
    /TR "wsl.exe -d Ubuntu --exec /usr/bin/sleep infinity" `
    /RU $account `
    /RP *

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create the Zabbix WSL scheduled task."
}

$settings = (Get-ScheduledTask -TaskName "Zabbix WSL").Settings
$settings.ExecutionTimeLimit = "PT0S"
Set-ScheduledTask -TaskName "Zabbix WSL" -Settings $settings
(Get-ScheduledTask -TaskName "Zabbix WSL").Settings.ExecutionTimeLimit
# The last command should return 'PT0S' value!
```


## Notes about WSL network settings in Windows registry

- System Subnet & Mask: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss
-- NatNetwork (REG_SZ): Network address with CIDR prefix (e.g., 172.22.16.0/20).
-- NatGatewayIpAddress (REG_SZ): Windows host adapter IP (vEthernet WSL), the gateway inside that subnet (e.g., 172.22.16.1).
- User VM IP Cache: HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss
-- NatIpAddress (REG_SZ): Cached IP assigned to the WSL2 Linux VM (eth0) inside that subnet (e.g., 172.22.16.2)
