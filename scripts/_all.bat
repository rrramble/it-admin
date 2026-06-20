:: Combines and run all nested scripts

:: Changes current directory to the folder where this script is executed from.
:: This ensures that the script correctly located instead of "c:\windows\system32".
cd /d "%~dp0"
call no-auto-run/_all.bat

cd /d "%~dp0"
call power-config/_all.bat

cd /d "%~dp0"
call windows-update/_all.bat
