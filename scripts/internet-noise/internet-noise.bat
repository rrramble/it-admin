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
@echo 3.1. Stops services
sc config DiagTrack start= disabled
sc stop DiagTrack >nul 2>&1
sc config dmwappushservice start= disabled
sc stop dmwappushservice >nul 2>&1

:: ======================
@echo 3.2. Sets policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "TurnOffHandwritingPersonalization" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "Disabled" /t REG_DWORD /d 1 /f

:: ======================
@echo 4. Injects privacy, handwriting, and advertising blocks
@echo 4.1. The Default User profile template
reg load HKLM\TempDefaultProfile "C:\Users\Default\NTUSER.DAT" >nul 2>&1
if %errorLevel% == 0 (
    set "DEF_PATH=HKLM\TempDefaultProfile\Software\Microsoft"
    reg add "HKLM\TempDefaultProfile\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
    reg add "!DEF_PATH!\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f >nul
    reg add "!DEF_PATH!\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul
    reg add "!DEF_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f >nul
    reg add "!DEF_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul
    reg add "!DEF_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul
    reg add "!DEF_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
    reg unload HKLM\TempDefaultProfile >nul
) else (
    echo [WARNING] Could not load Default User NTUSER.DAT template.
)

@echo 4.2. All existing user profiles
:: WARNING: "delims=	" contains a literal-real TAB character to handle usernames with spaces safely
for /f "tokens=1,2 delims=	" %%a in ('reg query HKEY_USERS') do (
    set "USER_REG_KEY=%%a"
    @REM Extracts just the SID string by replacing the HKEY_USERS root prefix
    set "USER_SID=!USER_REG_KEY:HKEY_USERS\=!"
    @REM Filter to apply only to actual logged-in security identifiers (S-1-5-21-...)
    @echo !USER_SID! | findstr /r /c:"S-1-5-21-[0-9\-]*$" >nul
    if !errorLevel! == 0 (
        set "ACTIVE_PATH=HKU\!USER_SID!\Software\Microsoft"
        reg add "HKU\!USER_SID!\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
        reg add "!ACTIVE_PATH!\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f >nul
        reg add "!ACTIVE_PATH!\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul
        reg add "!ACTIVE_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f >nul
        reg add "!ACTIVE_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul
        reg add "!ACTIVE_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul
        reg add "!ACTIVE_PATH!\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
    )
)

:: ======================
@echo 5. Safely refreshes the Windows environment parameters to apply profile changes
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
