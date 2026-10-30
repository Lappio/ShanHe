#!/bin/bash
# Stop the native Shanhe processes. Compatible with macOS Bash 3.2.
# Run: bash remove-local-macos.command
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
export SHANHE_DB_HOST="${SHANHE_DB_HOST:-127.0.0.1}"
export SHANHE_DB_PORT="${SHANHE_DB_PORT:-3306}"
no_pause=false
purge_data=false
show_help=false
runtime=".shanhe-local"

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
    echo 'Usage: bash remove-local-macos.command [--purge-data] [--no-pause] [--help]'
    echo 'Default: stop the native backend and frontend, and delete build output.'
    echo 'Build output is backend/target, frontend/dist and .shanhe-local/.'
    echo '--purge-data: also drop the shanhe database. The MySQL server itself is kept.'
    echo 'JDK, Maven, Node.js, MySQL and Homebrew are never uninstalled.'
    exit 0
fi

can_connect() {
    mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names \
        -h "$SHANHE_DB_HOST" -P "$SHANHE_DB_PORT" \
        -u "$1" "--password=${2}" -e "SELECT 1" >/dev/null 2>&1
}

stop_pid_file() {
    local file="$1" needle="$2" pid cmd i
    [ -f "$file" ] || return 0
    pid=$(tr -cd '0-9' < "$file")
    [ -n "$pid" ] || return 0
    cmd=$(ps -p "$pid" -o args= 2>/dev/null || true)
    case "$cmd" in
        *"$needle"*) ;;
        *)
            echo "PID ${pid} is not a Shanhe process. It was left running."
            return 0
            ;;
    esac
    echo "Stopping ${needle} (pid ${pid})..."
    kill "$pid" 2>/dev/null || true
    i=0
    while kill -0 "$pid" 2>/dev/null && [ "$i" -lt 10 ]; do
        sleep 1
        i=$((i + 1))
    done
    if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null || true
    fi
}

echo '=== Shanhe local removal / macOS ==='
[ -f sql/schema.sql ] && [ -f backend/pom.xml ] || fail 'Keep this script in the project root.'

stop_pid_file "$runtime/backend.pid" shanhe-portal.jar
stop_pid_file "$runtime/frontend.pid" local-frontend.mjs

if [ "$purge_data" = true ]; then
    [[ "$SHANHE_DB_HOST" =~ ^[A-Za-z0-9._-]+$ ]] || fail 'Invalid SHANHE_DB_HOST. Processes were already stopped.'
    [[ "$SHANHE_DB_PORT" =~ ^[0-9]{1,5}$ ]] || fail 'Invalid SHANHE_DB_PORT. Processes were already stopped.'
    command -v mysql >/dev/null 2>&1 || fail 'The mysql client is not on PATH. Processes were stopped, but the shanhe database was not dropped.'
    if [ "${SHANHE_DB_USER+x}" != x ]; then
        if can_connect root ""; then
            SHANHE_DB_USER=root
            SHANHE_DB_PASSWORD=""
        elif can_connect shanhe shanhe123; then
            SHANHE_DB_USER=shanhe
            SHANHE_DB_PASSWORD=shanhe123
        elif [ "$no_pause" = false ] && [ -t 0 ]; then
            read -r -p 'MySQL user [root]: ' SHANHE_DB_USER
            SHANHE_DB_USER=${SHANHE_DB_USER:-root}
            read -r -s -p 'MySQL password: ' SHANHE_DB_PASSWORD
            echo
            SHANHE_DB_PASSWORD=${SHANHE_DB_PASSWORD:-}
        else
            fail 'Set SHANHE_DB_USER and SHANHE_DB_PASSWORD to drop the database. Processes were stopped, but the database was kept.'
        fi
    fi
    SHANHE_DB_PASSWORD="${SHANHE_DB_PASSWORD:-}"
    can_connect "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" || fail "Cannot connect as ${SHANHE_DB_USER}. The shanhe database was not dropped."
    existing=$(mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names \
        -h "$SHANHE_DB_HOST" -P "$SHANHE_DB_PORT" \
        -u "$SHANHE_DB_USER" "--password=${SHANHE_DB_PASSWORD}" \
        -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='shanhe'" 2>/dev/null || true)
    if [ "$existing" = "shanhe" ]; then
        mysql --protocol=TCP --connect-timeout=8 --batch \
            -h "$SHANHE_DB_HOST" -P "$SHANHE_DB_PORT" \
            -u "$SHANHE_DB_USER" "--password=${SHANHE_DB_PASSWORD}" \
            -e "DROP DATABASE shanhe" || fail 'DROP DATABASE shanhe failed. The MySQL server was not uninstalled.'
        echo 'Database shanhe was deleted.'
    else
        echo 'Database shanhe was not present.'
    fi
else
    echo 'Database shanhe was kept. Use --purge-data to drop it.'
fi

if [ -f "$runtime/installed-by-script.txt" ]; then
    echo 'These packages were installed by deploy-local and were kept:'
    cat "$runtime/installed-by-script.txt"
else
    echo 'No record of packages installed by deploy-local.'
fi
echo 'JDK, Maven, Node.js, MySQL and Homebrew were not uninstalled.'

echo 'Removing backend/target, frontend/dist and .shanhe-local...'
rm -rf backend/target frontend/dist "$runtime"
echo '[OK] Local removal completed.'
echo 'node_modules was kept so the next build can reuse it.'
