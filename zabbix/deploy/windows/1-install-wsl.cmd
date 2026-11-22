:: File: deploy-server/windows/1.cmd
:: Installs WSL and Ubuntu

wsl --install --no-distribution
wsl --update
wsl --set-default-version 2
wsl --install -d Ubuntu
