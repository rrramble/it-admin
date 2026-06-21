:: ==============================================================
@echo Stops Internet Noise (Telemetry, Advertising, etc.)
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal EnabledDelayedExpansion
chcp 65001 >nul

@echo Verifying Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
@echo 1. Disables Windows Telemetry and Data Collection (0 = Security Only / Disabled)
set "TELEMETRY_PATH=HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
reg add "!TELEMETRY_PATH!" /v "AllowTelemetry" /t REG_DWORD /d 0 /f

:: ======================
@echo 2. Disables Windows Consumer Features and corporate suggestions (1 = Enforced / Blocked)
:: This does not cover the OneDrive
set "CLOUD_PATH=HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
reg add "!CLOUD_PATH!" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f

:: ======================
@echo 3. Disables system tracking background services (DiagTrack and dmwappushservice)
sc config DiagTrack start= disabled
sc stop DiagTrack >nul 2>&1
sc config dmwappushservice start= disabled
sc stop dmwappushservice >nul 2>&1

:: ======================
@echo 4. Injects Advertising ID and Content Delivery blocks (0 = Disabled) into the Default User profile template
reg load HKLM\TempDefaultProfile "C:\Users\Default\NTUSER.DAT" >nul 2>&1
if %errorLevel% == 0 (
    reg add "HKLM\TempDefaultProfile\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul
    reg add "HKLM\TempDefaultProfile\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f >nul
    reg unload HKLM\TempDefaultProfile >nul
) else (
    echo [WARNING] Could not load Default User NTUSER.DAT template.
)

:: ======================
@echo 5. Injects Advertising ID and Content Delivery blocks (0 = Disabled) into all existing user profiles
:: WARNING: "delims=	" contains a literal-real TAB character to handle usernames with spaces safely
:: ======================
for /f "tokens=1,2 delims=	" %%a in ('reg query HKEY_USERS') do (
    set "USER_REG_KEY=%%a"
    @REM Extracts just the SID string by replacing the HKEY_USERS root prefix
    set "USER_SID=!USER_REG_KEY:HKEY_USERS\=!"
    @REM Filter to apply only to actual logged-in security identifiers (S-1-5-21-...)
    @echo !USER_SID! | findstr /r /c:"S-1-5-21-[0-9\-]*$" >nul
    if !errorLevel! == 0 (
        reg add "HKU\!USER_SID!\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul
        reg add "HKU\!USER_SID!\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f >nul
    )
)

:: ======================
@echo 6. Safely refreshes the Windows environment parameters to apply profile changes
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
