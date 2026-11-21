#!/usr/bin/cat
# File: deploy-server/setup-docker.sh
# This script is not run directly but used in other scripts

set -Eeuo pipefail

MODE="${1:?mode is required}"
LINUX_USER="${2:-}"
SOURCE_DIR="${3:-}"

case "$MODE" in
    enable-systemd)
        touch /etc/wsl.conf
        tmp_file="$(mktemp)"
        awk '
            BEGIN { in_boot=0; found_boot=0; wrote_systemd=0 }
            {
                line=$0
                if (line ~ /^[[:space:]]*\[boot\][[:space:]]*$/) {
                    if (in_boot && !wrote_systemd) { print "systemd=true"; wrote_systemd=1 }
                    found_boot=1
                    in_boot=1
                    print line
                    next
                }
                if (line ~ /^[[:space:]]*\[[^]]+\][[:space:]]*$/) {
                    if (in_boot && !wrote_systemd) { print "systemd=true"; wrote_systemd=1 }
                    in_boot=0
                }
                if (in_boot && line ~ /^[[:space:]]*systemd[[:space:]]*=/) {
                    if (!wrote_systemd) print "systemd=true"
                    wrote_systemd=1
                    next
                }
                print line
            }
            END {
                if (in_boot && !wrote_systemd) print "systemd=true"
                if (!found_boot) { print ""; print "[boot]"; print "systemd=true" }
            }
        ' /etc/wsl.conf > "$tmp_file"
        install -m 0644 "$tmp_file" /etc/wsl.conf
        rm -f "$tmp_file"
        ;;

    install-docker-and-deploy)
        [[ -n "$LINUX_USER" && -n "$SOURCE_DIR" ]] || { echo 'Linux user and source directory are required.' >&2; exit 2; }
        id "$LINUX_USER" >/dev/null 2>&1 || { echo "Linux user '$LINUX_USER' does not exist." >&2; exit 1; }
        [[ "$(id -u "$LINUX_USER")" -ne 0 ]] || { echo 'A non-root Ubuntu user is required.' >&2; exit 1; }
        [[ -d /run/systemd/system ]] || { echo 'systemd is not active in WSL. Check /etc/wsl.conf and restart the distribution.' >&2; exit 1; }
        . /etc/os-release
        [[ "$ID" == 'ubuntu' ]] || { echo "Expected Ubuntu; found $ID." >&2; exit 1; }

        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        architecture="$(dpkg --print-architecture)"
        codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
        printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu %s stable\n' \
            "$architecture" "$codename" > /etc/apt/sources.list.d/docker.list
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        systemctl enable --now docker
        usermod -aG docker "$LINUX_USER"
        docker info >/dev/null
        docker compose version

        user_home="$(getent passwd "$LINUX_USER" | cut -d: -f6)"
        [[ -n "$user_home" && -d "$user_home" ]] || { echo "Could not determine home directory for '$LINUX_USER'." >&2; exit 1; }
        destination="$user_home/zabbix-deploy-server"
        mkdir -p "$destination"
        cp -a "$SOURCE_DIR/." "$destination/"
        chown -R "$LINUX_USER:$LINUX_USER" "$destination"
        chmod 700 "$destination"
        chmod 600 "$destination/.env"
        chmod +x "$destination/run.sh"

        echo 'Starting the Zabbix deployment installer...'
        su - "$LINUX_USER" -c "cd '$destination' && ./run.sh"
        ;;

    *)
        echo "Unknown mode: $MODE" >&2
        exit 2
        ;;
esac
