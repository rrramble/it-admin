:: ==============================================================================
:: Warning: This script is for Workgroups, not for Active Directory!
::
:: Configure Password Length via Local Security Policy
:: Enforces a minimum password length using Local Security Templates.
:: ==============================================================================

:: ======================
@echo Pre-requisites
setlocal EnabledDelayedExpansion
chcp 65001 >nul

@echo Verifing Administrator privileges
net session >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    endlocal
    exit /b 1
)

:: Configuration Variables
set "MIN_PASSWORD_LENGTH=6"
set "SEC_CONFIG_IN=%TEMP%\sec_config_in.inf"
set "SEC_CONFIG_OUT=%TEMP%\sec_config_out.inf"
set "SEC_DB=%TEMP%\sec_tmp.sdb"

@echo Cleanup any leftover temporary files from previous runs
if exist "!SEC_CONFIG_IN!" del /f /q "!SEC_CONFIG_IN!" >nul 2>&1
if exist "!SEC_CONFIG_OUT!" del /f /q "!SEC_CONFIG_OUT!" >nul 2>&1
if exist "!SEC_DB!" del /f /q "!SEC_DB!" >nul 2>&1

:: ======================
:: Exports Current Security Policy
@echo [INFO] Reads local security configuration database
secedit /export /cfg "!SEC_CONFIG_IN!" /areas SECURITYPOLICY >nul 2>&1

if !errorLevel! neq 0 (
    echo [ERROR] Failed to export current security policy.
    endlocal
    exit /b 1
)

:: ======================
@echo Modifies Policy Template
set "FoundSetting=False"

:: Read the exported file line by line and update the password length setting
for /f "usebackq tokens=*" %%A in ("!SEC_CONFIG_IN!") do (
    set "LINE=%%A"
    echo !LINE! | findstr /I /C:"MinimumPasswordLength" >nul
    if !errorLevel! == 0 (
        echo MinimumPasswordLength = !MIN_PASSWORD_LENGTH!>> "!SEC_CONFIG_OUT!"
        set "FoundSetting=True"
    ) else (
        echo !LINE!>> "!SEC_CONFIG_OUT!"
    )
)

:: If the setting did not exist in the template, append it under the correct section
if "!FoundSetting!"=="False" (
    echo [WARN] MinimumPasswordLength template section missing. Re-building configuration
    (
        echo [Unicode]
        echo Unicode=yes
        echo [System Access]
        echo MinimumPasswordLength = !MIN_PASSWORD_LENGTH!
        echo [Version]
        echo signature="$CHICAGO$"
        echo Revision=1
    ) > "!SEC_CONFIG_OUT!"
)

:: ======================
@echo Applies Configuration to Local Database
@echo [INFO] Commits new policy template to the operating system
:: We use a local temp SDB file to apply settings directly to the local system database
secedit /configure /db "!SEC_DB!" /cfg "!SEC_CONFIG_OUT!" /areas SECURITYPOLICY /log "%TEMP%\secedit_run.log" >nul 2>&1

if !errorLevel! neq 0 (
    echo [ERROR] Secedit failed to configure the security policy database.
    goto CleanupAndExitError
)

:: WORKGROUP: Instead of 'gpupdate', we trigger an explicit machine policy
:: refresh directly on the local Security Configuration Engine.
secedit /refreshpolicy machine_policy >nul 2>&1

:: ======================
@echo Verifies Target Setting
set "Verified=False"

for /f "tokens=*" %%L in ('net accounts') do (
    set "LINE=%%L"
    for /l %%I in (1,1,3) do (if "!LINE:~-1!"==" " set "LINE=!LINE:~0,-1!")
    echo !LINE!| findstr /R /C:"[! \t][! \t]*!MIN_PASSWORD_LENGTH!$" >nul
    if !errorLevel! == 0 (
        echo !LINE!| findstr /I /R "length len lng m¡n min" >nul
        if !errorLevel! == 0 set "Verified=True"
    )
)

if "!Verified!"=="True" (
    echo [SUCCESS] Local policy updated. Minimum password length is strictly !MIN_PASSWORD_LENGTH!.
    goto CleanupAndExitSuccess
) else (
    echo [ERROR] Policy verification failed. System value does not match !MIN_PASSWORD_LENGTH!.
    goto CleanupAndExitError
)

:CleanupAndExitSuccess
if exist "!SEC_CONFIG_IN!" del /f /q "!SEC_CONFIG_IN!" >nul 2>&1
if exist "!SEC_CONFIG_OUT!" del /f /q "!SEC_CONFIG_OUT!" >nul 2>&1
if exist "!SEC_DB!" del /f /q "!SEC_DB!" >nul 2>&1
endlocal
exit /b 0

:CleanupAndExitError
if exist "!SEC_CONFIG_IN!" del /f /q "!SEC_CONFIG_IN!" >nul 2>&1
if exist "!SEC_CONFIG_OUT!" del /f /q "!SEC_CONFIG_OUT!" >nul 2>&1
if exist "!SEC_DB!" del /f /q "!SEC_DB!" >nul 2>&1
endlocal
exit /b 2
