# Playwright manual smoke — 2026-06-11

**Prasyarat:** `php artisan serve`, `npm run dev` (Vite `127.0.0.1:5173`), core-api `:3000`.

## Hasil

| # | Skenario | Status | Catatan |
|---|----------|--------|---------|
| 1 | Login admin `admin@kolabri.id` / `password` | ✅ | Redirect `/admin/dashboard` |
| 2 | Settings → tab **Privasi** load | ✅ | 3 toggle + kebijakan |
| 3 | GET BFF `/api/user/privacy-preferences` | ✅ | 200 (network) |
| 4 | Toggle privasi → PUT | ✅ **setelah fix** | Awal **419** (tanpa CSRF); fix `X-CSRF-TOKEN` di `PrivacyTab.tsx` → **200** |
| 5 | Settings → **Retensi Data** (admin) | ✅ | Tabel kebijakan (Pengguna, Kursus, Grup, …) via BFF |
| 6 | Login lecturer / student demo | ✅ | Setelah `npm run db:seed`: `budi.santoso@univ.ac.id` / `andi.pratama@student.ac.id` + `password123` |
| 7 | Widget **Kesehatan Diskusi** | ✅ | `/dashboard` dosen: **16 diskusi aktif**, `GET /api/lecturer/discussion-health` **200**, skor per grup dari API |
| 8 | Student chat + HealthScoreCard | ✅ | IF201 Kelompok B: kirim pesan OK; **Kesehatan Diskusi** skor **0** (✗) tampil setelah ada pesan |

## Fix produksi dari smoke

- `PrivacyTab.tsx`: tambah `X-CSRF-TOKEN` pada PUT (selaras `RetentionPolicyTab`).

## Seed demo (2026-06-11)

```bash
cd Kolabri-core-api && npm run db:seed
```

- **Hati-hati:** seed demo **menghapus** user admin lama (`admin@kolabri.id`). Restore admin tanpa reset demo: `cd Kolabri-core-api && npx tsx prisma/seed-admin.ts` → `admin@kolabri.id` / `password`.
- **Kredensial demo** (dari `seed-demo-data.ts`):
  - Dosen: `budi.santoso@univ.ac.id` / `password123`
  - Mahasiswa: `andi.pratama@student.ac.id` / `password123`
- Fix seed: `seedQdrantPointsForDemoCourses` di-skip jika belum diimplementasi (seed tidak gagal di akhir).

## Ulangi otomatis + e2e

```bash
SMOKE_LECTURER_EMAIL=budi.santoso@univ.ac.id SMOKE_LECTURER_PASS=password123 \
SMOKE_STUDENT_EMAIL=andi.pratama@student.ac.id SMOKE_STUDENT_PASS=password123 \
./scripts/run-smoke-checklist.sh
```

```bash
cd Kolabri-client-app
TEST_LECTURER_EMAIL=budi.santoso@univ.ac.id TEST_LECTURER_PASSWORD=password123 \
TEST_STUDENT_EMAIL=andi.pratama@student.ac.id TEST_STUDENT_PASSWORD=password123 \
npx playwright test tests/e2e/student-group-chat.spec.ts
```