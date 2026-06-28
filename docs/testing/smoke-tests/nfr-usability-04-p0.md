# Smoke Test: NFR-USABILITY-04 (P0)

Dokumen ini untuk verifikasi manual setelah implementasi P0 (privacy BFF, AI discussion direction, lecturer discussion-health, HealthScoreCard).  
**Gate:** [`../p0-release-gate.md`](../p0-release-gate.md) · **OpenSpec:** `openspec/changes/nfr-usability-04-discussion-direction/` (+ `nfr-sec-02` retensi).

### Centang manual (isi tanggal di `p0-release-gate.md`)

- [ ] §1 Privasi
- [ ] §2 Retensi admin
- [ ] §3+ diskusi / health / ringkasan (sesuai section di bawah)

## Prasyarat

| Layanan | Perintah tipikal | Port default |
|---------|------------------|--------------|
| PostgreSQL + MongoDB + Redis | sesuai `docker-compose` / lokal | — |
| **Kolabri-core-api** | `npm run dev` di `Kolabri-core-api/` | `3000` (cek `.env`) |
| **Kolabri-ai-engine** | `uvicorn` / script dev di `Kolabri-ai-engine/` | `8001` |
| **Kolabri-client-app** | `php artisan serve` + `npm run dev` (Vite) | Laravel `8000`, Vite sesuai env |

### Env yang harus selaras

- **core-api** `AI_ENGINE_URL=http://localhost:8001` (bukan `5001`).
- **core-api** `CORE_API_SECRET` = secret yang diterima AI engine untuk `Authorization: Bearer …` pada `/api/classify-relevance` dan `/api/session-summary`.
- **client-app** `CORE_API_URL` (atau setara di `.env`) mengarah ke core-api; session login Laravel memuat JWT untuk proxy BFF.

### Data uji minimal

1. **Admin** — akun dengan role `admin`.
2. **Lecturer** — pemilik minimal satu `course` aktif dengan `group` + `chatSpace` terbuka (belum `closedAt`).
3. **Student** — anggota grup yang sama; chat space punya **learning goal** (agar classify & health score bermakna).
4. Opsional: beberapa pesan student/lecturer di chat space (untuk relevance / health).

---

## 1. Privacy preferences (student / semua user)

**Laravel BFF:** `GET/PUT /api/user/privacy-preferences`, `GET /api/privacy/policy`  
**Proxy:** `CoreApiProxyController` → core-api `/api/user/privacy-preferences`, `/api/privacy/policy`.

| # | Langkah | Ekspektasi |
|---|---------|------------|
| 1.1 | Login sebagai student, buka **Settings** → tab **Privasi** | Tab load tanpa error merah |
| 1.2 | DevTools → Network: `GET /api/user/privacy-preferences` | `200`, body berisi preferensi (`data` atau field flat — UI membaca keduanya) |
| 1.3 | Toggle salah satu switch (mis. analytics visibility) | `PUT` sukses, pesan sukses di UI, reload tab → nilai persist |
| 1.4 | Klik link kebijakan privasi (jika ada) → `GET /api/privacy/policy` | `200`, konten kebijakan (JSON/HTML sesuai API) |

**Gagal umum:** `502` dari Laravel → core-api down atau `CORE_API_URL` salah; `401` → session/JWT proxy.

---

## 2. Retention policies (admin only)

**UI:** Settings → tab **Retensi Data** (hanya `userRole === 'admin'`).  
**BFF:** `/admin/api/retention-policies` (GET, PUT `/{id}`, DELETE `/{id}`).

| # | Langkah | Ekspektasi |
|---|---------|------------|
| 2.1 | Login admin → Settings → **Retensi Data** | Daftar policy load (`result.data` array) |
| 2.2 | Edit satu baris (retention days / archive / auto purge) → simpan | `PUT` `200`, nilai di tabel update |
| 2.3 | (Opsional) Hapus policy custom jika ada di seed | `DELETE` + CSRF header → item hilang dari list |

**Non-admin:** tab Retensi Data **tidak** muncul di daftar tab.

---

## 3. AI message relevance (discussion direction)

**Alur:** Student kirim pesan di chat room → socket `send_message` → core-api batch classify (~5s debounce) → event `message_classified` → UI update `isRelevant`.

| # | Langkah | Ekspektasi |
|---|---------|------------|
| 3.1 | Student buka `/student/courses/{course}/chat/{chatSpace}` dengan goal terisi | Room connect socket, history load |
| 3.2 | Kirim 1–2 pesan on-topic terhadap goal | Pesan tampil; setelah ~5 detik (tanpa spam), relevance bisa ter-update (badge/indikator jika ada di UI) |
| 3.3 | DevTools / log core-api | Tidak error berulang `Discussion direction classification`; jika AI engine mati → fallback semua `isRelevant: true` (tanpa crash) |
| 3.4 | AI engine log | `POST /api/classify-relevance` terpanggil dengan `messages` + `goal` |

**HealthScoreCard:** Di room yang sama, komponen skor kesehatan tampil jika goal + pesan ada; tidak error `useMemo` / state order.

**Prasyarat:** `LearningGoal` untuk `chatSpaceId` ada; `CORE_API_SECRET` valid.

---

## 4. Lecturer discussion health widget

**BFF:** `GET /api/lecturer/discussion-health` → core-api `DiscussionHealthService.listForLecturer`.

| # | Langkah | Ekspektasi |
|---|---------|------------|
| 4.1 | Login lecturer, buka halaman yang memuat `DiscussionHealthWidget` (dashboard lecturer / analytics overview — sesuai layout app) | Widget loading lalu data atau empty state |
| 4.2 | Network: `GET /api/lecturer/discussion-health` | `200`, `{ chatSpaces: [...] }` dengan `healthScore` per item (dari server, bukan klien) |
| 4.3 | Klik item diskusi | Navigasi ke `/lecturer/courses/{courseId}/groups` (route chat lecturer dedicated belum ada) |
| 4.4 | Course tanpa chat aktif | Empty state “Tidak ada diskusi aktif” |

**Catatan performa:** Service saat ini query `ChatLog` per chat space (N+1); smoke OK untuk data kecil; monitor latency jika banyak space.

---

## 5. Regresi cepat (opsional)

```bash
# core-api
cd Kolabri-core-api && npm run test:run -- src/services/dashboard-cache.test.ts

# AI engine — compile route discussion direction
cd Kolabri-ai-engine && python3 -m py_compile app/api/routes/discussion_direction.py
```

---

## Checklist penutup P0

- [x] 1.x Privacy (Playwright 2026-06-11: load + PUT 200 setelah CSRF fix)
- [x] 2.x Retensi (admin) (Playwright: tabel kebijakan load)
- [ ] 3.x Classify + HealthScoreCard di student chat (butuh seed student + chat)
- [ ] 4.x Widget lecturer (butuh login lecturer + `/dashboard`)
- [ ] Env `AI_ENGINE_URL` + `CORE_API_SECRET` tercatat di runbook lokal

Setelah semua centang, update `tasks.md` change usability-04 untuk item yang benar-benar terverifikasi, lalu pertimbangkan archive change.

---

## Referensi file

| Area | Path |
|------|------|
| AI classify/summary | `Kolabri-ai-engine/app/api/routes/discussion_direction.py` |
| Socket classify | `Kolabri-core-api/src/socket/index.ts` |
| Discussion health API | `Kolabri-core-api/src/services/discussion-health.service.ts` |
| BFF proxy | `Kolabri-client-app/app/Http/Controllers/CoreApiProxyController.php`, `routes/web.php` |
| Privacy / retention UI | `resources/js/pages/settings/components/PrivacyTab.tsx`, `RetentionPolicyTab.tsx` |
| Student room | `resources/js/pages/student/chat/room.tsx` |
| Lecturer widget | `resources/js/components/lecturer/DiscussionHealthWidget.tsx` |