:: ==============================================================
:: Blocks system-level Mozilla Firefox browser installation,
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
if errorLevel 1 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: Check if Mozilla Firefox is currently running
tasklist /fi "IMAGENAME eq firefox.exe" 2>nul | findstr /i "firefox.exe" >nul
if %errorLevel% eq 0 (
    echo [WARNING] Mozilla Firefox is currently running!
    echo [ABORT] Script stopped to prevent data loss. Close Firefox and try again.
    pause
    exit /b 1
)

:: ======================
:: 1. Block in Program Files (64-bit)
call :BlockFirefox "%ProgramFiles%\Mozilla Firefox"

:: 2. Block in Program Files (32-bit)
if defined ProgramFiles(x86) (
    call :BlockFirefox "%ProgramFiles(x86)%\Mozilla Firefox"
)

echo [SUCCESS] System-level Firefox blocks applied successfully.
exit /b 0

:: ======================
:: Helper Function to Safely Block Directory
:BlockFirefox
set "StubPath=%~1"

:: Reset permissions if stub or directory exists to prevent script lockout
if exist "%StubPath%" (
    takeown /f "%StubPath%" /a >nul 2>&1
    icacls "%StubPath%" /reset >nul 2>&1
    del /f /q "%StubPath%" 2>nul
    rd /s /q "%StubPath%" 2>nul
)

:: Create the file-stub (without literal quotation marks inside the file)
echo This is a file-stub: do not delete!> "%StubPath%"

:: Secure the file-stub:
:: 1. Remove inheritance.
:: 2. Grant Administrators (S-1-5-32-544) and SYSTEM (S-1-5-18) full control to avoid OS instability.
:: 3. Deny built-in Users (S-1-5-32-545) write and execute permissions.
icacls "%StubPath%" /inheritance:r >nul
icacls "%StubPath%" /grant:r *S-1-5-32-544:(F) >nul
icacls "%StubPath%" /grant:r *S-1-5-18:(F) >nul
icacls "%StubPath%" /deny *S-1-5-32-545:(W,X) >nul

exit /b 0
