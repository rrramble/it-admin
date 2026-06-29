:: ============================================================
:: Windows Privacy/Telemetry Hardening (only for Workgroups, not for AD!)
:: ============================================================

:: ======================
@echo [INFO] Checks and sets pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [FATAL] Administrative privileges required. Execution halted.
    exit /b 1
)

:: ======================
@echo [INFO] Applying Machine Policy layers

set "KEY_HKLM_MS=HKLM\SOFTWARE\Policies\Microsoft\Windows"

:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-textinput
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" /v "AllowLinguisticDataCollection" /t REG_DWORD /d 0 /f

:: https://learn.microsoft.com/ru-ru/windows/client-management/mdm/policy-csp-privacy
reg add "%KEY_HKLM_MS%\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >nul
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-experience
reg add "%KEY_HKLM_MS%\CloudContent" /v DisableTailoredExperiencesWithDiagnosticData /t REG_DWORD /d 1 /f >nul
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-experience
reg add "%KEY_HKLM_MS%\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system
reg add "%KEY_HKLM_MS%\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-experience
reg add "%KEY_HKLM_MS%\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f >nul
:: https://learn.microsoft.com/ru-ru/windows/client-management/mdm/policy-csp-privacy
reg add "%KEY_HKLM_MS%\InputPersonalization" /v AllowInputPersonalization /t REG_DWORD /d 0 /f >nul
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-privacy
reg add "%KEY_HKLM_MS%\System" /v PublishUserActivities /t REG_DWORD /d 0 /f >nul
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-privacy
reg add "%KEY_HKLM_MS%\System" /v UploadUserActivities /t REG_DWORD /d 0 /f >nul
:: https://winitpro.ru/index.php/2017/12/19/sluzhba-windows-error-reporting-i-ochistka-kataloga-werreportqueue-v-windows/
reg add "%KEY_HKLM_MS%\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul
:: https://learn.microsoft.com/ru-ru/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
reg add "%KEY_HKLM_MS%\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f

:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-search
reg add "%KEY_HKLM_MS%\Windows Search" /v AllowSearchToUseLocation /t REG_DWORD /d 0 /f
    :: the following does not affect Windows Professional
reg add "%KEY_HKLM_MS%\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f

:: ======================
@echo [INFO] Service Control Layer
call :ManageService "DiagTrack"
call :ManageService "dmwappushservice"
call :ManageService "WerSvc"

:: ======================
@echo [INFO] Current User Layer (HKCU)
set "KEY_HKCU_MS_WIN_CURR=HKCU\Software\Microsoft\Windows\CurrentVersion"
set "KEY_HKCU_MS_INP_PERS=HKCU\Software\Microsoft\InputPersonalization"

:: https://learn.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
reg add "%KEY_HKCU_MS_INP_PERS%" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f >nul
:: https://learn.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
reg add "%KEY_HKCU_MS_INP_PERS%" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f >nul

:: ======================
@echo [INFO] Default Profile (NTUSER.DAT) enforcement
set "DEFAULT_HIVE=%SystemDrive%\Users\Default\NTUSER.DAT"

if exist "%DEFAULT_HIVE%" (
    :: Force an unload first to clear any stale or orphaned mounts from previous failures
    reg unload "HKLM\TEMP_DEFAULT" >nul 2>&1

    :: Explicitly flush errorlevel back to 0 to wipe out the proactive unload failure code
    cmd /c "exit /b 0"

    reg load "HKLM\TEMP_DEFAULT" "%DEFAULT_HIVE%" >nul 2>&1
    if !errorLevel! equ 0 (
        :: Wrapped inside a conditional block ensuring execution occurs only when loaded successfully
        set "KEY_HKLM_DEF_POLICY=HKLM\TEMP_DEFAULT\Software\Policies\Microsoft\Windows"
        set "KEY_HKLM_MS_WIN_CURR_VERS=HKLM\TEMP_DEFAULT\Software\Microsoft\Windows\CurrentVersion"
        set "KEY_HKLM_DEF_INPUT_PERS=HKLM\TEMP_DEFAULT\Software\Microsoft\InputPersonalization"

        :: https://learn.microsoft.com/ru-ru/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
        reg add "!KEY_HKLM_DEF_POLICY!\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul
        :: PARTLY! https://learn.microsoft.com/en-us/troubleshoot/windows-client/system-management-components/windows-error-reporting-diagnostics-enablement-guidance
        reg add "!KEY_HKLM_DEF_POLICY!\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul
        :: PARTLY! https://learn.microsoft.com/ru-ru/windows/client-management/mdm/policy-csp-privacy
        reg add "!KEY_HKLM_MS_WIN_CURR_VERS!\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul
        :: PARTLY! https://learn.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
        reg add "!KEY_HKLM_DEF_INPUT_PERS!" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f >nul
        reg add "!KEY_HKLM_DEF_INPUT_PERS!" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f >nul

        :: Mandatory clean unload
        reg unload "HKLM\TEMP_DEFAULT" >nul
        echo [OK] Default profile updated successfully.
    ) else (
        echo [WARN] Failed to load Default Profile hive. Code: !errorLevel!
    )
) else (
    echo [WARN] Default User Profile path not detected. Skipping baseline injection.
)

:: ======================
@echo [INFO] Clean Exit Mechanics
exit /b 0
goto :eof

:: ======================
:: FUNCTIONS

:ManageService
set "SVC_NAME=%~1"
sc query "%SVC_NAME%" >nul 2>&1
if !errorLevel! neq 0 (
    echo [SKIP] Service "%SVC_NAME%" is not present on this machine base.
    goto :eof
)
sc stop "%SVC_NAME%" >nul 2>&1
sc config "%SVC_NAME%" start= disabled >nul 2>&1
echo [OK] Service disabled: %SVC_NAME%
goto :eof
