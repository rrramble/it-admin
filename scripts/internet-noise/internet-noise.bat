:: ============================================================
:: Windows Privacy/Telemetry Hardening (only for Workgroups, not for AD!)
:: ============================================================

:: ======================
@echo [INFO] Checks and sets pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001 >nul 2>&1

@echo Verifying Administrator privileges
net session >nul 2>&1
if !errorLevel! neq 0 (
    echo [FATAL] Administrative privileges required. Execution halted.
    endlocal
    exit /b 1
)

:: ======================
@echo [INFO] Applying Machine Policy layers...

set "MAIN_KEY=HKLM\SOFTWARE\Policies\Microsoft\Windows"
set "KEY_MS=HKLM\SOFTWARE\Policies\Microsoft"

"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\System" /v PublishUserActivities /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\System" /v UploadUserActivities /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >nul

"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\Windows Error Reporting" /v DoNotSendAdditionalData /t REG_DWORD /d 1 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\DeliveryOptimization" /v SendLogs /t REG_DWORD /d 0 /f >nul

"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\InputPersonalization" /v AllowInputPersonalization /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%MAIN_KEY%\DeviceHealthAttribution" /v EnableDeviceHealthAttribution /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_MS%\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenSqm /t REG_DWORD /d 1 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_MS%\WindowsNT\Remote Assistance" /v NoRemoteAssistance /t REG_DWORD /d 1 /f >nul

:: ======================
@echo [INFO] Service Control Layer
call :ManageService "DiagTrack"
call :ManageService "dmwappushservice"
call :ManageService "WerSvc"

:: ======================
@echo [INFO] Current User Layer (HKCU)
set "KEY_CU_PRIV=HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy"
set "KEY_CU_ADV=HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
set "KEY_CU_CDM=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
set "KEY_CU_INPUT=HKCU\Software\Microsoft\InputPersonalization"
set "KEY_CU_INPUT_TR=HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore"

"%SystemRoot%\System32\reg.exe" add "%KEY_CU_PRIV%" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_CU_ADV%" /v Enabled /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_CU_CDM%" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_CU_CDM%" /v SoftLandingEnabled /t REG_DWORD /d 0 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_CU_INPUT%" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_CU_INPUT%" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f >nul
"%SystemRoot%\System32\reg.exe" add "%KEY_CU_INPUT_TR%" /v HarvestedWords /t REG_DWORD /d 0 /f >nul

:: ======================
@echo [INFO] Default Profile (NTUSER.DAT) enforcement
set "DEFAULT_HIVE=%SystemDrive%\Users\Default\NTUSER.DAT"

if exist "%DEFAULT_HIVE%" (
    :: Force an unload first to clear any stale or orphaned mounts from previous failures
    "%SystemRoot%\System32\reg.exe" unload "HKLM\TEMP_DEFAULT" >nul 2>&1

    :: Explicitly flush errorlevel back to 0 to wipe out the proactive unload failure code
    cmd /c "exit /b 0"

    "%SystemRoot%\System32\reg.exe" load "HKLM\TEMP_DEFAULT" "%DEFAULT_HIVE%" >nul 2>&1
    if !errorLevel! equ 0 (
        :: Wrapped inside a conditional block ensuring execution occurs only when loaded successfully
        set   "KEY_DEF_PRIV=HKLM\TEMP_DEFAULT\Software\Microsoft\Windows\CurrentVersion\Privacy"
        set    "KEY_DEF_ADV=HKLM\TEMP_DEFAULT\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        set    "KEY_DEF_CDM=HKLM\TEMP_DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        set "KEY_DEF_POLICY=HKLM\TEMP_DEFAULT\Software\Policies\Microsoft\Windows"

        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_PRIV!" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_ADV!" /v Enabled /t REG_DWORD /d 0 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_CDM!" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_CDM!" /v SoftLandingEnabled /t REG_DWORD /d 0 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_POLICY!\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_POLICY!\Windows Error Reporting" /v DoNotSendAdditionalData /t REG_DWORD /d 1 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_POLICY!\Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul

        set "KEY_DEF_INPUT=HKLM\TEMP_DEFAULT\Software\Microsoft\InputPersonalization"
        set "KEY_DEF_INPUT_TR=HKLM\TEMP_DEFAULT\Software\Microsoft\InputPersonalization\TrainedDataStore"

        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_INPUT!" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_INPUT!" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f >nul
        "%SystemRoot%\System32\reg.exe" add "!KEY_DEF_INPUT_TR!" /v HarvestedWords /t REG_DWORD /d 0 /f >nul

        :: Mandatory clean unload
        "%SystemRoot%\System32\reg.exe" unload "HKLM\TEMP_DEFAULT" >nul
        echo [OK] Default profile updated successfully.
    ) else (
        echo [WARN] Failed to load Default Profile hive. Code: !errorLevel!
    )
) else (
    echo [WARN] Default User Profile path not detected. Skipping baseline injection.
)

:: ======================
@echo [INFO] Clean Exit Mechanics
endlocal
exit /b 0
goto :eof

:: ======================
:: FUNCTIONS

:ManageService
set "SVC_NAME=%~1"
"%SystemRoot%\System32\sc.exe" query "%SVC_NAME%" >nul 2>&1
if !errorLevel! neq 0 (
    echo [SKIP] Service "%SVC_NAME%" is not present on this machine base.
    goto :eof
)
"%SystemRoot%\System32\sc.exe" stop "%SVC_NAME%" >nul 2>&1
"%SystemRoot%\System32\sc.exe" config "%SVC_NAME%" start= disabled >nul 2>&1
echo [OK] Service disabled: %SVC_NAME%
goto :eof
