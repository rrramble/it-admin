#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Write everything to a log file
exec > /var/log/custom_script_0.log 2>&1
export PS4='+ $(date "+%F %T") [${BASH_SOURCE##*/}:$LINENO] '
set -x

export DEBIAN_FRONTEND=noninteractive


# Requirements from VMManager
## Block automatic updates during user's installations
apt-mark hold qemu-guest-agent || :
apt-get update
apt-get -yy dist-upgrade

# Preseed ddclient configuration to avoid interactive prompts
echo "ddclient ddclient/run_daemon boolean false" | debconf-set-selections
echo "ddclient ddclient/daemon_interval string 300" | debconf-set-selections

apt-get install -y --no-install-recommends \
    openssh-server \
    ca-certificates \
    libpam-pwdfile \
    libpam-modules \
    libpam-modules-bin \
    passwd \
    fail2ban \
    ddclient \
    libio-socket-ssl-perl

pam-auth-update --package >/dev/null 2>&1 || true

# Requirements from VMManager
# Restore automatic updates
apt-mark unhold qemu-guest-agent || :

rm -rf /var/lib/apt/lists/*
echo "End of script"
