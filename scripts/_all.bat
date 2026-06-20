:: ==============================================================
:: Combines and run all nested scripts
:: ==============================================================

setlocal enabledelayedexpansion

:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call block-browsers/_all.bat

cd /d "%~dp0"
call no-auto-run/_all.bat

cd /d "%~dp0"
call power-config/_all.bat

cd /d "%~dp0"
call windows-update/_all.bat
