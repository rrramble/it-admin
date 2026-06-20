:: ==============================================================
:: Forces Continuous and Un-pausable Windows Updates
:: ==============================================================

set INSTALL_HOUR=13
@REM Options: 0 to 23. Standardizes the daily installation hour (e.g., 3 = 3:00 AM).

:: ===========================
@echo Verifying Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ===========================
@echo 1. Overriding interface access and disabling user update-pausing features
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdates" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatesBlockPeriod" /t REG_DWORD /d 0 /f

:: ===========================
@echo 2. Configuring automatic download and daily installation schedules (AUOptions: 4 = Automatic Download and Install)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 4 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallDay" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallTime" /t REG_DWORD /d %INSTALL_HOUR% /f

:: ===========================
@echo 3. Blocking Microsoft Dual Scan cloud-bypasses to enforce local policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableDualScan" /t REG_DWORD /d 1 /f

:: ===========================
@echo 4. Enforcing automated installations of minor updates and driver packages
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AutoInstallMinorUpdates" /t REG_DWORD /d 1 /f

:: ===========================
@echo 5. Configuring aggressive reboots outside active business hours (AlwaysAutoReboot: 1 = Enforced)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AlwaysAutoRebootAtScheduledTime" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AlwaysAutoRebootAtScheduledTimeMinutes" /t REG_DWORD /d 15 /f

:: ===========================
@echo 6. Re-enabling and resetting the underlying Windows Update background services
sc config wuauserv start= auto
sc stop wuauserv >nul 2>&1
sc start wuauserv >nul 2>&1

:: ===========================
@echo 7. Forcing an immediate background update detection check
wuauclt /detectnow
