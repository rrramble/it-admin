:: Combines and run all nested scripts

:: Changes current directory to the folder where this script is executed from.
:: This ensures that the script correctly located instead of "c:\windows\system32".
cd /d "%~dp0"
block-browsers/_all.bat

cd /d "%~dp0"
no-auto-run/_all.bat

cd /d "%~dp0"
power-config/_all.bat
