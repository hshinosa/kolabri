#!/usr/bin/env bash
# Kolabri local-native dev helper
# Usage: ./dev.sh {start|stop|restart|status|logs|smoke}

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGDIR="$ROOT/.dev-logs"
PIDDIR="$ROOT/.dev-pids"
mkdir -p "$LOGDIR" "$PIDDIR"

CORE_API_DIR="$ROOT/Kolabri-core-api"
AI_ENGINE_DIR="$ROOT/Kolabri-ai-engine"
CLIENT_APP_DIR="$ROOT/Kolabri-client-app"

CORE_PORT=3000
AI_PORT=8001
CLIENT_PORT=8000

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

log_ok()    { printf "${GREEN}✓${RESET} %s\n" "$1"; }
log_fail()  { printf "${RED}✗${RESET} %s\n" "$1"; }
log_warn()  { printf "${YELLOW}!${RESET} %s\n" "$1"; }

# ----- infra (homebrew services) -----

infra_status() {
    local services=(postgresql@17 mongodb-community@8.0 redis)
    local ok=1
    for svc in "${services[@]}"; do
        local state
        state=$(brew services list 2>/dev/null | awk -v s="$svc" '$1==s {print $2}')
        if [[ "$state" == "started" ]]; then
            log_ok "$svc"
        else
            log_fail "$svc ($state)"
            ok=0
        fi
    done

    # Qdrant: runs via Docker (Colima or Docker Desktop)
    if curl -sf -m 1 http://localhost:6333/healthz >/dev/null 2>&1; then
        log_ok "qdrant"
    else
        log_warn "qdrant (not responding on :6333)"
    fi

    return $((1 - ok))
}

docker_socket() {
    if [[ -S "$HOME/.colima/default/docker.sock" ]]; then
        echo "unix://$HOME/.colima/default/docker.sock"
    elif [[ -S "/var/run/docker.sock" ]]; then
        echo "unix:///var/run/docker.sock"
    fi
}

start_qdrant() {
    if curl -sf -m 1 http://localhost:6333/healthz >/dev/null 2>&1; then
        log_ok "qdrant already running"
        return 0
    fi
    local sock
    sock=$(docker_socket)
    if [[ -z "$sock" ]]; then
        log_warn "qdrant: no Docker socket found (install Colima or Docker Desktop)"
        return 1
    fi
    DOCKER_HOST="$sock" docker start qdrant-local >/dev/null 2>&1 || {
        log_warn "qdrant: container not found, creating..."
        DOCKER_HOST="$sock" docker run -d --name qdrant-local -p 6333:6333 -v qdrant_storage:/qdrant/storage qdrant/qdrant:latest >/dev/null 2>&1
    }
    sleep 3
    if curl -sf -m 2 http://localhost:6333/healthz >/dev/null 2>&1; then
        log_ok "qdrant started on :6333"
    else
        log_fail "qdrant failed to start"
        return 1
    fi
}

infra_start() {
    brew services start postgresql@17 >/dev/null 2>&1 || true
    brew services start mongodb-community@8.0 >/dev/null 2>&1 || true
    brew services start redis >/dev/null 2>&1 || true
    sleep 2
    log_ok "infra services started (postgres, mongo, redis)"
    start_qdrant
}

# ----- app processes -----

is_running() {
    local pid_file="$1"
    [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null
}

# Kill any process listening on the given port. Used as pre-flight before
# starting an app, to recover from zombie processes whose PID files were lost.
ensure_port_free() {
    local port="$1"
    local label="$2"
    local pids
    pids=$(lsof -ti TCP:"$port" -sTCP:LISTEN 2>/dev/null)
    if [[ -n "$pids" ]]; then
        log_warn "$label port $port occupied by PID(s) $pids — killing zombie process(es)"
        echo "$pids" | xargs kill 2>/dev/null || true
        sleep 1
        local still
        still=$(lsof -ti TCP:"$port" -sTCP:LISTEN 2>/dev/null)
        if [[ -n "$still" ]]; then
            echo "$still" | xargs kill -9 2>/dev/null || true
            sleep 1
        fi
    fi
}

start_core_api() {
    local pid_file="$PIDDIR/core-api.pid"
    if is_running "$pid_file"; then
        log_warn "core-api already running (PID $(cat "$pid_file"))"
        return 0
    fi

    ensure_port_free "$CORE_PORT" "core-api"

    if [[ ! -d "$CORE_API_DIR/node_modules" ]]; then
        log_warn "core-api: running npm install"
        ( cd "$CORE_API_DIR" && npm install )
    fi

    if [[ -d "$CORE_API_DIR/dist/services" && ! -d "$CORE_API_DIR/dist/src" ]]; then
        log_warn "core-api: stale dist/ detected (old layout), rebuilding..."
        rm -rf "$CORE_API_DIR/dist"
    fi
    if [[ ! -d "$CORE_API_DIR/dist/src" ]]; then
        log_warn "core-api: running npm run build"
        ( cd "$CORE_API_DIR" && npm run build )
    fi

    ( cd "$CORE_API_DIR" && nohup node dist/src/server.js > "$LOGDIR/core-api.log" 2>&1 & echo $! > "$pid_file"; disown 2>/dev/null )
    sleep 2
    if is_running "$pid_file"; then
        log_ok "core-api started on :$CORE_PORT (PID $(cat "$pid_file"))"
    else
        log_fail "core-api failed to start. tail $LOGDIR/core-api.log"
        return 1
    fi
}

start_ai_engine() {
    local pid_file="$PIDDIR/ai-engine.pid"
    if is_running "$pid_file"; then
        log_warn "ai-engine already running (PID $(cat "$pid_file"))"
        return 0
    fi

    ensure_port_free "$AI_PORT" "ai-engine"

    if [[ ! -d "$AI_ENGINE_DIR/.venv" ]]; then
        log_fail "ai-engine: .venv missing. run: cd $AI_ENGINE_DIR && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt"
        return 1
    fi

    if ! "$AI_ENGINE_DIR/.venv/bin/python" -c 'import fastapi' 2>/dev/null; then
        log_fail "ai-engine: deps not installed. run: $AI_ENGINE_DIR/.venv/bin/pip install -r $AI_ENGINE_DIR/requirements.txt"
        return 1
    fi

    ( cd "$AI_ENGINE_DIR" && nohup ./.venv/bin/uvicorn main:app --host 0.0.0.0 --port "$AI_PORT" > "$LOGDIR/ai-engine.log" 2>&1 & echo $! > "$pid_file"; disown 2>/dev/null )
    sleep 3
    if is_running "$pid_file"; then
        log_ok "ai-engine started on :$AI_PORT (PID $(cat "$pid_file"))"
    else
        log_fail "ai-engine failed to start. tail $LOGDIR/ai-engine.log"
        return 1
    fi
}

start_client_app() {
    local pid_file="$PIDDIR/client-app.pid"
    if is_running "$pid_file"; then
        log_warn "client-app already running (PID $(cat "$pid_file"))"
        return 0
    fi

    ensure_port_free "$CLIENT_PORT" "client-app"

    if [[ ! -d "$CLIENT_APP_DIR/vendor" ]]; then
        log_warn "client-app: running composer install"
        ( cd "$CLIENT_APP_DIR" && composer install --no-interaction )
    fi

    ( cd "$CLIENT_APP_DIR" && nohup php -d 'error_reporting=E_ALL & ~E_DEPRECATED' artisan serve --host=127.0.0.1 --port="$CLIENT_PORT" > "$LOGDIR/client-app.log" 2>&1 & echo $! > "$pid_file"; disown 2>/dev/null )
    sleep 2
    if is_running "$pid_file"; then
        log_ok "client-app started on :$CLIENT_PORT (PID $(cat "$pid_file"))"
    else
        log_fail "client-app failed to start. tail $LOGDIR/client-app.log"
        return 1
    fi
}

stop_pid_file() {
    local pid_file="$1"
    local label="$2"
    if is_running "$pid_file"; then
        local pid
        pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null || true
        sleep 1
        if kill -0 "$pid" 2>/dev/null; then
            kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
        log_ok "$label stopped"
    else
        log_warn "$label not running"
    fi
}

# ----- commands -----

cmd_start() {
    echo "→ infra"
    infra_start
    echo ""
    echo "→ apps"
    start_core_api
    start_client_app
    start_ai_engine || log_warn "ai-engine skipped — install deps first if you need it"
    echo ""
    log_ok "Done. Try: ./dev.sh smoke"
}

cmd_stop() {
    stop_pid_file "$PIDDIR/core-api.pid" "core-api"
    stop_pid_file "$PIDDIR/ai-engine.pid" "ai-engine"
    stop_pid_file "$PIDDIR/client-app.pid" "client-app"
    echo ""
    log_warn "infra services (postgres/mongo/redis) left running. Stop manually with: brew services stop ..."
}

cmd_restart() {
    cmd_stop
    sleep 1
    cmd_start
}

cmd_status() {
    echo "→ infra"
    infra_status
    echo ""
    echo "→ apps"
    for app in core-api ai-engine client-app; do
        local pid_file="$PIDDIR/$app.pid"
        if is_running "$pid_file"; then
            log_ok "$app (PID $(cat "$pid_file"))"
        else
            log_fail "$app (not running)"
        fi
    done
}

cmd_logs() {
    local app="${1:-}"
    if [[ -z "$app" ]]; then
        echo "Available logs:"
        ls -1 "$LOGDIR" 2>/dev/null | sed 's/^/  /' || echo "  (none)"
        echo ""
        echo "Usage: ./dev.sh logs <core-api|ai-engine|client-app>"
        return 1
    fi
    local log_file="$LOGDIR/$app.log"
    if [[ -f "$log_file" ]]; then
        tail -f "$log_file"
    else
        log_fail "log file not found: $log_file"
        return 1
    fi
}

cmd_smoke() {
    echo "→ infra"
    infra_status

    echo ""
    echo "→ apps"

    # Core API
    if curl -sf -m 3 "http://localhost:$CORE_PORT/health" >/dev/null 2>&1; then
        log_ok "core-api /health"
    else
        log_fail "core-api /health (port $CORE_PORT)"
    fi

    # AI Engine - require Bearer auth (KOL-142)
    local ai_secret
    ai_secret=$(grep -E "^CORE_API_SECRET=" "$AI_ENGINE_DIR/.env" 2>/dev/null | head -1 | cut -d= -f2-)
    if curl -sf -m 3 -H "Authorization: Bearer $ai_secret" "http://localhost:$AI_PORT/api/health" >/dev/null 2>&1; then
        log_ok "ai-engine /api/health"
    else
        log_fail "ai-engine /api/health (port $AI_PORT) — may not be running yet"
    fi

    # Client App
    local code
    code=$(curl -s -m 3 -o /dev/null -w "%{http_code}" "http://localhost:$CLIENT_PORT/" 2>/dev/null || echo "000")
    if [[ "$code" == "200" || "$code" == "302" ]]; then
        log_ok "client-app / (status $code)"
    else
        log_fail "client-app / (port $CLIENT_PORT, status $code)"
    fi
}

usage() {
    cat <<EOF
Kolabri local-native dev helper

Commands:
  start      Start all services + apps in background
  stop       Stop apps (infra services left running)
  restart    Stop then start
  status     Show service + app health
  logs <app> Tail log file (core-api|ai-engine|client-app)
  smoke      HTTP smoke test all 3 endpoints

Logs:        $LOGDIR
PID files:   $PIDDIR

Endpoints:
  Client app   http://localhost:$CLIENT_PORT
  Core API     http://localhost:$CORE_PORT
  AI Engine    http://localhost:$AI_PORT

EOF
}

case "${1:-}" in
    start)   cmd_start ;;
    stop)    cmd_stop ;;
    restart) cmd_restart ;;
    status)  cmd_status ;;
    logs)    cmd_logs "${2:-}" ;;
    smoke)   cmd_smoke ;;
    *)       usage; exit 1 ;;
esac
