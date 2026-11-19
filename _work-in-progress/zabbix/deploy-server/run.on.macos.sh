#!/usr/bin/env bash
# File: deploy-server/run.on.macos.sh

set -Eeuo pipefail
umask 077

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$PROJECT_DIR/Docker-compose.yaml"
ENV_FILE="$PROJECT_DIR/.env"


log() {
    printf '[INFO] %s\n' "$*"
}


fail() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}


dc() {
    docker compose -f "$COMPOSE_FILE" "$@"
}


check_env_variable() {
    local key="$1"

    if ! awk -v key="$key" '
        $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
            count++
            value = $0
            sub(/^[^=]*=/, "", value)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            if (value == "" || value ~ /^#/) {
                invalid = 1
            }
        }
        END { exit !(count == 1 && !invalid) }
    ' "$ENV_FILE"; then
        fail "Variable '$key' must be defined exactly once and have a non-empty value in .env."
    fi
}


check_prerequisites() {
    command -v docker >/dev/null 2>&1 || fail "Docker CLI is not installed or is not in PATH. Install Docker Desktop."
    command -v curl >/dev/null 2>&1 || fail "curl is required but was not found."
    command -v awk >/dev/null 2>&1 || fail "awk is required but was not found."

    docker compose version >/dev/null 2>&1 || fail "Docker Compose v2 is required."
    docker info >/dev/null 2>&1 || fail "Docker Desktop is not running. Start Docker Desktop and retry."

    [[ -f "$COMPOSE_FILE" ]] || fail "Compose file not found: $COMPOSE_FILE"
    [[ ! -L "$COMPOSE_FILE" ]] || fail "Compose file must not be a symbolic link."
}


check_env_file() {
    [[ -e "$ENV_FILE" ]] || fail ".env was not found."
    [[ ! -L "$ENV_FILE" ]] || fail ".env must not be a symbolic link."
    [[ -f "$ENV_FILE" ]] || fail ".env exists but is not a regular file."

    local owner mode current_uid
    owner="$(stat -f '%u' "$ENV_FILE")" || fail "Cannot determine .env file owner."
    mode="$(stat -f '%Lp' "$ENV_FILE")" || fail "Cannot determine .env file permissions."
    current_uid="$(id -u)"

    [[ "$owner" == "$current_uid" ]] || fail ".env must be owned by the current user (owner UID: $owner; current UID: $current_uid)."
    [[ "$mode" =~ ^[0-7]{3,4}$ ]] || fail "Cannot interpret .env permissions: $mode"
    (( (8#$mode & 077) == 0 )) || fail ".env permissions are too open ($mode). Set them to 600 with: chmod 600 .env"

    local required_vars=(
        POSTGRES_VERSION
        POSTGRES_DB
        POSTGRES_USER
        POSTGRES_PASSWORD
        ZABBIX_VERSION
        PHP_TIMEZONE
    )

    local env_key
    for env_key in "${required_vars[@]}"; do
        check_env_variable "$env_key"
    done
}


validate_compose() {
    log "Validating Docker Compose configuration..."
    dc config --quiet || fail "Docker Compose configuration is invalid. Review .env and Docker-compose.yaml."
}


wait_for_zabbix_api() {
    local zabbix_api_url response attempt
    local payload='{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}'

    log "Waiting for Zabbix API..."
    for ((attempt = 1; attempt <= 60; attempt++)); do
        zabbix_api_url="$(dc port zabbix-web 8080 2>/dev/null || true)"
        if [[ -n "$zabbix_api_url" ]] \
            && response="$(curl --silent --show-error --fail --max-time 5 \
                -H 'Content-Type: application/json-rpc' \
                --data-binary "$payload" \
                "http://${zabbix_api_url}/api_jsonrpc.php" 2>/dev/null)" \
            && grep -q '"result"' <<< "$response"; then
            log "Zabbix API is responding."
            return 0
        fi
        sleep 5
    done

    fail "Zabbix API did not become ready within several minutes. Check logs with: docker compose -f Docker-compose.yaml logs --tail=100"
}


main() {
    local force_reinstall=false
    if [[ "$#" -eq 2 && "$1" == "install" && "$2" == "--force" ]]; then
        force_reinstall=true
    elif [[ "$#" -gt 1 ]] || { [[ "$#" -eq 1 ]] && [[ "$1" != "install" ]]; }; then
        printf 'Usage: %s [install [--force]]\n' "$(basename "$0")" >&2
        exit 2
    fi

    check_prerequisites
    check_env_file
    validate_compose

    local existing_containers
    existing_containers="$(dc ps -a -q)"
    if [[ -n "$existing_containers" && "$force_reinstall" != true ]]; then
        fail "Zabbix containers already exist. To intentionally pull/build images and reconcile the existing stack, rerun with: $0 install --force"
    fi

    log "Pulling external container images..."
    dc pull --ignore-buildable

    log "Building the custom Zabbix Server image..."
    dc build zabbix-server

    log "Starting Zabbix containers..."
    dc up -d --no-build

    wait_for_zabbix_api
    zabbix_url_api="$(dc port zabbix-web 8080)"

    printf '\n======================================\n'
    printf ' ZABBIX INSTALLATION COMPLETED\n'
    printf '======================================\n'
    printf 'Web interface: http://%s\n' "$zabbix_url_api"
    printf '\nContainers are configured with restart: unless-stopped.\n'
    printf 'Docker Desktop itself must be started after macOS login for containers to restart.\n'
    printf 'Initial Zabbix account configuration is an operational task and was not performed.\n'
    printf '======================================\n'
}

main "$@"
