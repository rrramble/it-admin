#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Write everything to a log file
exec > /var/log/custom_script_2.log 2>&1
export PS4='+ $(date "+%F %T") [${BASH_SOURCE##*/}:$LINENO] '
set -x

mkdir -p /var/empty
chmod 0755 /var/empty
chown root:root /var/empty

mkdir -p /run/sshd

# Create groups if missing
getent group zero_clients >/dev/null || groupadd --system zero_clients
getent group zero_operators >/dev/null || groupadd --system zero_operators

create_user() {
    local username="$1"
    local password_hash='$6$rounds=5000$'"$2"
    local group="$3"

    if ! id "$username" >/dev/null 2>&1; then
        useradd -M -N -d /var/empty \
            -s /usr/sbin/nologin \
            -g "$group" \
            -p "$password_hash" \
            "$username"
    else
        # Updates if user already exists
        usermod -p "$password_hash" "$username"
    fi
}

create_user 'user' 'PASSWORD_HASH' zero_clients
create_user 'operator' 'PASSWORD_HASH' zero_operators

echo "End of script"
