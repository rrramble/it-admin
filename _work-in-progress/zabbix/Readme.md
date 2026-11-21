# Zabbix template for Docker environments

## Prerequisites

- Internet access
- Set up `/deploy-server/.env` file from `/deploy-server/.env.example`
- Installed Docker Engine (Linux) or Docker Desktop (MacOS)
- [Detailed prerequisites for Windows](./windows/Readme.md)


## Installation

1. Allow execution
- Linux/MacOS `chmod +x ./deploy-server/YOUR_OS_COMMAND`
- PowerShell for Windows `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

2. Run:
- Linux/MacOS `./deploy-server/run.sh`
- [Detailed instruction for Microsoft Windows](./windows/Readme.md)


## Kiosk version

(without a password use)

- Users > User Groups > Guests
-- Host permissions > Select: add all
-- Permissions: choose `Read`
-- Click `Update`

- Users > User Roles
-- Check only `Dashboards`
-- Enforce redirect after login
-- use URL: `zabbix.php?action=dashboard.view&kiosk=1`
-- Click `Update`

- Users > Users > guest
-- In `Groups` delete `disabled`
-- Click `Update`


## Configuring Windows agents

1. Import template `Custom Windows` (Data collection -> Templates -> Import)
1. Create host group `Custom discovered Windows hosts` (Data collection -> Host groups)
1. Create autoregistration action `Custom Autoregistering Windows host` (Alerts -> Actions -> Autoregistration actions)
- Condition: Host metadata: contains 'Windows'
- Operations:
-- Add host
-- Add host to group `Custom discovered Windows hosts`
-- Link template `Custom Windows`
1. Install and configure Zabbix Agent 2 on hosts

Verify:
- Data collection → Hosts
- Monitoring → Latest data
- Monitoring → Problems


## [Official templates](https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates?at=release%2F8.0)

- [OS Windows Agent Active]https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active/template_os_windows_agent_active.yaml?at=refs%2Fheads%2Frelease%2F8.0
