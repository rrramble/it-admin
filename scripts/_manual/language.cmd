REM Language settings

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Check for Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
REM Sets English US as the default Sign-in screen
:: Codes:
:: - English (UK) 00000809
:: - English (US) 00000409
:: Current user
reg add "HKCU\Keyboard Layout\Preload" /v 1 /t REG_SZ /d 00000409 /f
:: Default user
reg add "HKU\.DEFAULT\Keyboard Layout\Preload" /v 1 /t REG_SZ /d 00000409 /f
