:: ==============================================================
:: Combines and run all nested scripts
:: ==============================================================

setlocal enabledelayedexpansion

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
