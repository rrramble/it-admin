:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call 1-screensaver.bat

cd /d "%~dp0"
call 3-main-part.bat

:: TODO: rename '3-main-part'