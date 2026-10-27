:: ==============================================================
:: Combines and run all nested scripts
:: ==============================================================

setlocal enabledelayedexpansion

:: ======================
:: Check for Administrator privileges
fltmc >nul 2>&1
if %errorlevel% equ 0 goto :main_logic

:: Request elevation
echo Requests Administrator privileges

powershell.exe -NoProfile -Command ^
    "try { Start-Process -FilePath \"%~f0\" -Verb RunAs -ErrorAction Stop } catch { exit 1 }"

if errorlevel 1 (
    echo [ERROR] Elevation denied or failed.
    pause
    exit /b 1
)

exit /b
:main_logic

:: ======================
:: Sets the current directory to the folder containing this script,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call common/_all.bat

cd /d "%~dp0"
call internet/_all.bat

cd /d "%~dp0"
call no-auto-run/_all.bat

cd /d "%~dp0"
call power/_all.bat

cd /d "%~dp0"
call security/_all.bat

cd /d "%~dp0"
call windows-update/_all.bat
