:: File: deploy-server/windows/2.cmd
@echo Commands to check WSL status/setup

wsl --list --verbose

REM Compare result before with the following example response:
REM NAME   STATE   VERSION
REM Ubuntu Running 2
@echo.

wsl.exe -d Ubuntu --exec cat /etc/wsl.conf
@echo.
REM Compare result before with the following example response:
REM ...
REM [boot]
REM systemd=true
REM ...
