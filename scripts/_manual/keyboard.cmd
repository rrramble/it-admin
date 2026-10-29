REM Keyboard settings

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
REM Turns on Num-lock on startup/sign-in window
:: Codes:
:: 0 = NumLock off
:: 2 = NumLock on
:: 2147483648 = 0x80000000 = High bit set
:: 2147483650 = 0x80000002 = High bit + NumLock on
:: ======================

:: Default user
reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2147483650 /f
