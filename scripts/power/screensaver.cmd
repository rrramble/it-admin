:: ==============================================================
:: REMOVES Screensaver-related registry settings
:: because the `Screen Lock` policy is used instead (see the `Security` section)
:: ==============================================================

:: ======================
@echo Pre-requisites
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
@echo 1. Screensaver timeout and lock - main settings
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaverActive" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaveTimeOut" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v "ScreenSaverIsSecure" /f >nul 2>&1

:: ======================
@echo 2: Screensaver and lock inside the Default User profile template
reg load HKLM\TempDefaultProfile "C:\Users\Default\NTUSER.DAT" >nul 2>&1
if errorLevel 1 (
    echo [WARNING] Could not load Default User NTUSER.DAT template.
) else (
    reg delete "HKLM\TempDefaultProfile\Control Panel\Desktop" /v "ScreenSaverActive" /f >nul 2>&1
    reg delete "HKLM\TempDefaultProfile\Control Panel\Desktop" /v "ScreenSaveTimeOut" /f >nul 2>&1
    reg delete "HKLM\TempDefaultProfile\Control Panel\Desktop" /v "ScreenSaverIsSecure" /f >nul 2>&1
    reg unload HKLM\TempDefaultProfile >nul
)

:: ======================
@echo 3. Screensaver and lock inside all existing and active user profiles
for /f "tokens=1,2 delims=\" %%a in ('reg query HKEY_USERS ^| findstr /r /c:"S-1-5-21-[0-9\-]*$"') do (
    reg delete "HKU\%%b\Control Panel\Desktop" /v "ScreenSaverActive" /f >nul 2>&1
    reg delete "HKU\%%b\Control Panel\Desktop" /v "ScreenSaveTimeOut" /f >nul 2>&1
    reg delete "HKU\%%b\Control Panel\Desktop" /v "ScreenSaverIsSecure" /f >nul 2>&1
)
