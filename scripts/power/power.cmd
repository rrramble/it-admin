:: ==============================================================
:: Sets up the Power scheme
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

::
:: Variables
::
set SCHEME_GUID=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
@REM Usual GUIDs:
@REM - High performance: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
@REM - Balanced: 381b4222-f694-41f0-9685-ff5bb260df2e
@REM - Power saver: a1841308-3541-4fab-bc81-f71556f20b4a

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if errorLevel 1 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ===========================
@echo Check if the target power scheme exists
powercfg /list | findstr /i "%SCHEME_GUID%" >nul 2>&1
if errorLevel 1 (
    @echo [ERROR] Power scheme %SCHEME_GUID% is missing
    exit /b 1
)

:: ===========================
@echo Activate the power scheme
powercfg /setactive %SCHEME_GUID%
if errorLevel 1 (
    @echo [ERROR] Failed to activate power scheme
    exit /b 1
)

:: ===========================
@echo Timeout of switching off the display - AC and DC (in minutes)
powercfg /change monitor-timeout-ac 120
powercfg /change monitor-timeout-dc 30

:: ===========================
@echo Suggest using legacy S3-sleep, avoid modern S0-sleep due to instability
@echo [WARNING] *** This setting should be supported by BIOS settings ***
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v PlatformAoAcOverride /t REG_DWORD /d 0 /f

:: ===========================
@echo USB selective suspend AC and DC (disabled)
powercfg /setacvalueindex %SCHEME_GUID% 2a737441-1930-4402-8d77-b2bebba308a3 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0
powercfg /setdcvalueindex %SCHEME_GUID% 2a737441-1930-4402-8d77-b2bebba308a3 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0

:: ===========================
@echo Sleep for AC and DC modes (time in minutes, 0 - always on)
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 30

:: ===========================
@echo Hibernate timeout for AC and DC (disable, time in minutes)
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 240
powercfg /hibernate off

:: ===========================
@echo CPU minimum and maximum processor state (in %)
:: 54533251-82be-4824-96c1-47b60b740d00 - GUID Processor settings subroup
:: 36687f9e-e3a5-4dbf-b1dc-15eb381c6863 - Energy-saving Preference
:: bc5038f7-23e0-4960-96da-33abaf5935ec - Maximum CPU state
:: Legacy control, modern CPUs may partially ignore min state:
:: 893dee8e-2bef-41e0-89c6-b55d0929964c - Minimum CPU state

@echo AC
powercfg /setacvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 50
powercfg /setacvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

@echo DC
powercfg /setdcvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 20
powercfg /setdcvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

:: ===========================
@echo Re-activate the power scheme
:: Should be done to apply the settings (yes, the 2nd time!)
powercfg /setactive %SCHEME_GUID%
