#!/usr/bin/cat
# File: deploy-server/setup-docker.sh
# This script is not run directly but used in other scripts

set -Eeuo pipefail

LINUX_USER="${1:?Linux user is required.}"
SOURCE_DIR="${2:?Source directory is required.}"

# Must run as root.
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must run as root." >&2
    exit 1
fi

# Verify the Linux user.
if ! id "$LINUX_USER" >/dev/null 2>&1; then
    echo "Linux user '$LINUX_USER' does not exist." >&2
    exit 1
fi

if [[ "$(id -u "$LINUX_USER")" -eq 0 ]]; then
    echo "A non-root Linux user is required." >&2
    exit 1
fi

# Validate the source directory.
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Source directory not found: $SOURCE_DIR" >&2
    exit 1
fi

SOURCE_DIR="$(realpath "$SOURCE_DIR")"

# Verify systemd.
if [[ ! -d /run/systemd/system ]]; then
    echo "systemd is not active. Check WSL configuration and restart the distribution." >&2
    exit 1
fi

# Verify Ubuntu.
. /etc/os-release

if [[ "$ID" != "ubuntu" ]]; then
    echo "Expected Ubuntu; found '$ID'." >&2
    exit 1
fi

# Install prerequisites.
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    curl

# Configure the official Docker repository.
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

ARCHITECTURE="$(dpkg --print-architecture)"
CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu %s stable\n' \
    "$ARCHITECTURE" "$CODENAME" \
    > /etc/apt/sources.list.d/docker.list

# Install Docker Engine and Compose plugin.
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable and start Docker.
systemctl enable --now docker

# Grant Docker access to the deployment user.
usermod -aG docker "$LINUX_USER"

# Verify Docker installation.
docker info >/dev/null
docker compose version

# Determine the deployment user's home directory.
USER_HOME="$(getent passwd "$LINUX_USER" | cut -d: -f6)"

if [[ -z "$USER_HOME" || ! -d "$USER_HOME" ]]; then
    echo "Could not determine home directory for '$LINUX_USER'." >&2
    exit 1
fi

# Copy deployment files into the Linux user's home directory.
DESTINATION="$USER_HOME/zabbix-deploy-server"

mkdir -p "$DESTINATION"
cp -a "$SOURCE_DIR/." "$DESTINATION/"

# Set ownership and permissions.
USER_GROUP="$(id -gn "$LINUX_USER")"

chown -R "$LINUX_USER:$USER_GROUP" "$DESTINATION"
chmod 700 "$DESTINATION"
chmod 600 "$DESTINATION/.env"
chmod +x "$DESTINATION/run.sh"

# Start the Zabbix deployment as the Linux user.
echo "Starting the Zabbix deployment..."

runuser -u "$LINUX_USER" -- \
    bash -lc 'cd -- "$1" && exec ./run.sh' \
    bash "$DESTINATION"

echo "Docker installation and Zabbix deployment completed successfully."
