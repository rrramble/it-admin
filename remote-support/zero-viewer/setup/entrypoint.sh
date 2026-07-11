#!/bin/sh
set -e

add_users() {
    # Adds users from TXT-files to specified groups
    db_path=$1
    group=$2

    while IFS=: read -r user _; do
        [ -z "$user" ] && continue
        id "$user" >/dev/null 2>&1 && continue
        useradd -M -N -d /var/empty -s /usr/sbin/nologin -g "$group" "$user"
    done < "$db_path"
}

. /usr/local/bin/constants.conf

mkdir -p /var/empty
chmod 0755 /var/empty
chown root:root /var/empty

mkdir -p /etc/ssh/auth_db
chmod 0700 /etc/ssh/auth_db
chown root:root /etc/ssh/auth_db

mkdir -p /run/sshd

# Add Groups (ignores if already exist)
getent group zero_clients >/dev/null 2>&1 || groupadd --system zero_clients
getent group zero_operators >/dev/null 2>&1 || groupadd --system zero_operators

# Generate host keys if missing
ssh-keygen -A

add_users "$SERVER_OPERATORS_DB_PATH" zero_operators
add_users "$SERVER_CLIENTS_DB_PATH" zero_clients

# System host key verification checks
/usr/sbin/sshd -t || exit 1

# Run the daemons
service fail2ban start
exec /usr/sbin/sshd -D -e
