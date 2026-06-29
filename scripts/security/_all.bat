:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call no-auto-run.cmd

cd /d "%~dp0"
call security.cmd

cd /d "%~dp0"
call uac.cmd
