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
if %INACTIVITY_TIMER_SEC% LSS 60 (
    echo [ERROR] Timer too low (minimum practical value is 60 seconds)
    exit /b 1
)

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d %INACTIVITY_TIMER_SEC% /f
