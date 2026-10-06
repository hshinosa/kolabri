# E2E Flow Test — Semua Alur (live, produksi kolabri.web.id)

**Tanggal:** 6 Oktober 2026 · **Metode:** pengujian otomatis end-to-end terhadap produksi —
HTTP cookie-session Laravel (login otomatis), core-api + Socket.IO lewat tunnel SSH sumo1 `:13000`,
verifikasi langsung PostgreSQL & MongoDB, lalu render UI nyata via headless Chrome (CDP).
**Eksekutor:** Hermes (agentik). **Suite:** `e2e_flows/flows.js` (43 tes).

**Hasil run final: 42 PASS · 0 FAIL · 1 SKIP** (SKIP = uji "gabung kelas" sengaja tak diulang
di run akhir karena sudah terbukti di run sebelumnya — dijaga flag, agar tidak menambah
enrollment baru).

> Run 1–4 dipakai untuk kalibrasi harness (bukan bug aplikasi): `my-group` kosong ternyata
> `200 {data:null}` (bukan status error), tujuan SMART harus selaras materi minggu (validator
> menolak yang tidak nyambung), uji "keluar kelompok" tidak bisa di kelas ber-`min_members=2`.
> Sesi uji gagal dari run 1–2 sudah di-soft-delete.

---

## 1. Flow Mahasiswa — diskusi penuh (inti)

| # | Tes | Status | Bukti |
|---|---|---|---|
| 1 | Login Andi → `/student/courses` | ✅ | 302 → halaman 200 |
| 2 | Daftar kelas terdaftar | ✅ | 9 kelas, IF203 ada |
| 3 | Detail kelas + kelompok | ✅ | `Kelompok A` `e3b74cf5…` |
| 4 | Gabung kelas dengan kode (Dewi, IF203 `ZZHGET`) | ✅ | terverifikasi di `/courses/enrolled` |
| 5 | Buat kelompok (Lisa/IF206) + kode | ✅ | id `939a7ac5…`, kode `K9M26S93` |
| 6 | Gabung kelompok dengan kode (Fajar) | ✅ | `my-group` joiner terisi |
| 7 | Keluar dari kelompok | ✅ | `Left group successfully` + `my-group` kosong lagi |
| 8 | Daftar minggu → buat sesi diskusi | ✅ | redirect ke pre-read, id sesi terbaca |
| 9 | Gerbang pre-read tampil & selesai → redirect tujuan | ✅ | 200 → redirect `/goal` |
| 10 | Validasi tujuan: tanpa kata kerja Bloom | ✅ ditolak | pesan error Bloom; `myGoal` tetap null |
| 11 | Validasi tujuan: Bloom tapi non-SMART | ✅ ditolak AI | core-api `400` + pertanyaan balik: *"Bagaimana cara mengukur hasil analisis kelompokmu…?"* |
| 12 | Validasi tujuan: SMART + selaras materi | ✅ lolos | lolos pada percobaan ke-2 (percobaan 1 ditanya detail data) |
| 13 | Halaman chat room render | ✅ | 200 |
| 14 | Socket join + muat riwayat | ✅ | gate pre-read & goal berfungsi (tanpa goal → `GOAL_REQUIRED`) |
| 15 | Kirim pesan → bertahan setelah muat ulang | ✅ | koneksi baru, riwayat tetap memuat pesan |
| 16 | Edit pesan (socket) → tersimpan | ✅ | Mongo: `editedAt=10:04:48.852Z`, `version=1` |
| 17 | Hapus pesan (socket) → tersimpan | ✅ | Mongo: `deletedAt=10:04:49.108Z`, hilang dari riwayat |
| 18 | `@ai` → jawaban streaming | ✅ | 1374 karakter, `senderType=ai` |
| 19 | Riwayat final (4 pesan, 1 AI) | ✅ | |
| 20 | Tutup sesi | ✅ | `closedAt` + `closedBy` terisi |
| 21 | Ringkasan AI terbuat saat tutup | ✅ | 743 karakter, akurat (menyebut pesan & AI) |
| 22 | Ringkasan tetap ada setelah muat ulang (API) | ✅ | GET segar → 743 karakter |
| 23 | Refleksi pasca-sesi | ✅ | `201`, baris `reflections` ada |
| 24 | Status sesi: `isClosed` + refleksi | ✅ | `hasGoal=true`, `hasReflection=true` |

## 2. Flow Dosen — sampai jadi hasil analisis

| # | Tes | Status | Bukti |
|---|---|---|---|
| 1 | Login Budi (pemilik IF203) → halaman kelas | ✅ | 200 |
| 2 | Aktivitas diskusi per mahasiswa | ✅ | `total=94`, Andi `23` pesan, `6` mahasiswa aktif |
| 3 | `discussion-health` **saat sesi masih terbuka** | ✅ | skor `33`, `hasGoal=true`, `2` pesan, `1` anggota aktif |
| 4 | **Hasil analisis sesi** `GET /api/analytics/session-discussion/:id` | ✅ | `totalMessages=4, student=2, aiMentions=1, goals=1, reflections=1, qualityScore=60, timeline=4`, rekomendasi: *"Diskusi berjalan dengan baik dan berkualitas tinggi…"* |
| 5 | Dosen membaca ringkasan AI sesi | ✅ | 743 karakter — **identik** dengan ringkasan yang dihasilkan saat penutupan |
| 6 | Negatif: dosen non-pemilik (Siti) | ✅ ditolak | `403 You do not own this course` |
| 7 | `discussion-health` pasca-tutup | ✅ | sesi uji hilang dari widget (widget = sesi terbuka saja) |
| 8 | Analytics kelas / overview / recent / dashboard-charts | ✅ | semua `success:true`; skor rata-rata kelas ikut naik setelah sesi uji |
| 9 | 6 halaman analytics dosen render | ✅ | `/lecturer/analytics`, course analytics, detail, students, comparison (dgn `course_ids[]`), radar → semua 200 |
| 10 | Halaman kehadiran + auto-attendance | ✅ | **render nyata (headless Chrome):** tab "Attendance" menampilkan *"Kehadiran Mahasiswa → Sesi Kehadiran"* berisi **"Auto Attendance - E2E Analisis Dosen 1"** + kontrol "Dikoreksi" |
| 11 | Halaman analytics dosen render nyata | ✅ | *"Analitik · 8 kelas · ringkasan kualitas diskusi"* + kartu IF203 **Skor kualitas: 59/100** |

## 3. Flow Admin

| # | Tes | Status |
|---|---|---|
| 1 | Login `admin@kolabri.id` → `/admin/dashboard` | ✅ |
| 2 | 5 halaman (dashboard, users, master-data, ai-settings, audit-logs) | ✅ 5/5 200 |

## 4. Bukti tersimpan di DB (bukan klaim API semata)

```
Postgres session 44d354a0…  : closed_at=2026-10-06 10:04:49.704, summary ada (743 chr)
learning_goals              : "Menganalisis materi minggu ini tentang Algoritma Sorting & Searching…"
reflections                 : refleksi Andi 10:04:49.959
attendance_sessions         : "Auto Attendance - E2E Analisis Dosen 1" (auto, 10:04:49.727)
attendance_records          : Andi, notes "2 pesan, 2 HOT"
Mongo chatlogs (sesi tsb)   : 5 dokumen — edit (editedAt/version=1), hapus (deletedAt), 1 balasan AI
```

## 5. Temuan baru / lanjutan

### ⚠️ F4 (MASIH BUKA) — ringkasan tak pernah tampil setelah muat ulang, akar sudah diketahui
- API-nya sehat: GET summary → **200, 743 karakter** (terbukti lagi di tes atas).
- Dengan instrumentasi jaringan (CDP) pada muat ulang ruang chat sesi tertutup: **0 permintaan
  `/summary`** (yang terbit hanya `/materials`).
- **Akar kode:** `resources/js/pages/student/chat/room.tsx:662` —
  `const [isSummaryVisible, setIsSummaryVisible] = useState(false);` dan satu-satunya
  `setIsSummaryVisible(true)` ada di baris 579 (alur menutup sesi di halaman yang sama).
  `useChatSummary` di-baris 750 memakai `enabled: isSummaryVisible`, jadi halaman segar tidak
  pernah fetch. **Perbaikan sederhana:** init dari `sessionDiscussion.isClosed`
  (mis. `useState(!!sessionDiscussion.isClosed)`).

### ⚠️ F10 — Analisis per-sesi & ringkasan tidak punya permukaan di UI dosen
- `GET /api/analytics/session-discussion/:id` (qualityScore, rekomendasi, timeline pesan,
  statistik peserta) **tidak dipanggil oleh komponen mana pun** di `Kolabri-client-app`
  (grep seluruh `resources/js` + controllers). Datanya kaya dan benar — tapi hanya API.
- Ringkasan AI sesi hanya dirender untuk **mahasiswa** (`use-chat-summary`); tidak ada route
  atau komponen dosen yang menampilkannya.
- `DiscussionHealthWidget.tsx` **tidak pernah di-import** halaman mana pun (komponen mati),
  padahal route proxy `/api/lecturer/discussion-health` hidup dan datanya benar.
- Dampak: yang benar-benar *sampai ke layar dosen* dari diskusi adalah: aktivitas per mahasiswa,
  skor kualitas kelas/grup, dan kehadiran otomatis. Analisis sesi terlengkap & ringkasan AI
  berhenti di API.

### ℹ️ F11 — Kehadiran otomatis: `present = ≥3 pesan DAN ≥1 HOT` (`attendance.service.ts:5`)
- Sesi uji (2 pesan) → status `absent`, `0% hadir` — sesuai aturan, bukan bug. Tapi aturan ini
  tidak terkomunikasi di UI; sesi diskusi singkat otomatis bikin mahasiswa "tidak hadir".

### Regresi yang terbukti masih sehat
- Gate pre-read & goal di socket (`GOAL_REQUIRED` / `PRE_READ_REQUIRED`) berfungsi.
- Validator tujuan AI (tolak lemah, tanya balik, terima spesifik+berwaktu+selaras materi).
- Persistensi edit/hapus pesan (batch 2026-10-06) tetap hijau.
- Isolasi data: dosen lain ditolak 403; ringkasan/analisis hanya untuk pemilik kelas.

## 6. Residu data yang ditinggalkan (disengaja, untuk bukti)

- 3 sesi **"E2E Analisis Dosen 1"** (Kelompok A / IF203) — lengkap (goal, pesan, ringkasan,
  refleksi, auto-attendance). Sesi uji gagal dari run awal sudah di-soft-delete.
- Grup **"Kelompok Uji E2E"** IF206 (`K9M26S93`, Lisa + Fajar keluar lagi) — dipakai ulang
  untuk uji kelompok; grup uji di IF202 sudah dihapus.
- 1 enrollment Dewi di IF203 (uji gabung kelas).
- Sekitar 15 dokumen `chatlogs` uji di Mongo.

## 7. Rekomendasi → SEMUA DIKERJAKAN (batch kedua, 2026-10-06)

1. ✅ **F4 DIPERBAIKI** — `room.tsx` init `isSummaryVisible` dari `sessionDiscussion.isClosed`.
   **Verifikasi live:** instrumentasi jaringan CDP pada muat ulang ruang chat sesi tertutup kini
   menghasilkan `GET .../summary → 200` (sebelumnya 0), dan kartu **"Ringkasan Diskusi"** tampil
   di DOM hasil render React.
2. ✅ **F10 DIPERBAIKI** — tab baru **"Sesi & Analisis"** di halaman kelas dosen:
   - core-api: `GET /api/courses/:id/sessions` (lecturer-only, cek pemilik kelas) —
     daftar sesi + grup/minggu/tujuan/keadaan ringkasan/refleksi.
   - client-app: proxy `GET /lecturer/courses/{c}/sessions` dan
     `.../sessions/{sd}/detail` (gabung analisis + ringkasan) — `LecturerSessionInsightController`.
   - UI: `SessionsTab.tsx` — daftar sesi, ekspansi per sesi menampilkan **Tujuan, Ringkasan AI
     penuh, skor kualitas + rekomendasi, metrik, kontribusi per mahasiswa**; **`DiscussionHealthWidget`
     kini dirender** (sebelumnya komponen mati).
   **Verifikasi live (headless Chrome, akun Budi):** daftar berisi sesi uji; ekspansi menampilkan
   ringkasan 873 karakter + "Kualitas Diskusi 60/100 · Cukup" + rekomendasi lengkap + metrik
   (total pesan 4, @ai 1, refleksi 1, anggota 3) + kontribusi Andi (2 pesan, rata-rata 44 karakter).
3. ✅ **F11 DIPERBAIKI** — legenda aturan kehadiran otomatis di tab Attendance
   ("hadir = ≥3 pesan & ≥1 HOT… koreksi manual via Lihat Detail"), terverifikasi tampil di DOM.

**Regresi setelah deploy (suite yang sama): 42 PASS · 0 FAIL · 1 SKIP** — tidak ada alur yang rusak.
Build: core-api `tsc` bersih + **602 passed / 0 failed**; client-app `tsc` = 27 error baseline
(`@/routes/*` wayfinder) dan vitest 3 file gagal = baseline identik (bukan regresi).


## 8. Batch 3 (2026-10-06, lanjutan) — sisa route mahasiswa + audit dosen penuh

### Mahasiswa — semua route terpetakan vs teruji (13+9+13+3 = 38 tes baru)
Hasil akhir: **s2a 13/13 · s2b2 9/9 · s2c 13/13 · s2d 3/3 PASS**.
Terdiscovery & diperbaiki:
- **M1 (fix): `PUT /api/users/me` selalu 404** — core-api tidak punya endpoint itu sama sekali dan router user cuma di-mount di `/api/admin/users`. Edit profil (nama/email) dari UI mahasiswa tidak pernah bisa. Fix: tambah route `PUT /me` (semua role) + mount `/api/users` (endpoint admin tetap 403 untuk non-admin, terverifikasi).
- **M2 (fix): grup soft-delete masih bisa di-join** — `joinGroupByCode`/`inviteMembers`/`getGroupById` tidak memfilter `deletedAt`. Terbukti live: Fajar berhasil join grup yang sudah dihapus (baris `group_members` tercipta). Fix: guard `deletedAt: null` di 3 service; verifikasi: kode grup terhapus → 404 `Invalid join code`.
- **M3 (RESOLVED — dibuang): `PATCH /student/groups/{g}/members/{m}` (ubah role) →** keputusan: sistem hanya punya **ketua (createdBy) ↔ anggota**, jadi role admin di tengah anggota redundan. Route + method `updateRole` dihapus; `PATCH` ke path itu kini **405** (method hanya DELETE untuk keluarkan anggota). Regresi s2b2 (invite/keluar-kan/leave) tetap **9/9 PASS**.
- Bukan bug: avatar <100x100 ditolak (validasi by design); BFF form-error selalu 302 (uji harus assert state, bukan status).

### Dosen — 18+11+21 tes (batch L1/L2/L3), semua lulus setelah fix
- **D1 (fix): `GET /lecturer/courses/{c}/materials` → 500** — route menunjuk method `LecturerMaterialsController::index()` yang tidak pernah dibuat. Diimplement.
- **D2 (fix): minggu gagal di-reorder → 500** — `CourseWeekIndexService::renumberForCourse` update `week_index` satu per satu kena UNIQUE(course_id, week_index) saat dua minggu bertukar posisi. Fix: renumber dua fase (slot sementara negatif dulu).
- **D3 (fix): fitur analitik "Live Stats", "Tren", "Bagikan Laporan" mati total** — core-api tak punya endpoint `/analytics/courses/:id/live|trends|share` (semua 404) dan halaman Inertia `lecturer/analytics/shared` tidak ada. Diimplement: live (delegasi analytics course), tren per hari (engagement/completion/attendance dari chatlogs + sessionDiscussions), share token stateless (JWT+exp, tanpa tabel), halaman shared.tsx.
- **D4 (fix): `GET export-section` → 302** — BFF memanggil `GET /api/analytics/export` tanpa path course (route itu butuh `/:courseId`). Fix: alias `GET /export?courseId=`.
- Teruji PASS: kelas CRUD + arsip, weeks CRUD/reorder/assign/unassign, upload knowledge-base, materi CRUD + stats + view + reindex (antre indeks ok), grup dosen buat/tambah anggota/hapus, close-single (200 "Sesi ditutup, kehadiran dicatat"), kehadiran detail/override/summary/export/bulk-close/destroy, aktivitas + export CSV, analytics detail/students/benchmark, share → akses publik 200, search dosen.

**Regresi batch 3:** s2a/s2b2/s2c/s2d semua hijau setelah deploy; suite flows.js (43 tes) dijalankan ulang sebagai regresi penuh.
**Residu baru:** kelas arsip `E2EDSN1` (Kelas Uji Dosen E2E v2, kelompok Grup Uji Dosen + sesi Sesi Uji Dosen), sesi "Sesi Uji Close-Single" (tertutup, auto-absen), 2 grup uji dihapus lewat UI.


## 9. Batch 4 (2026-10-06) — Uji empiris retrieval RAG per-minggu di chat diskusi

Pertanyaan user: apakah AI di chat diskusi membaca knowledge base per minggu (mis. sesi minggu 3 bisa mengambil materi minggu 1), dan apakah dokumen yang terpanggil muncul di sidebar?

### Cara diuji
1. Upload materi unik (`partisi-lomuto-uji.txt`, penanda QUARK-LUMEN-7734) → assign ke **Minggu 1** IF203.
2. Buat sesi di **Minggu 3** (Analisis Kompleksitas), pre-read + tujuan SMART, tanya `@ai` tentang isi materi minggu 1.
3. Verifikasi: metadata chunk Qdrant, citations di socket, persistensi ChatLog, render sidebar via headless Chrome.

### Temuan & fix (4 bug, semua terpasang & terverifikasi)
- **R1 (client-app): assign materi ke minggu gagal re-ingest** — `LecturerCourseWeeksController::assignMaterial` mengirim `Storage::disk()->path()` (path container Laravel) ke core-api → "Source file not found on disk" → chunk tidak pernah dapat `week_index` → boost per-minggu mati. Fix: `CoreApiFilePath::resolve()` (shared volume `/shared-storage[-private]`), dipakai juga di MateriController (DRY).
- **R2 (ai-engine): ingest duplikat membuang metadata minggu** — idempotency `content_hash` men-skip total saat file sama (mis. assign ulang / reindex) → `week_index` tidak pernah menempel. Fix: `VectorStoreService.update_payload_metadata()` (merge ke chunk existing via `set_payload`) + dipanggil di jalur duplikat untuk kunci `week_index`/`week_id`/`course_material_id`.
- **R3 (ai-engine): jawaban ungrounded tanpa citations** — saat grounding check gagal, result scaffolding tidak menyertakan citations → dokumen hilang dari sidebar padahal retrieval sukses. Fix: `sources_to_citations` ikut disertakan di result ungrounded.
- **R4 (core-api): `@ai` pertama pasca-restart engine selalu gagal/kosong** — cold-start reranker cross-encoder ~45 detik (download model) > `LLM_TIMEOUT` 30s → stream dibatalkan sebelum citations terkirim. Fix: `STREAM_TIMEOUT` 120s khusus `orchestratedChatStream`.

### Hasil uji akhir (live)
- Sesi Minggu 3 → tanya materi Minggu 1: **5/5 PASS** — citations `[{partisi-lomuto-uji.txt h.1}, {if203-sorting-algorithm-comparison.pdf h.1}]`, materi minggu 1 terkutip lintas minggu ✓
- Metadata chunk Qdrant: `week_index=1, week_id=45486ac8-...` menempel setelah R1+R2 ✓
- **Sidebar UI (headless Chrome)**: ruang chat menampilkan tepat 2 dokumen yang dikutip (materi minggu 1) — "kalo dia terpanggil aja" ✓
- Regresi: core-api vitest **602/0**; subset engine (rag/vector/processor/grounding) **651 passed / 24 failed** — A/B buktikan **24 gagal identik di kode lama (pre-existing)**, bukan regresi.

### Desain retrieval (hasil telusur, diverifikasi)
- Filter ketat per-minggu **sengaja dimatikan** (`week_metadata_filter()` return None) — AI boleh baca seluruh kelas; chunk minggu sesi di-**boost** (margin skor 0.08) via `rank_week_boosted_results`.
- Sidebar dokumen = `aggregateCitedMaterials` dari pesan AI (citations), bukan seluruh materi minggu.

### Residu uji batch ini
- Materi `partisi-lomuto-uji.txt` (Minggu 1 IF203) + chunk meta-test di koleksi Qdrant IF203.
- 5+ sesi "Uji Retrieval Minggu" di Kelompok A IF203 (tertutup goal; @ai aktif di 2 sesi terakhir).
