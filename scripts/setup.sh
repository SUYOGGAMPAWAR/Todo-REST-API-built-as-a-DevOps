#!/usr/bin/env bash
# scripts/setup.sh — One-shot local environment bootstrap
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
die()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

log "=== DevOps Todo API — Local Setup ==="

# ── Prerequisites check ───────────────────────────────────
for cmd in docker docker-compose node npm; do
    command -v "$cmd" &>/dev/null || die "Missing: $cmd — please install it first."
    log "$cmd found: $(command -v $cmd)"
done

# ── Build & start ─────────────────────────────────────────
log "Building Docker images..."
docker-compose build --no-cache

log "Starting services (app + jenkins + nginx)..."
docker-compose up -d

# ── Wait for app ──────────────────────────────────────────
warn "Waiting for app to be healthy..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
        log "App is UP!"
        break
    fi
    sleep 2
done

# ── Print summary ─────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Services Running                      ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "  🌐 App (direct)   →  http://localhost:3000"
echo -e "  🔀 App (via nginx) →  http://localhost:80"
echo -e "  🏗  Jenkins        →  http://localhost:8080"
echo ""
echo -e "  API Endpoints:"
echo -e "    GET  /api/todos"
echo -e "    GET  /api/todos/:id"
echo -e "    POST /api/todos       { \"title\": \"...\" }"
echo -e "    PUT  /api/todos/:id"
echo -e "    DELETE /api/todos/:id"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
warn "Jenkins initial password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || warn "Jenkins still starting — check back in ~60s"
