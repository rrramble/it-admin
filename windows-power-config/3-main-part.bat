@ECHO Run it as Administrator!
REM ! Replace {SCHEME_GUID} below with the needed GUID taken from `powercfg /list` !
@REM Usual GUIDs (but can be other, user-made):
@REM - High performance: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
@REM - Balanced: 381b4222-f694-41f0-9685-ff5bb260df2e
@REM - Power saver: a1841308-3541-4fab-bc81-f71556f20b4a
set SCHEME_GUID={SCHEME_GUID}

@REM ===========================
REM 0. Activate the power scheme
powercfg /setactive %SCHEME_GUID%

@REM ===========================
REM 1. Timeout of switching off the display - AC and DC (minutes)
powercfg /change monitor-timeout-ac 120
powercfg /change monitor-timeout-dc 30

@REM ===========================
REM 2. USB selective suspend AC and DC (disabled)
powercfg /setacvalueindex %SCHEME_GUID% 2a737441-1930-4402-8d77-b2bebba308a3 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0
powercfg /setdcvalueindex %SCHEME_GUID% 2a737441-1930-4402-8d77-b2bebba308a3 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0

@REM ===========================
REM 3. Sleep timeout AC and DC (minutes)
powercfg /change standby-timeout-ac 240
powercfg /change standby-timeout-dc 60

@REM ===========================
REM 4. Allow sleep AC and DC (disable)
powercfg /setacvalueindex %SCHEME_GUID% 238C9FA8-0AAD-41ED-83F4-97BE242C8F20 29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA 0
powercfg /setdcvalueindex %SCHEME_GUID% 238C9FA8-0AAD-41ED-83F4-97BE242C8F20 29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA 1

@REM ===========================
REM 5. Hibernate timeout AC (disable, command in minutes)
powercfg /change hibernate-timeout-ac 0
powercfg /hibernate off

@REM ===========================
REM 6. Hibernate timeout DC (disable, command in minutes)
powercfg /change hibernate-timeout-dc 240
powercfg /hibernate off

@REM ===========================
REM 7. CPU minimum and maximum processor state AC (%)
powercfg /setacvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 50
powercfg /setacvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

@REM ===========================
REM 8. CPU minimum and maximum processor state DC (%)
powercfg /setdcvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 20
powercfg /setdcvalueindex %SCHEME_GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 80

@REM ===========================
REM Apply changes
powercfg /S %SCHEME_GUID%

echo Power settings updated
pause
