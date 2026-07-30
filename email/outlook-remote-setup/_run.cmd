@echo off
:: ===============================================================================
:: REMOTE OUTLOOK CONFIGURATION
:: This script creates Outlook profile using `PsExec` program
::
:: Requirements:
:: - `Psexec.exe` should be available.
:: - Run this code as administrator.
:: - Remote user must be logged in.
:: - Outlook should be installed on the remote computer.

set "TARGET_PC=PC-01"
set "SHARED_PRF_PATH=config.prf"

:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"

:: Note: Update the path below for your version of Outlook:
:: For Office 2010: "C:\Program Files\Microsoft Office\Office14\OUTLOOK.EXE"
:: For Office 2013: "C:\Program Files\Microsoft Office\Office15\OUTLOOK.EXE"
:: For Office 2016 / 2019 / 2021 / 365: "C:\Program Files\Microsoft Office\Office16\OUTLOOK.EXE"

psexec \\%TARGET_PC% -i -d "C:\Program Files\Microsoft Office\Office16\OUTLOOK.EXE" /importprf "%SHARED_PRF_PATH%"
