:: ==============================================================
@echo Screen Lock
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if errorLevel 1 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
:: Variables
set INACTIVITY_TIMER_SEC=1200

:: ======================
:: Run
set /a _=%INACTIVITY_TIMER_SEC% >nul 2>&1 || (
    echo [ERROR] Invalid timer value. Should be numeric.
    exit /b 1
)

if %INACTIVITY_TIMER_SEC% LSS 60 (
    echo [ERROR] Timer too low (minimum practical value is 60 seconds)
    exit /b 1
)

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "InactivityTimeoutSecs" /t REG_DWORD /d %INACTIVITY_TIMER_SEC% /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaveTimeOut" /f /t REG_DWORD /d %INACTIVITY_TIMER_SEC% >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaveActive" /f /t REG_DWORD /d 1 >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaverIsSecure" /f /t REG_DWORD /d 1 >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "%SystemRoot%\System32\scrnsave.scr" /f >nul 2>&1
