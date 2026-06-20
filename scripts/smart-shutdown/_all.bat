setlocal EnabledDelayedExpansion

set "HTA_FILE_NAME=smart-shutdown.hta"
set "TARGET_DIR=%SystemDrive%\Program Files\_IT\smart-shutdown"
set "TASK_NAME=SmartNightlyShutdown"
set "TASK_TIME=17:30"

:: Changes current directory to the folder where this script is executed from.
:: This ensures that the script correctly locates the HTA file instead of "c:\windows\system32".
cd /d "%~dp0"

:: Creates a folder to house the script if it does not exist
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

:: Copies HTA (forces rewriting of an old version)
copy /y "%~dp0%HTA_FILE_NAME%" "%TARGET_DIR%\%HTA_FILE_NAME%"

:: Gives full access for SYSTEM (S-1-5-18) and BUILTIN\Admininistrators (S-1-5-32-544).
:: Gives read/run access for BUILTIN\Users (S-1-5-32-545).
icacls "%TARGET_DIR%\%HTA_FILE_NAME%" /inheritance:r
icacls "%TARGET_DIR%\%HTA_FILE_NAME%" /grant:r *S-1-5-18:(F)
icacls "%TARGET_DIR%\%HTA_FILE_NAME%" /grant:r *S-1-5-32-544:(F)
icacls "%TARGET_DIR%\%HTA_FILE_NAME%" /grant:r *S-1-5-32-545:(RX)

:: Deletes the old scheduled task if it exists to avoid conflicts
schtasks /delete /tn "%TASK_NAME%" /f 2>nul

:: Registers the new task in Windows Task Scheduler.
:: Runs the task daily using the SYSTEM account with the highest privileges.
schtasks /create /tn "%TASK_NAME%" /tr "mshta.exe \"%TARGET_DIR%\%HTA_NAME%\"" /sc daily /st %TASK_TIME% /ru "SYSTEM" /rl highest

@echo Completed!
