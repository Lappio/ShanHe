#!/bin/bash
# Native deploy (no Docker). Compatible with macOS Bash 3.2.
# Run: bash deploy-local-macos.command
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
export SHANHE_BACKEND_PORT="${SHANHE_BACKEND_PORT:-8088}"
export SHANHE_FRONTEND_PORT="${SHANHE_FRONTEND_PORT:-43123}"
export SHANHE_DB_HOST="${SHANHE_DB_HOST:-127.0.0.1}"
export SHANHE_DB_PORT="${SHANHE_DB_PORT:-3306}"
export SHANHE_WAIT_SECONDS="${SHANHE_WAIT_SECONDS:-180}"
# SHANHE_DB_USER and SHANHE_DB_PASSWORD are optional. When they are unset the
# script tries root with an empty password, then shanhe/shanhe123.
no_pause=false
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
        --help) show_help=true ;;
        *) fail 'Unknown argument. Use --help.' ;;
    esac
done
if [ "$show_help" = true ]; then
    echo 'Usage: bash deploy-local-macos.command [--no-pause] [--help]'
    echo 'Build and start Shanhe on this machine. Docker is not used.'
    echo 'Missing JDK 17, Maven, Node.js or MySQL 8 are installed with Homebrew.'
    echo 'An already running MySQL is reused and is not reinstalled.'
    echo 'Credentials: SHANHE_DB_HOST, SHANHE_DB_PORT, SHANHE_DB_USER, SHANHE_DB_PASSWORD.'
    echo 'Ports: SHANHE_BACKEND_PORT (default 8088), SHANHE_FRONTEND_PORT (default 43123), SHANHE_DB_PORT (default 3306).'
    echo 'SHANHE_MYSQL_PORT is the Docker host port and is not used by this script.'
    exit 0
fi

version_ge() {
    awk -v have="$1" -v need="$2" 'BEGIN {
        n = split(have, H, ".")
        m = split(need, N, ".")
        max = n
        if (m > max) max = m
        for (i = 1; i <= max; i++) {
            hv = H[i] + 0
            nv = N[i] + 0
            if (hv > nv) exit 0
            if (hv < nv) exit 1
        }
        exit 0
    }'
}

first_line() {
    printf '%s\n' "$1" | awk 'NR==1 { print; exit }'
}

strip_ansi() {
    # Maven on some systems colors its version line even when stdout is not a terminal.
    printf '%s\n' "$1" | sed "s/$(printf '\033')\\[[0-9;]*[A-Za-z]//g"
}

java_major() {
    local text line major
    text=$(java -version 2>&1 || true)
    line=$(first_line "$(strip_ansi "$text")")
    major=$(printf '%s\n' "$line" | sed -n 's/.*version "\([0-9][0-9]*\).*/\1/p')
    if [ "$major" = "1" ]; then
        major=$(printf '%s\n' "$line" | sed -n 's/.*version "1\.\([0-9][0-9]*\).*/\1/p')
    fi
    printf '%s\n' "$major"
}

tool_version() {
    printf '%s\n' "$1" | sed -n 's/[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\(\.[0-9][0-9]*\)\{0,1\}\).*/\1/p'
}

port_listening() {
    (echo >/dev/tcp/127.0.0.1/"$1") >/dev/null 2>&1
}

need_brew() {
    command -v brew >/dev/null 2>&1 || fail 'Homebrew is required to install missing tools. Install it from https://brew.sh and run this script again. Already installed tools were left unchanged.'
}

record_installed() {
    mkdir -p "$runtime"
    if [ -f "$runtime/installed-by-script.txt" ] && grep -qx "$1" "$runtime/installed-by-script.txt"; then
        return 0
    fi
    printf '%s\n' "$1" >> "$runtime/installed-by-script.txt"
}

add_openjdk_path() {
    local prefix
    for prefix in /opt/homebrew/opt/openjdk@17 /usr/local/opt/openjdk@17; do
        if [ -x "$prefix/bin/java" ]; then
            export PATH="$prefix/bin:$PATH"
        fi
        if [ -d "$prefix/libexec/openjdk.jdk/Contents/Home" ]; then
            export JAVA_HOME="$prefix/libexec/openjdk.jdk/Contents/Home"
            export PATH="$JAVA_HOME/bin:$PATH"
        fi
    done
}

mysql_cmd() {
    local user="$1" password="$2"
    shift 2
    mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names \
        --default-character-set=utf8mb4 \
        -h "$SHANHE_DB_HOST" -P "$SHANHE_DB_PORT" \
        -u "$user" "--password=${password}" "$@"
}

can_connect() {
    mysql_cmd "$1" "$2" -e "SELECT 1" >/dev/null 2>&1
}

stop_pid_file() {
    local file="$1" needle="$2" pid cmd i
    [ -f "$file" ] || return 0
    pid=$(tr -cd '0-9' < "$file")
    [ -n "$pid" ] || return 0
    cmd=$(ps -p "$pid" -o args= 2>/dev/null || true)
    case "$cmd" in
        *"$needle"*) ;;
        *) return 0 ;;
    esac
    kill "$pid" 2>/dev/null || true
    i=0
    while kill -0 "$pid" 2>/dev/null && [ "$i" -lt 10 ]; do
        sleep 1
        i=$((i + 1))
    done
    if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null || true
    fi
    rm -f "$file"
}

echo '=== Shanhe local deployment / macOS ==='
[ -f sql/schema.sql ] && [ -f sql/data.sql ] && [ -f backend/pom.xml ] || fail 'Keep this script in the project root.'
command -v curl >/dev/null 2>&1 || fail 'curl is required to check the application.'
[[ "$SHANHE_DB_HOST" =~ ^[A-Za-z0-9._-]+$ ]] || fail 'Invalid SHANHE_DB_HOST'
for name in SHANHE_BACKEND_PORT SHANHE_FRONTEND_PORT SHANHE_DB_PORT; do
    value="${!name}"
    [[ "$value" =~ ^[0-9]{1,5}$ ]] || fail "Invalid port: $name"
    (( 10#$value >= 1 && 10#$value <= 65535 )) || fail "Invalid port: $name"
done
[[ "$SHANHE_WAIT_SECONDS" =~ ^[0-9]{1,6}$ ]] || fail 'Invalid SHANHE_WAIT_SECONDS'
(( 10#$SHANHE_WAIT_SECONDS >= 1 )) || fail 'Invalid SHANHE_WAIT_SECONDS'

add_openjdk_path
if command -v java >/dev/null 2>&1; then
    java_found=$(java_major || true)
    if [ -n "$java_found" ] && [ "$java_found" -ge 17 ]; then
        echo "Java $java_found is already installed."
    else
        fail "Java ${java_found:-unknown} is older than 17. Put JDK 17 or newer on PATH. This script will not replace the existing Java."
    fi
else
    need_brew
    echo 'Installing OpenJDK 17...'
    NONINTERACTIVE=1 brew install openjdk@17
    record_installed openjdk@17
    add_openjdk_path
    command -v java >/dev/null 2>&1 || fail 'OpenJDK 17 was installed, but java is still not on PATH.'
fi

if command -v mvn >/dev/null 2>&1; then
    maven_text=$(mvn -version 2>&1 || true)
    maven_found=$(tool_version "$(first_line "$(strip_ansi "$maven_text")")")
    version_ge "$maven_found" "3.8.0" || fail "Maven ${maven_found:-unknown} is older than 3.8. This script will not replace it."
    echo "Maven $maven_found is already installed."
else
    need_brew
    echo 'Installing Maven...'
    NONINTERACTIVE=1 brew install maven
    record_installed maven
    command -v mvn >/dev/null 2>&1 || fail 'Maven was installed, but mvn is still not on PATH.'
fi

if command -v node >/dev/null 2>&1; then
    node_text=$(node -v 2>&1 || true)
    node_found=$(tool_version "$(strip_ansi "$node_text")")
    version_ge "$node_found" "20.0.0" || fail "Node.js ${node_found:-unknown} is older than 20. This script will not replace it."
    echo "Node.js $node_found is already installed."
else
    need_brew
    echo 'Installing Node.js...'
    NONINTERACTIVE=1 brew install node
    record_installed node
    command -v node >/dev/null 2>&1 || fail 'Node.js was installed, but node is still not on PATH.'
fi

if [ "$SHANHE_DB_HOST" = "127.0.0.1" ] || [ "$SHANHE_DB_HOST" = "localhost" ]; then
    if port_listening "$SHANHE_DB_PORT"; then
        echo "MySQL is already listening on ${SHANHE_DB_HOST}:${SHANHE_DB_PORT}. It will be reused and not reinstalled."
    else
        echo "MySQL is not listening on port ${SHANHE_DB_PORT}."
        if command -v mysqld >/dev/null 2>&1 || command -v mysql.server >/dev/null 2>&1 || { command -v brew >/dev/null 2>&1 && brew list mysql >/dev/null 2>&1; }; then
            echo 'Starting the existing MySQL server...'
            if command -v brew >/dev/null 2>&1 && brew list mysql >/dev/null 2>&1; then
                brew services start mysql || true
            fi
            if command -v mysql.server >/dev/null 2>&1; then
                mysql.server start || true
            fi
            if command -v service >/dev/null 2>&1; then
                service mysql start || true
            fi
        elif command -v brew >/dev/null 2>&1; then
            echo 'Installing MySQL 8 with Homebrew...'
            NONINTERACTIVE=1 brew install mysql
            record_installed mysql
            brew services start mysql || mysql.server start || true
        else
            fail "MySQL is not running and Homebrew is not available. Start MySQL 8 on ${SHANHE_DB_HOST}:${SHANHE_DB_PORT}. This script will not install a second copy without Homebrew."
        fi
        deadline=$((SECONDS + 60))
        while ! port_listening "$SHANHE_DB_PORT"; do
            (( SECONDS < deadline )) || fail "MySQL did not start on port ${SHANHE_DB_PORT}. Start it manually. No database was changed."
            sleep 2
        done
    fi
else
    echo "Using MySQL at ${SHANHE_DB_HOST}:${SHANHE_DB_PORT}. No local server will be installed or started."
fi

if ! command -v mysql >/dev/null 2>&1; then
    need_brew
    echo 'Installing the MySQL client...'
    NONINTERACTIVE=1 brew install mysql-client
    record_installed mysql-client
    client_prefix=$(brew --prefix mysql-client 2>/dev/null || true)
    if [ -n "$client_prefix" ] && [ -d "$client_prefix/bin" ]; then
        export PATH="$client_prefix/bin:$PATH"
    fi
    command -v mysql >/dev/null 2>&1 || fail 'The mysql client is still not on PATH.'
fi

if [ "${SHANHE_DB_USER+x}" = x ]; then
    SHANHE_DB_PASSWORD="${SHANHE_DB_PASSWORD:-}"
    can_connect "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" || fail "Cannot connect to MySQL at ${SHANHE_DB_HOST}:${SHANHE_DB_PORT} as ${SHANHE_DB_USER}. Check SHANHE_DB_PASSWORD. Existing data was not modified."
else
    if can_connect root ""; then
        SHANHE_DB_USER=root
        SHANHE_DB_PASSWORD=""
    elif can_connect shanhe shanhe123; then
        SHANHE_DB_USER=shanhe
        SHANHE_DB_PASSWORD=shanhe123
    elif [ "$no_pause" = false ] && [ -t 0 ]; then
        printf 'MySQL is running at %s:%s. Enter an account that can create databases.\n' "$SHANHE_DB_HOST" "$SHANHE_DB_PORT"
        read -r -p 'MySQL user [root]: ' SHANHE_DB_USER
        SHANHE_DB_USER=${SHANHE_DB_USER:-root}
        read -r -s -p 'MySQL password: ' SHANHE_DB_PASSWORD
        echo
        SHANHE_DB_PASSWORD=${SHANHE_DB_PASSWORD:-}
        can_connect "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" || fail "Cannot connect as ${SHANHE_DB_USER}. Existing data was not modified."
    else
        fail "MySQL is running at ${SHANHE_DB_HOST}:${SHANHE_DB_PORT}, but login failed. Set SHANHE_DB_USER and SHANHE_DB_PASSWORD. Existing data was not modified."
    fi
fi
echo "Connected to MySQL as ${SHANHE_DB_USER}."

server_version=$(mysql_cmd "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" -e "SELECT VERSION()" 2>/dev/null || true)
case "$server_version" in
    *MariaDB*|*mariadb*) fail "The server at ${SHANHE_DB_HOST}:${SHANHE_DB_PORT} is MariaDB (${server_version}). MySQL 8 is required. It was not modified." ;;
esac
server_major=${server_version%%.*}
[[ "$server_major" =~ ^[0-9]+$ ]] || fail "Could not read the MySQL version from '${server_version}'."
[ "$server_major" -ge 8 ] || fail "MySQL 8 or newer is required. This server reports ${server_version}. It was not upgraded or replaced."

db_name=$(mysql_cmd "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='shanhe'" 2>/dev/null || true)
if [ "$db_name" = "shanhe" ]; then
    echo 'Database shanhe already exists. Tables and data were left unchanged.'
else
    echo 'Database shanhe does not exist. Loading sql/schema.sql and sql/data.sql...'
    load_ok=true
    mysql --protocol=TCP --connect-timeout=8 --default-character-set=utf8mb4 \
        --init-command="SET time_zone='+08:00'" \
        -h "$SHANHE_DB_HOST" -P "$SHANHE_DB_PORT" \
        -u "$SHANHE_DB_USER" "--password=${SHANHE_DB_PASSWORD}" < sql/schema.sql || load_ok=false
    if [ "$load_ok" = true ]; then
        mysql --protocol=TCP --connect-timeout=8 --default-character-set=utf8mb4 \
            --init-command="SET time_zone='+08:00'" \
            -h "$SHANHE_DB_HOST" -P "$SHANHE_DB_PORT" \
            -u "$SHANHE_DB_USER" "--password=${SHANHE_DB_PASSWORD}" < sql/data.sql || load_ok=false
    fi
    spot_count=""
    if [ "$load_ok" = true ]; then
        spot_count=$(mysql_cmd "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" -D shanhe -e "SELECT COUNT(*) FROM scenic_spot" 2>/dev/null || true)
    fi
    if [ "$load_ok" != true ] || [ -z "$spot_count" ] || [ "$spot_count" -lt 1 ]; then
        echo 'Load failed. Dropping the incomplete shanhe database so the next run can retry.' >&2
        mysql_cmd "$SHANHE_DB_USER" "$SHANHE_DB_PASSWORD" -e "DROP DATABASE IF EXISTS shanhe" >/dev/null 2>&1 || true
        fail 'Could not load sql/schema.sql and sql/data.sql. Use an account that can CREATE DATABASE, often root.'
    fi
    echo "Loaded demo data (${spot_count} scenic spots)."
fi

if can_connect shanhe shanhe123; then
    APP_DB_USER=shanhe
    APP_DB_PASSWORD=shanhe123
else
    APP_DB_USER=$SHANHE_DB_USER
    APP_DB_PASSWORD=$SHANHE_DB_PASSWORD
    echo "The shanhe database user is not available. The backend will use ${APP_DB_USER}."
fi

echo 'Building the backend...'
( cd backend && mvn -DskipTests package ) || fail 'Backend build failed. MySQL data was not deleted.'
echo 'Building the frontend...'
( cd frontend && npm ci && npm run build ) || fail 'Frontend build failed. MySQL data was not deleted.'

stop_pid_file "$runtime/backend.pid" shanhe-portal.jar
stop_pid_file "$runtime/frontend.pid" local-frontend.mjs
if port_listening "$SHANHE_BACKEND_PORT"; then
    fail "Port ${SHANHE_BACKEND_PORT} is already in use. Set SHANHE_BACKEND_PORT or stop the other program."
fi
if port_listening "$SHANHE_FRONTEND_PORT"; then
    fail "Port ${SHANHE_FRONTEND_PORT} is already in use. Set SHANHE_FRONTEND_PORT or stop the other program."
fi

mkdir -p "$runtime"
export SERVER_PORT="$SHANHE_BACKEND_PORT"
export SPRING_DATASOURCE_URL="jdbc:mysql://${SHANHE_DB_HOST}:${SHANHE_DB_PORT}/shanhe?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true"
export SPRING_DATASOURCE_USERNAME="$APP_DB_USER"
export SPRING_DATASOURCE_PASSWORD="$APP_DB_PASSWORD"
unset MYSQL_PWD || true
echo 'Starting the backend and frontend...'
nohup java -jar backend/target/shanhe-portal.jar > "$runtime/backend.log" 2>&1 &
echo $! > "$runtime/backend.pid"
export SHANHE_DIST="$PWD/frontend/dist"
export SHANHE_BACKEND_HOST=127.0.0.1
nohup node scripts/local-frontend.mjs > "$runtime/frontend.log" 2>&1 &
echo $! > "$runtime/frontend.pid"

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
if [ "$ready" != true ]; then
    echo '[ERROR] The site did not become ready. MySQL data was not deleted.' >&2
    echo "Logs: ${runtime}/backend.log and ${runtime}/frontend.log" >&2
    tail -n 40 "$runtime/backend.log" >&2 || true
    tail -n 20 "$runtime/frontend.log" >&2 || true
    exit 1
fi

printf '\n[OK] Local deployment completed.\nWebsite: http://127.0.0.1:%s\nAdmin:   http://127.0.0.1:%s/admin\n' "$SHANHE_FRONTEND_PORT" "$SHANHE_FRONTEND_PORT"
echo 'Admin login: admin / admin123'
echo 'User login:  linwan / user123'
echo "Stop: bash remove-local-macos.command"
echo "Logs: tail -f ${runtime}/backend.log ${runtime}/frontend.log"
if [ -f "$runtime/installed-by-script.txt" ]; then
    echo 'Installed by this script and kept on disk:'
    cat "$runtime/installed-by-script.txt"
else
    echo 'No packages were installed. Existing JDK, Maven, Node.js, MySQL and Homebrew were reused.'
fi
echo 'remove-local does not uninstall JDK, Maven, Node.js, MySQL or Homebrew.'
echo 'Database shanhe is kept unless remove-local is run with --purge-data.'
