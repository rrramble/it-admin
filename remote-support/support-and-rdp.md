# Remote support and RDP

## Configure Network Level Authentication (NLA)
> Allow connections only from computers running Remote Desktop with Network Level Authentication
> 1 — Require NLA, 0 - NLA not required

Registry
```
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]
"UserAuthentication"=dword:00000001
```
CLI `reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f`


## Enable/Disable Remote Assistance
> 1 — Enable, 0 - Disable

Registry
```
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000001
```
CLI `reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /f /d 1`


## Enable/Disable Remote Desktop
 > 1 — Enable, 0 - Disable

 Registry
 ```
 [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server]
"fDenyTSConnections"=dword:00000001
 ```
 CLI `reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /f /d 1`


 ## Configure RDP Security Layer
 > 0 — RDP security, 1 — Negotiate, 2 — TLS/SSL

 Registry
 ```
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]
"SecurityLayer"=dword:00000002
```


## Open the Windows Firewall for RDP

```cmd
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
```

```powershell
powershell Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

## Allow a remote user to connect via Remote Desktop
```cmd
net localgroup "Remote Desktop Users" username /add
```

## Remote Assistance Invitation Settings

### Maximum invitation lifetime
> Specify number of days, A = 10

```reg
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services]
"MaxTicketExpiry"=dword:0000000a
```

### Allow Solicited Remote Assistance
```
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services]
"fAllowToGetHelp"=dword:00000001
```


### Allow Solicited Remote Assistance
```reg
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services]
"fAllowUnsolicited"=dword:00000001
```

These correspondes with the Group policy settings:
Computer Configuration
 └ Administrative Templates
    └ System
       └ Remote Assistance