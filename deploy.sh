#!/bin/bash
#
# Kolabri — one-command deployment for hosting via Docker.
#
# Usage:
#   ./deploy.sh                 # full deploy, nginx enabled on :80/:443
#   ./deploy.sh --no-cache      # force clean rebuild of all images
#   ./deploy.sh --yes           # never prompt (CI / agent); missing env files are
#                               # created from the examples and deployment proceeds
#   ./deploy.sh --no-nginx      # skip the nginx profile (app ports stay internal)
#   ./deploy.sh --status        # only print service status, change nothing
#   ./deploy.sh --check         # validate compose config only (no build, no start)
#
# Env:
#   KOLABRI_DOMAIN=example.com  # CN used for the auto-generated self-signed cert
#   KOLABRI_HEALTH_TIMEOUT=180  # seconds to wait for healthchecks
#
# What it does:
#   1. check prerequisites (docker + compose v2 or v1)
#   2. create required directories + self-signed TLS pair (nginx needs it)
#   3. create .env.production / root .env from the bundled examples if missing
#   4. build images
#   5. start services
#   6. wait for healthchecks (no fixed sleep)
#   7. optimize Laravel
#   8. generate Laravel APP_KEY if the placeholder is still present
#
# Compose file: docker-compose.production.yml (nginx profile auto-enabled).
# Prisma migrations run automatically (core-api entrypoint.sh -> prisma migrate deploy).

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

COMPOSE_FILE="docker-compose.production.yml"
NO_CACHE=""
ASSUME_YES=false
STATUS_ONLY=false
WITH_NGINX=true
CHECK_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --no-cache) NO_CACHE="--no-cache" ;;
        --yes|-y)   ASSUME_YES=true ;;
        --status)   STATUS_ONLY=true ;;
        --no-nginx) WITH_NGINX=false ;;
        --check)    CHECK_ONLY=true ;;
        --help|-h)
            sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg (try --help)${NC}"
            exit 1
            ;;
    esac
done

# nginx lives behind a compose profile; enabling it makes the stack reachable on
# :80/:443 (client-app/core-api publish no host ports by design).
if [ "$WITH_NGINX" = true ]; then
    export COMPOSE_PROFILES="docker-nginx"
fi

# Resolve compose: prefer v2 plugin (`docker compose`), fall back to legacy binary.
if docker compose version > /dev/null 2>&1; then
    COMPOSE="docker compose"
elif command -v docker-compose > /dev/null 2>&1; then
    COMPOSE="docker-compose"
else
    echo -e "${RED}Error: Docker Compose not found${NC}"
    echo -e "${YELLOW}Install it: https://docs.docker.com/compose/install/${NC}"
    exit 1
fi
compose() { $COMPOSE -f "$COMPOSE_FILE" "$@"; }

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Kolabri — Docker deployment          ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Compose: ${COMPOSE} -f ${COMPOSE_FILE}"
echo ""

if [ "$STATUS_ONLY" = true ]; then
    compose ps
    exit 0
fi

# Interactive prompts are only possible on a TTY. Without one we proceed with
# whatever the examples provide and report it — a `read` here would hang an
# agent/CI run and `set -e` would abort on EOF.
INTERACTIVE=false
if [ -t 0 ] && [ "$ASSUME_YES" = false ]; then
    INTERACTIVE=true
fi

# ---1/8 prerequisites ---
echo -e "${BLUE}[1/8] Checking prerequisites...${NC}"
if ! command -v docker > /dev/null 2>&1; then
    echo -e "${RED}Error: docker is not installed${NC}"; exit 1
fi
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"; exit 1
fi
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Running as root (allowed — common on VPS).${NC}"
fi
echo -e "${GREEN}✓ Prerequisites met${NC}"
echo ""

# ---2/8 directories + TLS material ---
echo -e "${BLUE}[2/8] Creating directories...${NC}"
mkdir -p nginx/ssl uploads logs

# nginx/conf.d/default.conf has a `listen 443 ssl` block pointing at
# /etc/nginx/ssl/{fullchain,privkey}.pem. Without those files nginx refuses to
# start, so mint a self-signed pair first (replace with Let's Encrypt later —
# see DEPLOYMENT.md "SSL Configuration").
if [ "$WITH_NGINX" = true ] && [ ! -f nginx/ssl/fullchain.pem ]; then
    if command -v openssl > /dev/null 2>&1; then
        echo -e "${YELLOW}→ generating self-signed TLS certificate (replace with real cert later)${NC}"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout nginx/ssl/privkey.pem \
            -out nginx/ssl/fullchain.pem \
            -subj "/CN=${KOLABRI_DOMAIN:-kolabri.local}" 2>/dev/null
        chmod 600 nginx/ssl/privkey.pem
        echo -e "${GREEN}✓ Self-signed certificate created${NC}"
    else
        echo -e "${YELLOW}⚠ openssl not found and no cert present — nginx would fail to start.${NC}"
        echo -e "${YELLOW}  Run with --no-nginx, or install openssl and re-run.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# ---3/8 environment files ---
echo -e "${BLUE}[3/8] Checking environment files...${NC}"

ensure_env() {
    local target="$1" template="$2" label="$3"
    if [ -f "$target" ]; then
        echo -e "${GREEN}✓${NC} $target exists"
        return 0
    fi
    if [ ! -f "$template" ]; then
        echo -e "${RED}✗ $template missing — cannot create $target${NC}"; exit 1
    fi
    cp "$template" "$target"
    echo -e "${YELLOW}→ created $target from $label"
    if [ "$INTERACTIVE" = true ]; then
        echo -e "${RED}⚠ Review $target with your production values${NC}"
        printf "Press Enter to continue after editing..."
        read -r _ || true
    else
        echo -e "${YELLOW}  (non-interactive: using example defaults — review before real production)${NC}"
    fi
}

ensure_env "Kolabri-ai-engine/.env.production"   "Kolabri-ai-engine/.env.production.example"   "ai-engine example"
ensure_env "Kolabri-core-api/.env.production"    "Kolabri-core-api/.env.production.example"    "core-api example"
ensure_env "Kolabri-client-app/.env.production"  "Kolabri-client-app/.env.production.example"  "client-app example"

# Root .env feeds ${VAR:-default} interpolation in docker-compose.production.yml.
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# Docker Compose interpolation (used by docker-compose.production.yml)
POSTGRES_PASSWORD=change-this-to-strong-password
MONGO_USERNAME=admin
MONGO_PASSWORD=change-this-to-strong-mongo-password
REDIS_PASSWORD=change-this-to-strong-redis-password
EOF
    echo -e "${YELLOW}→ created root .env with placeholder passwords"
    if [ "$INTERACTIVE" = true ]; then
        echo -e "${RED}⚠ Edit .env with strong passwords (openssl rand -base64 32)${NC}"
        printf "Press Enter to continue..."
        read -r _ || true
    fi
fi
# The committed example ships a fixed APP_KEY. Every deployment that kept it
# would share one publicly-known encryption key, so mint a fresh one whenever the
# value is empty, a placeholder, or still the example's literal.
APP_KEY_EXAMPLE="base64:whSTEms2vPLTKNAu+t6LJ+p8w1qHUb93jl9/VKJhGuA="
ENV_CLIENT="Kolabri-client-app/.env.production"
if [ -f "$ENV_CLIENT" ]; then
    current_key=$(grep -E '^APP_KEY=' "$ENV_CLIENT" | head -1 | cut -d= -f2- || true)
    case "$current_key" in
        ""|"base64:generate-new-app-key"|"$APP_KEY_EXAMPLE")
            if command -v openssl > /dev/null 2>&1; then
                new_key="base64:$(openssl rand -base64 32 | tr -d '\n')"
                grep -vE '^APP_KEY=' "$ENV_CLIENT" > "$ENV_CLIENT.tmp" || true
                echo "APP_KEY=${new_key}" >> "$ENV_CLIENT.tmp"
                mv "$ENV_CLIENT.tmp" "$ENV_CLIENT"
                echo -e "${GREEN}✓ Generated a fresh APP_KEY (was empty/placeholder/example value)${NC}"
            else
                echo -e "${YELLOW}⚠ openssl missing — APP_KEY not rotated (step 8 will retry)${NC}"
            fi
            ;;
        *)
            echo -e "${GREEN}✓ APP_KEY already set (leaving untouched)${NC}"
            ;;
    esac
fi

echo -e "${GREEN}✓ Environment files ready${NC}"
echo ""

# --check: prove the compose file parses (catches missing env_file, bad YAML,
# unknown profile) without spending time/RAM on building images.
if [ "$CHECK_ONLY" = true ]; then
    echo -e "${BLUE}[check] Validating ${COMPOSE_FILE}...${NC}"
    if compose config --quiet; then
        echo -e "${GREEN}✓ Compose config is valid (${COMPOSE} -f ${COMPOSE_FILE})"
        echo -e "${GREEN}✓ Profiles: ${COMPOSE_PROFILES:-<none>}"
        compose config --services | sed "s/^/  - /"
        exit 0
    else
        echo -e "${RED}✗ Compose config invalid${NC}"
        exit 1
    fi
fi

# ---4/8 build ---
echo -e "${BLUE}[4/8] Building Docker images...${NC}"
if [ -n "$NO_CACHE" ]; then
    echo -e "${YELLOW}--no-cache: clean rebuild (this takes a while)${NC}"
else
    echo -e "${YELLOW}Using cached layers where possible${NC}"
fi
compose build $NO_CACHE
echo -e "${GREEN}✓ Images built${NC}"
echo ""

# ---5/8 start ---
echo -e "${BLUE}[5/8] Starting services...${NC}"
compose up -d
echo -e "${GREEN}✓ Services started${NC}"
echo ""

# ---6/8 health wait ---
echo -e "${BLUE}[6/8] Waiting for services to be healthy...${NC}"
WAIT_SECS=${KOLABRI_HEALTH_TIMEOUT:-180}
deadline=$(( $(date +%s) + WAIT_SECS ))
while [ "$(date +%s)" -lt "$deadline" ]; do
    # a service is ready when it reports healthy, or is Up without a healthcheck
    pending=$(compose ps --format '{{.Name}} {{.Status}}' 2>/dev/null \
        | awk '$0 ~ /health: starting|Restarting|Created/ {n++} END {print n+0}')
    if [ "$pending" -eq 0 ]; then
        echo -e "${GREEN}✓ No service is still starting${NC}"
        break
    fi
    sleep 5
done
echo ""
echo -e "${BLUE}Service status:${NC}"
compose ps
echo ""

# ---7/8 Laravel optimization ---
echo -e "${BLUE}[7/8] Optimizing Laravel...${NC}"
if docker ps --format '{{.Names}}' | grep -qx "kolabri-client-app"; then
    if docker exec kolabri-client-app php artisan config:cache > /dev/null 2>&1; then
        docker exec kolabri-client-app php artisan route:cache > /dev/null 2>&1 || true
        docker exec kolabri-client-app php artisan view:cache > /dev/null 2>&1 || true
        echo -e "${GREEN}✓ Laravel optimized${NC}"
    else
        echo -e "${YELLOW}⚠ Laravel not reachable yet — skipping optimization (run later)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ kolabri-client-app not running — skipping${NC}"
fi
echo ""

# ---8/8 APP_KEY ---
echo -e "${BLUE}[8/8] Checking Laravel APP_KEY...${NC}"
ENV_APP="Kolabri-client-app/.env.production"
if [ -f "$ENV_APP" ]; then
    if grep -qE '^APP_KEY=$|^APP_KEY=base64:generate-new-app-key' "$ENV_APP"; then
        KEY=$(docker exec kolabri-client-app php artisan key:generate --show 2>/dev/null || true)
        if [ -n "$KEY" ]; then
            # portable in-place edit (no `sed -i` GNU/BSD divergence)
            grep -vE '^APP_KEY=' "$ENV_APP" > "$ENV_APP.tmp" || true
            echo "APP_KEY=${KEY}" >> "$ENV_APP.tmp"
            mv "$ENV_APP.tmp" "$ENV_APP"
            docker restart kolabri-client-app > /dev/null 2>&1 || true
            echo -e "${GREEN}✓ APP_KEY generated and set${NC}"
        else
            echo -e "${YELLOW}⚠ Could not generate APP_KEY (container not ready). Re-run: ./deploy.sh${NC}"
        fi
    else
        echo -e "${GREEN}✓ APP_KEY already configured${NC}"
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Deployment finished${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Follow-up:${NC}"
echo "1. Point your domain: edit nginx/conf.d/ (server_name), then"
echo "   ${COMPOSE} -f ${COMPOSE_FILE} restart nginx"
echo "2. SSL: add certs to nginx/ssl/ (or certbot --standalone)"
echo "3. Seed demo data: ./scripts/seed-demo.sh"
echo "4. Status:  ./deploy.sh --status"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  Logs:      ${COMPOSE} -f ${COMPOSE_FILE} logs -f [service]"
echo "  Stop:      ${COMPOSE} -f ${COMPOSE_FILE} down"
echo "  Rebuild:   ./deploy.sh            (cached)"
echo "  Clean:     ./deploy.sh --no-cache"
