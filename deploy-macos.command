#!/bin/bash
# Compatible with the Bash 3.2 shipped with macOS. Run: bash deploy-macos.command
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
export SHANHE_MYSQL_PORT="${SHANHE_MYSQL_PORT:-13306}"
export SHANHE_BACKEND_PORT="${SHANHE_BACKEND_PORT:-8088}"
export SHANHE_FRONTEND_PORT="${SHANHE_FRONTEND_PORT:-43123}"
export SHANHE_WAIT_SECONDS="${SHANHE_WAIT_SECONDS:-180}"
# Remember this before any function calls exit. Bash clears positional
# parameters for an EXIT trap that runs from a function, so reading "$1"
# inside the trap would ignore --no-pause after a failure.
no_pause=false
if [ "${1:-}" = "--no-pause" ]; then
    no_pause=true
fi

finish() {
    local result=$?
    trap - EXIT
    if [ "$no_pause" = false ] && [ -t 0 ]; then
        read -r -p 'Press Enter to close...' _ || true
    fi
    exit "$result"
}
trap finish EXIT

fail() { printf '\n[ERROR] %s\n' "$*" >&2; exit 1; }
diagnostics() {
    echo '[ERROR] Deployment failed. Existing database volumes have been kept.' >&2
    echo 'If a port is occupied, set SHANHE_MYSQL_PORT, SHANHE_BACKEND_PORT or SHANHE_FRONTEND_PORT and retry.' >&2
    docker compose -p shanhe -f docker-compose.yml ps || true
    docker compose -p shanhe -f docker-compose.yml logs --tail 60 || true
    exit 1
}

echo '=== Shanhe deployment / macOS ==='
[ -f docker-compose.yml ] || fail 'Keep this script in the project root with docker-compose.yml.'
command -v docker >/dev/null 2>&1 || fail 'Install and open Docker Desktop: https://www.docker.com/products/docker-desktop/'
command -v curl >/dev/null 2>&1 || fail 'curl is required to check the application.'
docker compose version >/dev/null 2>&1 || fail 'Docker Compose v2 or newer is required. Update Docker Desktop.'
for name in SHANHE_MYSQL_PORT SHANHE_BACKEND_PORT SHANHE_FRONTEND_PORT; do
    value="${!name}"
    [[ "$value" =~ ^[0-9]{1,5}$ ]] || fail "Invalid port: $name"
    (( 10#$value >= 1 && 10#$value <= 65535 )) || fail "Invalid port: $name"
done
[[ "$SHANHE_WAIT_SECONDS" =~ ^[0-9]{1,6}$ ]] || fail 'Invalid SHANHE_WAIT_SECONDS'
(( 10#$SHANHE_WAIT_SECONDS >= 1 )) || fail 'Invalid SHANHE_WAIT_SECONDS'

if ! docker info >/dev/null 2>&1; then
    echo 'Starting Docker Desktop; waiting up to 120 seconds...'
    if open -g -a Docker; then
        deadline=$((SECONDS + 120))
        until docker info >/dev/null 2>&1; do
            (( SECONDS < deadline )) || fail 'Docker is unavailable. Start your Docker runtime manually (Docker Desktop, OrbStack, or Colima) and run this script again.'
            sleep 2
        done
    else
        fail 'Docker is not running, and Docker Desktop was not found. Start your Docker runtime manually (OrbStack or Colima also work) and run this script again.'
    fi
fi

docker compose -p shanhe -f docker-compose.yml config --quiet
echo 'Building images and starting services. The first run needs Internet access.'
docker compose -p shanhe -f docker-compose.yml up --build --detach --wait --wait-timeout "$SHANHE_WAIT_SECONDS" || diagnostics
echo 'Checking the frontend, backend and database...'
deadline=$((SECONDS + 10#$SHANHE_WAIT_SECONDS))
ready=false
while (( SECONDS < deadline )); do
    response=$(curl --noproxy '*' --fail --silent --max-time 5 "http://127.0.0.1:${SHANHE_FRONTEND_PORT}/api/home") || response=''
    if [[ "$response" =~ \"code\"[[:space:]]*:[[:space:]]*0[[:space:]]*[,}] ]] &&
       [[ "$response" =~ \"data\"[[:space:]]*:[[:space:]]*\{ ]]; then
        ready=true
        break
    fi
    sleep 2
done
[ "$ready" = true ] || diagnostics

printf '\n[OK] Deployment completed.\nWebsite: http://127.0.0.1:%s\nAdmin:   http://127.0.0.1:%s/admin\n' "$SHANHE_FRONTEND_PORT" "$SHANHE_FRONTEND_PORT"
echo 'Admin login: admin / admin123'
echo 'User login:  linwan / user123'
echo 'Stop: docker compose -p shanhe -f docker-compose.yml stop'
echo 'Logs: docker compose -p shanhe -f docker-compose.yml logs -f'
