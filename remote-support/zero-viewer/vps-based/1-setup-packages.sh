#!/usr/bin/env bash

# A warning:
# This script relies on the ($_DDCLIENT_LOGIN) and ($_DDCLIENT_PASSWORD)
# variables passed from the VPS host server

set -o errexit -o nounset -o pipefail

# Write everything to a log file
exec > /var/log/custom_script_1.log 2>&1
export PS4='+ $(date "+%F %T") [${BASH_SOURCE##*/}:$LINENO] '
set -x


######################################
# Variables
TCP_PORT=9022

######################################
# Set up SSH

## Next file
FILENAME=/etc/ssh/sshd_config.d/99-custom.conf
cat > "$FILENAME" <<EOF
Port $TCP_PORT
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

## Next file
FILENAME=/etc/ssh/sshd_config.d/security.conf
cat <<'EOF' | sudo tee "$FILENAME" > /dev/null
PermitRootLogin no
MaxStartups 10:30:60
PerSourceMaxStartups 1
LoginGraceTime 3
MaxAuthTries 1
MaxSessions 2
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

## Next file
FILENAME=/etc/ssh/sshd_config.d/whitelist.conf
cat <<'EOF' | sudo tee "$FILENAME" > /dev/null
AllowUsers *@*
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

######################################
### ### Configures `pam` ### ###
## Next file
FILENAME=/etc/security/access.conf
cat <<'EOF' | sudo tee "$FILENAME" > /dev/null
+ : zero_clients : ALL
+ : zero_operators : ALL
- : ALL : ALL
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

## Next file
FILENAME=/etc/pam.d/sshd
cat <<'EOF' | sudo tee "$FILENAME" > /dev/null
auth required pam_env.so
@include common-auth
account required pam_nologin.so
account required pam_access.so
session required pam_loginuid.so
session required pam_env.so
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

## Run folder for `ssh.service`
install -d -m0755 -o root -g root /run/sshd


## Next file
FILENAME=/etc/ssh/sshd_config.d/zeroviewer.conf
cat <<'EOF' | sudo tee "$FILENAME" > /dev/null
HostKey /etc/ssh/ssh_host_ed25519_key
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com

#GatewayPorts yes #TODO: yes or no?
GatewayPorts no

PasswordAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes

AllowTcpForwarding no
AllowStreamLocalForwarding no
AllowAgentForwarding no
X11Forwarding no
PermitTunnel no
PermitTTY no

Match Group zero_clients
    AllowUsers *@*
    AllowTcpForwarding remote
    AllowStreamLocalForwarding no
    AllowAgentForwarding no
    GatewayPorts no
    X11Forwarding no
    PermitTunnel no
    ForceCommand echo "Authenticated successfully. Reverse tunnel active. No shell access available."

Match Group zero_operators
    AllowUsers *@*
    AllowTcpForwarding local
    AllowStreamLocalForwarding no
    AllowAgentForwarding no
    GatewayPorts no
    X11Forwarding no
    PermitTunnel no
    ForceCommand echo "Authenticated successfully. Desktop connection active. No shell access available."
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

######################################
### ### Configures `fail2ban`` ### ###
## Next file
FILENAME=/etc/fail2ban/fail2ban.local
cat <<'EOF' | sudo tee "$FILENAME" > /dev/null
[Definition]
allowipv6 = auto
dbpurgeage = 72000
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

## Next file
FILENAME=/etc/fail2ban/jail.local
cat <<EOF | sudo tee "$FILENAME" > /dev/null
[sshd]
enabled = true
port = $TCP_PORT
filter = sshd
maxretry = 2
findtime = 1m
bantime = 1m
backend = systemd
banaction = iptables-multiport
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"


## Next file
#TODO: check deletion
FILENAME=/etc/fail2ban/jail.d/sshd.local
cat <<EOF | sudo tee "$FILENAME" > /dev/null
[sshd]
enabled = true
port = $TCP_PORT
backend = systemd
filter = sshd
maxretry = 2
findtime = 1m
bantime = 1m
banaction = iptables-multiport
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

######################################
# Configures `ddclient`
## Next file
FILENAME=/etc/ddclient.conf
cat <<EOF | sudo tee "$FILENAME" > /dev/null
login=($_DDCLIENT_LOGIN)
password="($_DDCLIENT_PASSWORD)"
protocol=noip
server=dynupdate.no-ip.com
daemon=60
ssl=yes
use=web
web=checkip.amazonaws.com
kng.ddns.net
EOF
chmod 644 "$FILENAME"
chown root:root "$FILENAME"

######################################
### ### Apply services ### ###
systemctl disable --now ssh.socket || true
systemctl mask ssh.socket || true
systemctl daemon-reload
sshd -t
systemctl enable --now ssh.service
systemctl restart ssh.service

systemctl enable fail2ban.service
systemctl restart fail2ban.service

systemctl enable ddclient.service
systemctl restart ddclient.service

echo "End of script"
