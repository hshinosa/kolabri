# Smoke tests (manual)

**P0 gate:** [`../p0-release-gate.md`](../p0-release-gate.md) · **P1:** `openspec/changes/improve-test-coverage/tasks.md`

| Dokumen | Scope |
|---------|--------|
| [nfr-usability-04-p0.md](./nfr-usability-04-p0.md) | Privacy BFF, retensi admin, AI classify, discussion-health, HealthScoreCard |
| [nfr-perf-02-dashboard-caching.md](./nfr-perf-02-dashboard-caching.md) | Dashboard SimpleCache, invalidation, AI analytics Redis cache |

Jalankan layanan lengkap (client-app, core-api, ai-engine, DB) sebelum checklist.

**Otomatis (API + unit tests):**

```bash
chmod +x scripts/run-smoke-checklist.sh
./scripts/run-smoke-checklist.sh
# Opsional: SMOKE_ADMIN_EMAIL=admin@kolabri.id SMOKE_ADMIN_PASS=password
# Demo full seed: lecturer@kolabri.edu / student1@kolabri.edu + password123
```

Laporan terakhir: `docs/smoke-tests/last-run-*.md`