:: ==============================================================
:: Wakes up a PC on accessing file-shares or shared printing
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

set "TARGET_GUID=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
set "TARGET_GUID_ALTERNATIVE=e9a42b02-d5df-448d-aa00-03f14749eb61"
:: Usual GUIDs:
:: - High performance: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
:: - High performance in corporate profiles: e9a42b02-d5df-448d-aa00-03f14749eb61
:: - Balanced: 381b4222-f694-41f0-9685-ff5bb260df2e
:: - Power saver: a1841308-3541-4fab-bc81-f71556f20b4a

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if errorLevel 1 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
@echo Activate the maximum power scheme if exist, otherwise uses the current power scheme

:: Interrogate system for existence of the preferred performance profiles
set "SCHEME_GUID="

powercfg /list | findstr /i "%TARGET_GUID%" >nul
if not errorlevel 1 (
    set "SCHEME_GUID=%TARGET_GUID%"
) else (
    powercfg /list | findstr /i "%TARGET_GUID_ALTERNATIVE%" >nul
    if not errorlevel 1 (
        set "SCHEME_GUID=%TARGET_GUID_ALTERNATIVE%"
    )
)

:: Language-independent fallback loop if preferred profiles do not exist
if not defined SCHEME_GUID (
    echo [WARNING] Preferred performance profiles missing. Resolving active system fallback...
    for /f "tokens=2 delims=:" %%A in ('powercfg /getactivescheme') do (
        for /f "tokens=1" %%B in ("%%A") do set "SCHEME_GUID=%%B"
    )
)

:: Hard recovery fallback to standard Balanced profile if processing fails entirely
if not defined SCHEME_GUID (
    echo [WARNING] Active scheme unresolved. Enforcing default system Balanced configuration.
    set "SCHEME_GUID=381b4222-f694-41f0-9685-ff5bb260df2e"
)

powercfg /setactive %SCHEME_GUID%

:: ======================
:: WAKE-ON-PATTERN INTEGRATION FOR SHARED FOLDERS AND PRINTERS
set "SLEEP_SETTINGS_GUID=238c9fa8-0aad-41ed-83f4-97be242c8f20"
set "SYSTEM_UNATTENDED_SLEEP_TIMEOUT=7bc4a2f9-d8fc-4460-b07b-d11178bc5949"
set "NET_CONNECTIVITY_STANDBY_STATE=F15576E8-98b7-410C-96b7-82D335584d36"
set "PCI_EXPR_SETTINGS_GUID=501a4d13-42af-4429-9fd1-a8218c268e20"
set "LINK_STATE_POWER_MANAGEMENT=ee12f906-d277-404b-b6da-d51e5176422f"

@echo Unattended Wake-Sleep Timeout
:: Value=30 (minutes): Timeout for maintains system power after accessing a shared folder or printer wake
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\%SLEEP_SETTINGS_GUID%\%SYSTEM_UNATTENDED_SLEEP_TIMEOUT%" /v "Attributes" /t REG_DWORD /d 2 /f
powercfg /setacvalueindex %SCHEME_GUID% %SLEEP_SETTINGS_GUID% %SYSTEM_UNATTENDED_SLEEP_TIMEOUT% 30
powercfg /setdcvalueindex %SCHEME_GUID% %SLEEP_SETTINGS_GUID% %SYSTEM_UNATTENDED_SLEEP_TIMEOUT% 30

@echo Keep Network Connectivity Active in Standby (AC and DC)
:: Value=1: Managed / Always On - keeps the network interface alive to listen for TCP requests
powercfg /setacvalueindex %SCHEME_GUID% %SLEEP_SETTINGS_GUID% %NET_CONNECTIVITY_STANDBY_STATE% 1
powercfg /setdcvalueindex %SCHEME_GUID% %SLEEP_SETTINGS_GUID% %NET_CONNECTIVITY_STANDBY_STATE% 1

@echo Prevent PCI Express Bus Power-Down During Sleep (AC and DC)
:: Value=0: Off - Prevents the OS from severing hardware power to PCIe network cards during sleep
powercfg /setacvalueindex %SCHEME_GUID% %PCI_EXPR_SETTINGS_GUID% %LINK_STATE_POWER_MANAGEMENT% 0
powercfg /setdcvalueindex %SCHEME_GUID% %PCI_EXPR_SETTINGS_GUID% %LINK_STATE_POWER_MANAGEMENT% 0

@echo Authorize Physical Network Adapters to Trigger OS Wake State
where wmic >nul 2>&1
if errorlevel 1 (
    echo [WARNING] WMIC is unavailable on this system. Skipping hardware wake authorization.
) else (
    @echo Authorize Network Adapters to Trigger OS Wake State
    FOR /F "tokens=2 delims==" %%A IN (
        'wmic path Win32_NetworkAdapter where "PhysicalAdapter=True and PNPDeviceID like 'PCI%%'" get Name /value ^| findstr "="'
    ) DO (
        powercfg /deviceenablewake "%%A"
    )
)

@echo Allow Any Targeted Packet to Wake Up a PC (Configure Standardized NDIS Keywords)
:: Class GUID: {4D36E972-E325-11CE-BFC1-08002BE10318} (Microsoft Net setup class)
:: *WakeOnPattern = 1 (Enables Wake on Pattern Match to capture incoming network requests)
:: Note: WakeOnProtocolPatterns is intentionally omitted/set to 1 to ensure low-level traffic
:: like Ping (ICMP) and Network Name Queries are allowed to wake up the PC.
set "CLASS_PATH=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
for /f "tokens=*" %%A in ('reg query "%CLASS_PATH%" ^| findstr /R /C:"\\[0-9][0-9][0-9][0-9]$"') do (
    reg add "%%A" /v "*WakeOnPattern" /t REG_SZ /d "1" /f >nul
    reg add "%%A" /v "WakeOnProtocolPatterns" /t REG_DWORD /d 1 /f >nul
)

@echo Configure SMB Session Retention
:: Holds the SMB Session ID valid so that save packets match a valid open handle
:: Value=600 minutes
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "autodisconnect" /t REG_DWORD /d 600 /f
net config server /autodisconnect:600

@echo Configure Aggressive SMB KeepAlive for Dead Clients
:: Identifies dropped client connections
:: Value=6000 (interval in milliseconds), repeats 5 times.
:: If a client abruptly reboots computer, the server closes the dead connection and tears down
:: hidden lock files within 60000 milliseconds (1 minute).
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "KeepAliveInterval" /t REG_DWORD /d 6000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "KeepAliveTime" /t REG_DWORD /d 60000 /f

:: ==============================================================
:: Hard Disk / Storage Settings
set "GUID_HARD_DISK_SUBGROUP=0012ee47-9041-4b5d-9b77-535fba8b1442"
set "HARD_DISK_TIMEOUT_GROUP=6733a4d4-c582-4c7b-a8d3-21c16e341372"
set "AHCI_LINK_POWER_MGMT_GROUP=0b2d69d7-a2a1-449c-9680-f91c70521c60"

@echo Unhide Advanced Storage Power Settings
:: Attributes=2 - exposes hidden Link Power Management configurations to powercfg
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\%GUID_HARD_DISK_SUBGROUP%\0b2d69d7-a2a1-449c-9680-f91c70521c60" /v "Attributes" /t REG_DWORD /d 2 /f

@echo AC Storage Performance Optimization
:: 0 = Never spin down hard drives on AC power to prevent file access latency
powercfg /setacvalueindex %SCHEME_GUID% %GUID_HARD_DISK_SUBGROUP% %HARD_DISK_TIMEOUT_GROUP% 0
:: 0 = Active (Disable HIPM/DIPM link power saving). Keeps the SSD bus wide awake for instant file lock validation
powercfg /setacvalueindex %SCHEME_GUID% %GUID_HARD_DISK_SUBGROUP% %AHCI_LINK_POWER_MGMT_GROUP% 0

@echo DC Storage Power Optimization
:: Value=1200 (seconds): Spin down idle hard drives after X time on battery power to conserve cells
powercfg /setdcvalueindex %SCHEME_GUID% %GUID_HARD_DISK_SUBGROUP% %HARD_DISK_TIMEOUT_GROUP% 1200
:: Value=1: HIPM (Host Initiated Power Management). Allows minor power savings on battery while keeping waking latency low
powercfg /setdcvalueindex %SCHEME_GUID% %GUID_HARD_DISK_SUBGROUP% %AHCI_LINK_POWER_MGMT_GROUP% 1


:: ==============================================================
@echo 7. Re-activate the power scheme
:: Applies and commits configuration instantly
powercfg /setactive %SCHEME_GUID%
