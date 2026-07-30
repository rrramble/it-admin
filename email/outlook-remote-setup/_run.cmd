:: ===============================================================================
:: REMOTE OUTLOOK CONFIGURATION
:: Launches Outlook remotely via the `PsExec` program, specifying a PRF configuration file.
::
:: Requirements:
:: - "Psexec.exe" should be available
:: - Run this code as administrator
:: - Remote user must be logged in
:: - Outlook should be installed on the remote computer

set "TARGET_PC=PC-01"
set "SHARED_PRF_PATH=config.prf"

set "PATH_OFFICE_2010=C:\Program Files\Microsoft Office\Office14\OUTLOOK.EXE"
set "PATH_OFFICE_2013=C:\Program Files\Microsoft Office\Office15\OUTLOOK.EXE"
set "PATH_OFFICE_2016=C:\Program Files\Microsoft Office\Office16\OUTLOOK.EXE"

:: =================================
:: Uncomment needed path
:: set "FULL_OUTLOOK_PATH=%PATH_OFFICE_2010%"
:: set "FULL_OUTLOOK_PATH=%PATH_OFFICE_2013%"
:: set "FULL_OUTLOOK_PATH=%PATH_OFFICE_2016%"

if not defined FULL_OUTLOOK_PATH (
    echo ERROR: FULL_OUTLOOK_PATH should be uncommented in code.
    pause
    exit /b 1
)

:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"

where psexec >nul 2>&1
if errorlevel 1 (
    echo ERROR: PsExec was not found in PATH.
    pause
    exit /b 1
)

if not exist "%SHARED_PRF_PATH%" (
    echo ERROR: PRF file not found: "%SHARED_PRF_PATH%"
    pause
    exit /b 1
)

psexec \\%TARGET_PC% -i -d "%FULL_OUTLOOK_PATH%" /importprf "%SHARED_PRF_PATH%"
