# Zabbix template for Docker environments

## Prerequisites

- Internet access
- Installed Docker
- Set up `/deploy-server/.env` from `/deploy-server/.env.example`


## Installation

1. Allow execution
- Linux/MacOS `chmod +x ./deploy-server/YOUR_OS_COMMAND`
- Windows `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

2. Run `./deploy-server/YOUR_OS_COMMAND`


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
