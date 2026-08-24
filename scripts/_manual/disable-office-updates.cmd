:: ======================
:: Disables automatic Microsoft Office Updates

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

:: ======================
:: Request Administrator privileges

:: Check
fltmc >nul 2>&1
if !errorlevel! neq 0 (
    powershell.exe -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList 'elevated' -Verb RunAs"
    exit /b
)

:: Elevated process
if /i "%~1"=="elevated" (
    fltmc >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] Running failed: Administrator privileges were not obtained.
        exit /b 1
    )
)

:: ======================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\common\OfficeUpdate" /v "EnableAutomaticUpdates" /t REG_DWORD /d 0 /f
