:: Changes current directory to the folder where this script is executed from.
:: This ensures that the script correctly located instead of "c:\windows\system32".
cd /d "%~dp0"
1-screensaver.bat

cd /d "%~dp0"
3-main-part.bat

:: TODO: rename 'main-part'