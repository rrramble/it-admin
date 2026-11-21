:: File: deploy-server/windows/2.cmd
:: Commands to check WSL status/setup

wsl --list --verbose

:: Example response:
:: NAME   STATE   VERSION
:: Ubuntu Running 2

wsl.exe -d Ubuntu --exec cat /etc/wsl.conf

:: Example result:
:: ...
:: [boot]
:: systemd=true
:: ...
