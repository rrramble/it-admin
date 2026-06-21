:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call google-noise.bat

cd /d "%~dp0"
call internet-noise.bat