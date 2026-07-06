#!/usr/bin/env bash
# Kolabri Demo Data Seeding Script
# Seeds both the core-api (PostgreSQL + MongoDB) and client-app (MySQL + PDF materials)
#
# Usage:
#   ./scripts/seed-demo.sh              # Full seed (reset + seed both)
#   ./scripts/seed-demo.sh --core-only  # Only seed core-api
#   ./scripts/seed-demo.sh --client-only # Only seed client-app materials
#   ./scripts/seed-demo.sh --skip-pdf   # Seed client-app without regenerating PDFs

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_API_DIR="$ROOT/Kolabri-core-api"
CLIENT_APP_DIR="$ROOT/Kolabri-client-app"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

log_ok()    { printf "${GREEN}✓${RESET} %s\n" "$1"; }
log_fail()  { printf "${RED}✗${RESET} %s\n" "$1"; }
log_warn()  { printf "${YELLOW}!${RESET} %s\n" "$1"; }
log_info()  { printf "${BLUE}→${RESET} %s\n" "$1"; }

SEED_CORE=true
SEED_CLIENT=true
SKIP_PDF=false

for arg in "$@"; do
    case "$arg" in
        --core-only)  SEED_CLIENT=false ;;
        --client-only) SEED_CORE=false ;;
        --skip-pdf)   SKIP_PDF=true ;;
        --help|-h)
            echo "Usage: $0 [--core-only|--client-only|--skip-pdf]"
            echo ""
            echo "Options:"
            echo "  --core-only    Only seed core-api (PostgreSQL + MongoDB)"
            echo "  --client-only  Only seed client-app materials (MySQL + PDFs)"
            echo "  --skip-pdf     Seed client-app without regenerating existing PDFs"
            exit 0
            ;;
    esac
done

echo ""
echo "========================================="
echo "  Kolabri Demo Data Seeder"
echo "========================================="
echo ""

# Check prerequisites
log_info "Checking prerequisites..."

if [ ! -d "$CORE_API_DIR" ]; then
    log_fail "Core API directory not found: $CORE_API_DIR"
    exit 1
fi

if [ ! -d "$CLIENT_APP_DIR" ]; then
    log_fail "Client App directory not found: $CLIENT_APP_DIR"
    exit 1
fi

if ! curl -s http://localhost:3000/health > /dev/null 2>&1; then
    log_warn "Core API not running on port 3000"
    if [ "$SEED_CLIENT" = true ]; then
        log_fail "Core API must be running for client-app seeding (materials seeder needs API access)"
        log_info "Start it with: cd Kolabri-core-api && npm run dev"
        exit 1
    fi
fi

log_ok "Prerequisites OK"
echo ""

# Step 1: Seed core-api
if [ "$SEED_CORE" = true ]; then
    echo "-----------------------------------------"
    echo "  Step 1: Seed Core API (PostgreSQL + MongoDB)"
    echo "-----------------------------------------"
    log_info "Running: npm run db:reset:demo-data"
    echo ""

    cd "$CORE_API_DIR"
    if npm run db:reset:demo-data; then
        log_ok "Core API seeded successfully"
    else
        log_fail "Core API seeding failed"
        exit 1
    fi
    echo ""
fi

# Step 2: Seed client-app materials
if [ "$SEED_CLIENT" = true ]; then
    echo "-----------------------------------------"
    echo "  Step 2: Seed Client App Materials (MySQL + PDFs)"
    echo "-----------------------------------------"

    cd "$CLIENT_APP_DIR"

    # Clear existing PDFs if not skipping
    if [ "$SKIP_PDF" = false ]; then
        log_info "Clearing existing PDFs..."
        rm -rf storage/app/public/demo-materials
        mkdir -p storage/app/public/demo-materials
    fi

    log_info "Running: php artisan db:seed --class=MaterialsDemoSeeder"
    echo ""

    if php artisan db:seed --class=MaterialsDemoSeeder; then
        log_ok "Client app materials seeded successfully"

        PDF_COUNT=$(find storage/app/public/demo-materials -name "*.pdf" 2>/dev/null | wc -l | tr -d ' ')
        log_ok "Generated $PDF_COUNT PDF files in storage/app/public/demo-materials/"
    else
        log_fail "Client app seeding failed"
        exit 1
    fi
    echo ""
fi

# Summary
echo "========================================="
echo "  Seeding Complete!"
echo "========================================="
echo ""
echo "Demo credentials:"
echo "  Lecturer 1: budi.santoso@univ.ac.id / password123"
echo "  Lecturer 2: siti.rahayu@univ.ac.id / password123"
echo "  Student:    andi.pratama@student.ac.id / password123"
echo ""
echo "Access the app at: http://localhost:8000"
echo ""
