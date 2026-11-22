# Detailed instruction to install Zabbix in Windows 10/11

## Script 1: Set up WSL

- Define a dedicated Windows login to own WSL.
- Add it to the local Administrators group.
- Log in using it.
- Run script `1...cmd` to install WSL.


## Script 2: Check WSL

Script `2...cmd` shows WSL settings.

- Verify that Ubuntu is using version 2 of WSL.
- Verify that there is `systemd=true` inside `[boot]` section of the `/etc/wsl.conf` file.


## Script 3: Set up scheduler to run WSL on Windows startup

Allow PowerShell to run scripts for the current window `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

Script `3...ps1` creates a scheduler task.

During running enter password of the Windows account when asked.


## Script 4: Install Docker and Zabbix on Ubuntu

- `4...ps1`


## Additional notes about WSL network settings in Windows registry

- System Subnet & Mask: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss
-- NatNetwork (REG_SZ): Network address with CIDR prefix (e.g., 172.22.16.0/20).
-- NatGatewayIpAddress (REG_SZ): Windows host adapter IP (vEthernet WSL), the gateway inside that subnet (e.g., 172.22.16.1).
- User VM IP Cache: HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss
-- NatIpAddress (REG_SZ): Cached IP assigned to the WSL2 Linux VM (eth0) inside that subnet (e.g., 172.22.16.2)
