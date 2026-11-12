# Zabbix Agent 2 installation on Windows 10/11

- download and put [zabbix_agent2.msi version 8]() in this folder
- edit `SERVER_TARGET_IP_FOR_FIREWALL` variable in `_run.cmd`
- edit `Server` and `ServerActive` parameters in `custom.conf`
- tune parameters in `configs/` folder
- run `_run.bat` as Administrator


## Additional info:

- [Agent 2 installation via MSI](https://www.zabbix.com/documentation/8.0/en/manual/installation/install/win_msi)
- [Configuration files](https://www.zabbix.com/documentation/8.0/en/manual/concepts/agent2/agent2_params)
