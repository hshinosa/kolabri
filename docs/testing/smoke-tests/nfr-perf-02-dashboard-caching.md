# Smoke & Verifikasi: NFR-PERF-02 Dashboard Caching

**OpenSpec:** `openspec/changes/nfr-perf-02-dashboard-caching/`  
**Status implementasi:** caching & invalidation sebagian besar ada; tasks **3.4–5.4** masih verifikasi/test.

## Prasyarat

- core-api running, admin user untuk dashboard admin stats.
- (Untuk analytics cache) AI engine + Redis sesuai `Kolabri-ai-engine/app/core/redis_cache.py`.
- Group ID valid untuk endpoint analytics group dashboard.

---

## A. Admin dashboard stats (SimpleCache + Cache-Control)

**Endpoint:** `GET /api/admin/dashboard/stats` (atau route yang memanggil `DashboardController.getStats`).

| # | Langkah | Ekspektasi |
|---|---------|------------|
| A.1 | Login admin, panggil stats 2× dalam < 30s (curl atau UI admin dashboard) | Response header `Cache-Control: private, max-age=30` |
| A.2 | Bandingkan latency request kedua vs pertama | Kedua biasanya lebih cepat (in-memory hit) — catat ms di log |
| A.3 | Tunggu > 30s, panggil lagi | Cache TTL expired → recompute (latency bisa naik) |

**Cache key:** `dashboard:stats:{preset}:{start}:{end}` — **global pattern**, bukan per-userId (beda dari wording spec lama; invalidation memakai `invalidatePattern('dashboard:stats:')`).

---

## B. Invalidation events

| Event | Kode | Smoke |
|-------|------|--------|
| `send_message` (socket) | `socket/index.ts` → `invalidateDashboardCache()` | Setelah kirim pesan grup, refresh admin stats dalam 30s → angka pesan/aktivitas terbaru |
| User leave room (presence) | `socket/presence.ts` `removeUserFromRoom` | Leave chat → stats presence-related tidak wajib di dashboard; invalidation tetap dipanggil |
| Reflection submit | `reflection.service.ts` | Submit refleksi student → stats terkait update setelah refresh |
| `join_room` | `socket/index.ts` setelah `room_joined` | Invalidate dipanggil (selaras spec membership/presence) |

**Catatan spec vs implementasi:** Spec menyebut invalidation per-user; implementasi **flush semua** key `dashboard:stats:*` — lebih sederhana, aman untuk smoke “data tidak stale > 1 request setelah event”.

---

## C. AI Engine analytics Redis cache (task 4.4)

**Endpoints contoh:**  
`GET /analytics/dashboard/group/{group_id}` — TTL `CACHE_TTL["analytics"]` (300s).

| # | Langkah | Ekspektasi |
|---|---------|------------|
| C.1 | Panggil endpoint 2× dengan `group_id` sama | Response body identik; request kedua tidak memicu orchestrator berat (cek log / timing) |
| C.2 | `pytest` unit/route dengan mock redis | Lihat `tests/test_unit/test_redis_cache.py` + tes analytics route (ditambahkan di P1) |

---

## D. Benchmark (task 5.1–5.3)

| Task | Cara manual |
|------|-------------|
| 5.1 TTI dashboard < 2s | Chrome Performance / Network pada halaman admin dashboard; catat `DOMContentLoaded` + API stats duration |
| 5.2 Fresh setelah invalidation | Catat `users.total` atau `messages` counter → kirim pesan → hit stats lagi dalam 30s → nilai berubah |
| 5.3 Analytics cache hit | Ulangi C.1 dengan `curl -w '%{time_total}\n'` |

---

## Perintah otomatis (regresi)

```bash
cd Kolabri-core-api
npm run test:run -- src/services/dashboard-cache.test.ts
# Setelah P1: dashboard-invalidation-hooks.test.ts, reflection invalidate test

cd Kolabri-ai-engine
pytest tests/test_unit/test_analytics_dashboard_cache.py -q   # setelah ditambahkan
pytest tests/test_unit/test_redis_cache.py -q
```

---

## Checklist perf-02

- [x] A.1–A.3 Cache-Control & TTL (benchmark script + smoke)
- [x] B send_message + reflection — vitest `dashboard-invalidation-hooks`, `reflection.service`
- [x] C analytics double-fetch (benchmark 5.3)
- [x] D benchmark — `./scripts/perf02-benchmark.sh` → `docs/smoke-tests/perf02-benchmark-*.md`
- [x] `tasks.md` 5.1–5.4

```bash
./scripts/perf02-benchmark.sh
# optional: PERF02_GROUP_ID=<uuid>
```