#!/usr/bin/env bash
# NFR-PERF-02 manual benchmark (tasks 5.1–5.4)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ROOT
CORE_API="${CORE_API_URL:-http://127.0.0.1:3000}"
AI_ENGINE="${AI_ENGINE_URL:-http://127.0.0.1:8001}"
ADMIN_EMAIL="${SMOKE_ADMIN_EMAIL:-admin@kolabri.id}"
ADMIN_PASS="${SMOKE_ADMIN_PASS:-password}"
GROUP_ID="${PERF02_GROUP_ID:-4a95c9b8-7afd-44a1-bc83-cfe6e760de79}"
REPORT="${ROOT}/docs/smoke-tests/perf02-benchmark-$(date +%Y%m%d-%H%M%S).md"
TTI_MS_MAX=2000

mkdir -p "${ROOT}/docs/smoke-tests"
echo "# PERF-02 benchmark $(date -Iseconds)" >"$REPORT"
echo "" >>"$REPORT"

log() { echo "$1" | tee -a "$REPORT"; }

login_token() {
  curl -sf -X POST "${CORE_API}/api/auth/login" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASS}\"}" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('accessToken','') or d.get('token',''))"
}

ADM_TOKEN=$(login_token || true)
if [[ -z "$ADM_TOKEN" ]]; then
  log "**FAIL** admin login"
  exit 1
fi

STATS_URL="${CORE_API}/api/admin/dashboard/stats"

log "## A — Admin dashboard stats cache"
HDR=$(curl -s -D - -o /dev/null -H "Authorization: Bearer ${ADM_TOKEN}" "$STATS_URL" | tr -d '\r' | grep -i '^cache-control:' || true)
log "- Cache-Control: \`${HDR#cache-control: }\`"

log ""
log "## 5.1 — Dashboard API latency (API target < ${TTI_MS_MAX}ms warm)"
export ADM_TOKEN STATS_URL TTI_MS_MAX
python3 <<'PY' | tee -a "$REPORT"
import json, subprocess, time, statistics, os

token = os.environ["ADM_TOKEN"]
url = os.environ["STATS_URL"]
max_ms = int(os.environ["TTI_MS_MAX"])
hdr = ["-H", f"Authorization: Bearer {token}"]

def fetch():
    t0 = time.perf_counter()
    subprocess.run(
        ["curl", "-sf", "-o", "/tmp/perf02-stats.json", url, *hdr],
        check=True, capture_output=True,
    )
    return (time.perf_counter() - t0) * 1000

root = os.environ["ROOT"]
subprocess.run(
    ["npx", "tsx", "-e",
     "import { invalidateDashboardCache } from './src/services/dashboard.service.js'; invalidateDashboardCache();"],
    cwd=f"{root}/Kolabri-core-api", capture_output=True,
)
cold = [fetch() for _ in range(3)]
for _ in range(3):
    fetch()
warm = [fetch() for _ in range(5)]

def line(label, arr):
    print(f"- {label}: min={min(arr):.0f}ms median={statistics.median(arr):.0f}ms max={max(arr):.0f}ms")

line("cold (after invalidate)", cold)
line("warm (cache hit)", warm)
ok = max(warm) < max_ms
print(f"- warm max < {max_ms}ms: {'PASS' if ok else 'FAIL'}")
PY

log ""
log "## 5.2 — Stats after invalidate"
python3 <<'PY' | tee -a "$REPORT"
import json, subprocess, os

token = os.environ["ADM_TOKEN"]
url = os.environ["STATS_URL"]
root = os.environ["ROOT"]

def stats():
    subprocess.run(
        ["curl", "-sf", "-o", "/tmp/perf02-s1.json", url, "-H", f"Authorization: Bearer {token}"],
        check=True,
    )
    raw = json.load(open("/tmp/perf02-s1.json"))
    return raw.get("data", raw)

s1 = stats()
subprocess.run(
    ["npx", "tsx", "-e",
     "import { invalidateDashboardCache } from './src/services/dashboard.service.js'; invalidateDashboardCache();"],
    cwd=f"{root}/Kolabri-core-api", capture_output=True,
)
s2 = stats()
print(f"- users.total before={s1.get('users',{}).get('total')} after={s2.get('users',{}).get('total')}")
print("- [x] 5.2 valid JSON after invalidate: PASS")
PY

log ""
log "## 5.3 — AI analytics double-fetch"
AI_SECRET=""
if [[ -f "${ROOT}/Kolabri-ai-engine/.env" ]]; then
  AI_SECRET=$(grep -E '^CORE_API_SECRET=' "${ROOT}/Kolabri-ai-engine/.env" | cut -d= -f2- | tr -d '"' | head -1)
fi
AUTH=()
[[ -n "$AI_SECRET" ]] && AUTH=(-H "Authorization: Bearer ${AI_SECRET}")
AN_URL="${AI_ENGINE}/api/analytics/dashboard/group/${GROUP_ID}"
CODE1=$(curl -s -o /tmp/perf02-an1.json -w '%{http_code}' "${AUTH[@]}" "$AN_URL" 2>/dev/null || echo "000")
if [[ "$CODE1" == "200" ]]; then
  T1=$(curl -s -o /tmp/perf02-an1.json -w '%{time_total}' "${AUTH[@]}" "$AN_URL")
  T2=$(curl -s -o /tmp/perf02-an2.json -w '%{time_total}' "${AUTH[@]}" "$AN_URL")
  python3 -c "import json;a=json.load(open('/tmp/perf02-an1.json'));b=json.load(open('/tmp/perf02-an2.json'));print(f'- 1st={float('$T1'):.3f}s 2nd={float('$T2'):.3f}s');print('- identical body:', 'PASS' if a==b else 'FAIL')"
else
  log "- SKIP analytics HTTP $CODE1"
fi

log ""
log "## 5.4 — Perf-02 regression subset (task 5.4)"
VITEST_FILES="src/services/dashboard-cache.test.ts src/services/dashboard-invalidation-hooks.test.ts src/services/reflection.service.test.ts src/services/dashboard.service.test.ts"
if (cd "${ROOT}/Kolabri-core-api" && npm run test:run -- $VITEST_FILES >/tmp/perf02-vitest.log 2>&1); then
  log "- [x] core-api vitest (dashboard + invalidation + reflection)"
else
  log "- [ ] core-api vitest perf-02 subset FAIL"
  tail -8 /tmp/perf02-vitest.log | tee -a "$REPORT"
fi
if (cd "${ROOT}/Kolabri-ai-engine" && python3 -m pytest tests/test_unit/test_analytics_dashboard_cache.py tests/test_unit/test_redis_cache.py -q >/tmp/perf02-pytest.log 2>&1); then
  log "- [x] ai-engine pytest (analytics + redis cache)"
else
  log "- [ ] ai-engine pytest perf-02 subset FAIL"
  tail -8 /tmp/perf02-pytest.log | tee -a "$REPORT"
fi

log ""
log "Report: $REPORT"