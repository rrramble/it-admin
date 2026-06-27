:: ==============================================================
:: Forces Continuous Windows Updates with Immediate Installation and No Forced Reboots
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ===========================
@echo 1. Overriding interface access and disabling user update-pausing features
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdates" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatesBlockPeriod" /t REG_DWORD /d 0 /f
:: Allow users to start updates manually
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d 0 /f

:: ===========================
@echo 2. Configuring immediate automatic download and background installation schedules
:: Automatic scheduling is left to default automatic background checks rather than a specific night hour
:: (AUOptions: 4 = Automatic Download and Install)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 4 /f

:: ===========================
@echo 3. Blocking Microsoft Dual Scan cloud-bypasses to enforce local policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableDualScan" /t REG_DWORD /d 0 /f

:: ===========================
@echo 4. Enforcing automated installations of minor updates and driver packages
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AutoInstallMinorUpdates" /t REG_DWORD /d 1 /f

:: ===========================
@echo 5. Allowing forced automatic restarts while employees logged on into the operating system
@echo (NoAutoReboot: 1 = Enforced / No Forced Restart)
:: DELETED: reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AlwaysAutoRebootAtScheduledTime" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AlwaysAutoRebootAtScheduledTimeMinutes" /f

:: ===========================
@echo 6. Re-enabling and resetting the underlying Windows Update background services
sc config wuauserv start= auto
sc stop wuauserv
sc start wuauserv

:: ===========================
@echo 7. Forcing an immediate background update detection check
wuauclt /detectnow
