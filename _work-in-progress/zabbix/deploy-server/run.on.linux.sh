# deploy-server/linux.sh
#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
cd "$PROJECT_DIR"

echo "======================================"
echo " ZABBIX DEPLOYMENT"

command -v docker >/dev/null 2>&1 || {
    echo "Docker is not installed."
    echo "Install Docker Engine and Compose plugin first."
    exit 1
}

docker compose version >/dev/null 2>&1 || {
    echo "Docker Compose v2 is required."
    exit 1
}

docker info >/dev/null 2>&1 || {
    echo "Docker daemon is unavailable or access is denied."
    echo "Start Docker or configure your permissions."
    exit 1
}

if [[ ! -f .env ]]; then
    echo "Generating environment configuration..."

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

echo "Waiting for PostgreSQL..."

POSTGRES_READY=false

for i in $(seq 1 60); do
    if docker compose exec -T postgres sh -c \
        'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' \
        >/dev/null 2>&1; then
        POSTGRES_READY=true
        break
    fi

    sleep 5
done

if [[ "$POSTGRES_READY" != true ]]; then
    echo "ERROR: PostgreSQL did not become ready."
    docker compose logs postgres
    exit 1
fi

echo "PostgreSQL is ready."

echo
echo "Running initial Zabbix configuration..."
docker compose run --rm configure

echo "======================================"
echo " DEPLOYMENT COMPLETED"
echo "Web UI: http://localhost:8080"
echo "Remote URL: http://SERVER-IP:8080"
echo "Zabbix Server: SERVER-IP:10051"
echo
echo "Check status:"
echo "docker compose ps"
echo
echo "View logs:"
echo "docker compose logs -f"
