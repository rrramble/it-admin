# Disk shares

> Note: After applying settings, restarting of the Server service is needed:
```cmd
sc stop lanmanserver

:wait
sc query lanmanserver | find "STOPPED" >nul
if errorlevel 1 (
    timeout /t 1 >nul
    goto wait
)

sc start lanmanserver
```

PowerShell `Restart-Service -Name LanmanServer [-Force]`


## Display shares

- CMD `net share`
- PowerShell `Get-SmbShare`


## Check the Server Service is Running
`sc query lanmanserver`


### Start it
```cmd
sc query lanmanserver
net start lanmanserver
```


## Enable File and Printer Sharing Firewall Rules
- CMD `netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes`
- PowerShell `Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"`



## Administrative Shares (C$, ADMIN$) in Windows 7, 10, 11

Registry
```[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters]
"AutoShareWks"=dword:00000001
```

CMD `reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareWks /t REG_DWORD /d 1 /f`

> IPC$ is created automatically by the Server service (LanmanServer) and cannot normally be disabled independently.


## Allow SMB Access Through Local Security Policy

```reg
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa]
"forceguest"=dword:00000000
```
> 0 — Classic authentication
> 1 — Guest only


## Remote UAC Restrictions

```reg
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"LocalAccountTokenFilterPolicy"=dword:00000001
```

CMD `reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f`

> 0 UAC remote filtering enabled (default)
> 1 Full administrator token remotely
