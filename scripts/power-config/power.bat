:: ==============================================================
:: Sets up the Power scheme
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnabledDelayedExpansion
chcp 65001 >nul

::
:: Variables section
::
set SCHEME_GUID=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
@REM Usual GUIDs:
@REM - High performance: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
@REM - Balanced: 381b4222-f694-41f0-9685-ff5bb260df2e
@REM - Power saver: a1841308-3541-4fab-bc81-f71556f20b4a

@echo Verifying Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ===========================
@echo Checking if the target power scheme exists and recreating if missing
powercfg /list | findstr /i "%SCHEME_GUID%" >nul 2>&1
if %errorLevel% neq 0 (
    @echo [WARNING] Power scheme %SCHEME_GUID% was missing. Re-importing factory default blueprint.
    powercfg /duplicatescheme %SCHEME_GUID% >nul
)

:: ===========================
@echo 1. Activate the power scheme
powercfg /setactive %SCHEME_GUID%

:: ===========================
@echo 2. Timeout of switching off the display - AC and DC (in minutes)
powercfg /change monitor-timeout-ac 120
powercfg /change monitor-timeout-dc 30

:: ===========================
@echo 3. USB selective suspend AC and DC (disabled)
powercfg /setacvalueindex %SCHEME_GUID% 2a737441-1930-4402-8d77-b2bebba308a3 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0
powercfg /setdcvalueindex %SCHEME_GUID% 2a737441-1930-4402-8d77-b2bebba308a3 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0

:: ===========================
@echo 4. Sleep
@echo 4.1. AC (0 = disabled, time in minutes)
powercfg /setacvalueindex %SCHEME_GUID% 238C9FA8-0AAD-41ED-83F4-97BE242C8F20 29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA 0
powercfg /change standby-timeout-ac 0

@echo 4.2. DC (1 = enabled, time in minutes)
powercfg /setdcvalueindex %SCHEME_GUID% 238C9FA8-0AAD-41ED-83F4-97BE242C8F20 29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA 1
powercfg /change standby-timeout-dc 30

:: ===========================
@echo 5. Hibernate timeout AC and DC (disable, command in minutes)
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 240
powercfg /hibernate off

:: ===========================
@echo 6. CPU minimum and maximum processor state
@echo 6.1. AC (%)
powercfg /setacvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 50
powercfg /setacvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

@echo 6.2. DC (%)
powercfg /setdcvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 20
powercfg /setdcvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 80

:: ===========================
@echo 7. Re-activate the power scheme
:: Should be done to apply the settings (yes, the 2nd time!)
powercfg /setactive %SCHEME_GUID%
