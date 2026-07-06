#!/usr/bin/env bash
# Automated portion of docs/smoke-tests/*.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE_API="${CORE_API_URL:-http://127.0.0.1:3000}"
LARAVEL="${LARAVEL_URL:-http://127.0.0.1:8000}"
AI_ENGINE="${AI_ENGINE_URL:-http://127.0.0.1:8001}"
REPORT="${ROOT}/docs/smoke-tests/last-run-$(date +%Y%m%d-%H%M%S).md"
PASS=0
FAIL=0
SKIP=0
AI_HEALTH_OK=false

log() { echo "$1" | tee -a "$REPORT"; }
ok() { log "- [x] $1"; PASS=$((PASS+1)); }
bad() { log "- [ ] **FAIL** $1"; FAIL=$((FAIL+1)); }
skip() { log "- [~] **SKIP** $1"; SKIP=$((SKIP+1)); }

mkdir -p "${ROOT}/docs/smoke-tests"
log "# Smoke checklist run $(date -Iseconds)"
log ""

log "## Infrastructure"
if curl -sf --connect-timeout 3 "${CORE_API}/health" >/dev/null; then ok "core-api ${CORE_API}/health"; else bad "core-api down"; fi
if curl -sf --connect-timeout 3 "${LARAVEL}/login" >/dev/null; then ok "laravel ${LARAVEL}/login"; else bad "laravel down"; fi
for path in /api/health /health; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "${AI_ENGINE}${path}" 2>/dev/null || echo 000)
  if [[ "$code" == "200" || "$code" == "401" ]]; then AI_HEALTH_OK=true; break; fi
done
if $AI_HEALTH_OK; then ok "ai-engine health"; else skip "ai-engine not up (classify smoke needs it)"; fi
log ""

log "## P0 — core-api (direct API)"
ADMIN_EMAIL="${SMOKE_ADMIN_EMAIL:-admin@kolabri.id}"
ADMIN_PASS="${SMOKE_ADMIN_PASS:-password}"
LECTURER_EMAIL="${SMOKE_LECTURER_EMAIL:-}"
LECTURER_PASS="${SMOKE_LECTURER_PASS:-}"
STUDENT_EMAIL="${SMOKE_STUDENT_EMAIL:-}"
STUDENT_PASS="${SMOKE_STUDENT_PASS:-}"
ADM_TOKEN=""

login_token() {
  local email="$1" pass="$2"
  curl -sf -X POST "${CORE_API}/api/auth/login" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"${email}\",\"password\":\"${pass}\"}" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('accessToken','') or d.get('token',''))" 2>/dev/null || true
}

ADM_TOKEN=$(login_token "$ADMIN_EMAIL" "$ADMIN_PASS")
if [[ -n "$ADM_TOKEN" ]]; then
  CODE=$(curl -s -o /tmp/privacy-admin.json -w "%{http_code}" -H "Authorization: Bearer ${ADM_TOKEN}" "${CORE_API}/api/user/privacy-preferences")
  if [[ "$CODE" == "200" ]]; then ok "GET /api/user/privacy-preferences (admin token)"; else bad "privacy GET http $CODE"; fi
  CODE=$(curl -s -o /tmp/policy.json -w "%{http_code}" "${CORE_API}/api/privacy/policy")
  if [[ "$CODE" == "200" ]]; then ok "GET /api/privacy/policy"; else bad "policy GET http $CODE"; fi
  CODE=$(curl -s -o /tmp/ret.json -w "%{http_code}" -H "Authorization: Bearer ${ADM_TOKEN}" "${CORE_API}/api/admin/retention-policies")
  if [[ "$CODE" == "200" ]]; then ok "GET /api/admin/retention-policies"; else bad "retention GET http $CODE"; fi
  CODE=$(curl -s -o /tmp/dh.json -w "%{http_code}" -H "Authorization: Bearer ${ADM_TOKEN}" "${CORE_API}/api/lecturer/discussion-health")
  if [[ "$CODE" == "200" ]] && python3 -c "import json; assert 'chatSpaces' in json.load(open('/tmp/dh.json'))" 2>/dev/null; then
    ok "GET /api/lecturer/discussion-health"
  else
    bad "discussion-health http $CODE or bad shape"
  fi
else
  skip "admin login failed ($ADMIN_EMAIL) — set SMOKE_ADMIN_EMAIL/PASS"
fi

if [[ -n "$STUDENT_EMAIL" && -n "$STUDENT_PASS" ]]; then
  STU_TOKEN=$(login_token "$STUDENT_EMAIL" "$STUDENT_PASS")
  if [[ -n "$STU_TOKEN" ]]; then ok "student login ($STUDENT_EMAIL)"; else skip "student login failed"; fi
else
  skip "student login — optional SMOKE_STUDENT_EMAIL/PASS (demo seed: student1@kolabri.edu / password123 if seeded)"
fi

if [[ -n "$LECTURER_EMAIL" && -n "$LECTURER_PASS" ]]; then
  LEC_TOKEN=$(login_token "$LECTURER_EMAIL" "$LECTURER_PASS")
  if [[ -n "$LEC_TOKEN" ]]; then ok "lecturer login ($LECTURER_EMAIL)"; else skip "lecturer login failed"; fi
else
  skip "lecturer login — optional SMOKE_LECTURER_EMAIL/PASS (demo: lecturer@kolabri.edu / password123 if seeded)"
fi

log ""
log "## P0 — Laravel BFF"
CODE=$(curl -s -o /dev/null -w "%{http_code}" "${LARAVEL}/api/user/privacy-preferences")
if [[ "$CODE" == "401" || "$CODE" == "302" || "$CODE" == "403" ]]; then
  ok "BFF privacy protected without session (HTTP $CODE)"
else
  bad "BFF privacy without session expected 401/302 got $CODE"
fi
skip "Settings UI (Privasi / Retensi / widget) — manual browser after login"

log ""
log "## P0 — classify-relevance"
if $AI_HEALTH_OK; then
  AI_SECRET="${AI_ENGINE_SECRET:-}"
  if [[ -z "$AI_SECRET" && -f "${ROOT}/Kolabri-ai-engine/.env" ]]; then
    AI_SECRET=$(grep -E '^CORE_API_SECRET=' "${ROOT}/Kolabri-ai-engine/.env" | cut -d= -f2- | tr -d '"' | head -1)
  fi
  AUTH_ARGS=()
  [[ -n "$AI_SECRET" ]] && AUTH_ARGS=(-H "Authorization: Bearer ${AI_SECRET}")
  CODE=$(curl -s -o /tmp/cl.json -w "%{http_code}" --max-time 90 -X POST "${AI_ENGINE}/api/classify-relevance" \
    -H 'Content-Type: application/json' "${AUTH_ARGS[@]}" \
    -d '{"messages":[{"id":"m1","content":"apa itu photosynthesis"}],"goal":"memahami fotosintesis"}')
  if [[ "$CODE" == "200" ]] && python3 -c "import json; assert 'classifications' in json.load(open('/tmp/cl.json'))" 2>/dev/null; then
    ok "POST /api/classify-relevance"
  else
    bad "classify http $CODE"
  fi
else
  skip "classify — ai-engine down"
fi

log ""
log "## Perf-02 — dashboard Cache-Control"
if [[ -n "$ADM_TOKEN" ]]; then
  HDR=$(curl -s -D - -o /dev/null -H "Authorization: Bearer ${ADM_TOKEN}" "${CORE_API}/api/admin/dashboard/stats" 2>/dev/null | tr -d '\r' | grep -i '^cache-control:' || true)
  if echo "$HDR" | grep -qi 'max-age=30'; then ok "admin dashboard stats Cache-Control max-age=30"; else bad "Cache-Control missing: $HDR"; fi
else
  skip "dashboard Cache-Control — no admin token"
fi

log ""
log "## Automated tests (regression)"
if (cd "${ROOT}/Kolabri-core-api" && npm run test:run -- src/services/dashboard-cache.test.ts src/services/dashboard-invalidation-hooks.test.ts src/services/reflection.service.test.ts >/tmp/vitest-smoke.log 2>&1); then
  ok "vitest dashboard + reflection"
else
  bad "vitest — see /tmp/vitest-smoke.log"
fi
if (cd "${ROOT}/Kolabri-ai-engine" && python3 -m pytest tests/test_unit/test_analytics_dashboard_cache.py -q >/tmp/pytest-smoke.log 2>&1); then
  ok "pytest analytics dashboard cache"
else
  bad "pytest analytics — see /tmp/pytest-smoke.log"
fi

log ""
log "## Summary: pass=$PASS fail=$FAIL skip=$SKIP"
log "Report: $REPORT"
echo "Done: pass=$PASS fail=$FAIL skip=$SKIP → $REPORT"