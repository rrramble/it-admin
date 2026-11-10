# deploy-server/macos.sh
#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
cd "$PROJECT_DIR"

command -v docker >/dev/null 2>&1 || {
    echo "Docker Desktop is required."
    exit 1
}

docker compose version >/dev/null 2>&1 || {
    echo "Docker Compose v2 is required."
    exit 1
}

docker info >/dev/null 2>&1 || {
    echo "Docker Desktop is not running."
    exit 1
}

if [[ ! -f .env ]]; then
    DB_PASSWORD="$(openssl rand -hex 32)"
    sed "s/REPLACE_WITH_RANDOM_PASSWORD/$DB_PASSWORD/" \
        .env.example > .env
    chmod 600 .env
fi

mkdir -p backups

echo "Pulling external container images..."
docker compose pull --ignore-buildable

echo "Building custom Zabbix Server image..."
docker compose build zabbix-server

echo "Starting Zabbix..."
docker compose up -d

docker compose run --rm configure

echo "Zabbix deployment completed."
echo "Open http://localhost:8080"
