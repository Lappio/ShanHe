#!/bin/bash
# Compatible with macOS Bash 3.2. Run: bash remove-macos.command
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
no_pause=false
purge_data=false
show_help=false

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

for arg in "$@"; do
    case "$arg" in
        --no-pause) no_pause=true ;;
        --purge-data) purge_data=true ;;
        --help) show_help=true ;;
        *) fail 'Unknown argument. Use --help.' ;;
    esac
done
if [ "$show_help" = true ]; then
    echo 'Usage: bash remove-macos.command [--purge-data] [--no-pause] [--help]'
    echo 'Default: remove Shanhe containers, network and locally built service images.'
    echo '--purge-data: also permanently delete the Shanhe database volume.'
    echo 'Docker Desktop, shared base images and host software are kept.'
    exit 0
fi

echo '=== Shanhe removal / macOS ==='
[ -f docker-compose.yml ] || fail 'Keep this script in the project root with docker-compose.yml.'
command -v docker >/dev/null 2>&1 || fail 'Docker was not found. No resources were removed.'
docker compose version >/dev/null 2>&1 || fail 'Docker Compose v2 or newer is required.'
docker info >/dev/null 2>&1 || fail 'Docker is not running. Start your Docker runtime manually (Docker Desktop, OrbStack, or Colima) and run this script again.'

compose_args=(compose -p shanhe -f docker-compose.yml down --rmi local)
if [ "$purge_data" = true ]; then
    echo 'Removing project containers, network, built images AND database data...'
    compose_args+=(--volumes)
else
    echo 'Removing project containers, network and built images; keeping database data...'
fi
docker "${compose_args[@]}" || fail 'Removal did not complete. Review the Docker errors above and retry.'
echo '[OK] Removal completed.'
if [ "$purge_data" = true ]; then
    echo 'Database data was deleted. The next deployment will load fresh demo data.'
else
    echo 'Database data was kept. Use --purge-data to delete it as well.'
fi
echo 'Docker Desktop, shared base images and host software have been kept.'
