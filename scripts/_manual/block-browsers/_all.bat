:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call atom.bat

cd /d "%~dp0"
call chrome.cmd

cd /d "%~dp0"
call yandex.bat
