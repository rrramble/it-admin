:: ==============================================================
:: Blocks system-level Google Chrome browser installation,
:: allowing it only in local user profiles.
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal enabledelayedexpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges...
fltmc >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: Check if Google Chrome is currently running
tasklist /fi "IMAGENAME eq chrome.exe" 2>nul | findstr /i "chrome.exe" >nul
if %errorLevel% eq 0 (
    echo [WARNING] Google Chrome is currently running!
    echo [ABORT] Script stopped to prevent data loss. Close Chrome and try again.
    pause
    exit /b 1
)

:: ======================
:: 1. Block in Program Files (64-bit)
call :BlockChrome "%ProgramFiles%\Google"

:: 2. Block in Program Files (32-bit)
if defined ProgramFiles(x86) (
    call :BlockChrome "%ProgramFiles(x86)%\Google"
)

echo [SUCCESS] System-level Chrome blocks applied successfully.
exit /b 0

:: ======================
:: Helper Function to Safely Block Directory
:BlockChrome
set "ParentDir=%~1"
set "StubPath=%~1\Chrome"

:: Ensure parent directory exists first
if not exist "%ParentDir%" mkdir "%ParentDir%"

:: Reset permissions if stub exists to prevent script lockout
if exist "%StubPath%" (
    takeown /f "%StubPath%" /a >nul 2>&1
    icacls "%StubPath%" /reset >nul 2>&1
    del /f /q "%StubPath%" 2>nul
    rd /s /q "%StubPath%" 2>nul
)

:: Create the file-stub
echo This is a file-stub: do not delete!> "%StubPath%"

:: Secure the file-stub:
:: 1. Remove inheritance.
:: 2. Grant Administrators and SYSTEM full control (prevents system instability).
:: 3. Deny Users (S-1-5-32-545) write and execute permissions.
icacls "%StubPath%" /inheritance:r >nul
icacls "%StubPath%" /grant:r *S-1-5-32-544:(F) >nul
icacls "%StubPath%" /grant:r *S-1-5-18:(F) >nul
icacls "%StubPath%" /deny *S-1-5-32-545:(W,X) >nul

exit /b 0
