:: ==============================================================
:: Screensaver and Screen-lock
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    endlocal
    exit /b 1
)

:: ==============================================================
@echo 1. Enforces screensaver timeout and password resume system-wide
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaverActive" /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "1800" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "1" /f

:: ==============================================================
@echo 2: Injects screensaver and lock policies into the Default User profile template
reg load HKLM\TempDefaultProfile "C:\Users\Default\NTUSER.DAT" >nul 2>&1
if %errorLevel% == 0 (
    reg add "HKLM\TempDefaultProfile\Control Panel\Desktop" /v "ScreenSaverActive" /t REG_SZ /d "1" /f >nul
    reg add "HKLM\TempDefaultProfile\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "1800" /f >nul
    reg add "HKLM\TempDefaultProfile\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "1" /f >nul
    reg unload HKLM\TempDefaultProfile >nul
) else (
    echo [WARNING] Could not load Default User NTUSER.DAT template.
)

:: ==============================================================
@echo 3. Injects screensaver and lock policies into all existing and active user profiles
for /f "tokens=1,2 delims=\" %%a in ('reg query HKEY_USERS ^| findstr /r /c:"S-1-5-21-[0-9\-]*$"') do (
    reg add "HKU\%%b\Control Panel\Desktop" /v "ScreenSaverActive" /t REG_SZ /d "1" /f >nul
    reg add "HKU\%%b\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "1800" /f >nul
    reg add "HKU\%%b\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "1" /f >nul
)
