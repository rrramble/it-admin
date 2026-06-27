:: Sets the current directory to the folder where this script is executed from,
:: instead of "c:\windows\system32"
cd /d "%~dp0"
call chrome-noise.cmd

cd /d "%~dp0"
call edge-setup.cmd

cd /d "%~dp0"
call overall-noise.cmd
