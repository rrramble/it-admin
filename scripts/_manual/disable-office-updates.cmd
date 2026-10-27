:: ======================
:: Disables automatic Microsoft Office Updates

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Check Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\common\OfficeUpdate" /v "EnableAutomaticUpdates" /t REG_DWORD /d 0 /f
