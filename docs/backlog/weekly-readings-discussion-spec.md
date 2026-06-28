# Spesifikasi: Minggu, materi, sesi diskusi, bacaan, RAG, sitasi & goal

**Status:** sebagian besar diimplementasi (MVP minggu, pre-read, panel, sitasi, goal revise).
**OpenSpec:** `openspec/changes/course-weeks-discussion-readings/` (implementasi; materi SoT Laravel, `course_material_id` canonical, KB `week_index` + link material).  
**ADR:** `docs/adr/001-course-weeks-materials-architecture.md`, `docs/adr/002-week-id-and-material-cap-contract.md`.

---

## 1. Tujuan

- Dosen: pool upload bebas + **kartu per minggu** (`week_id`, **judul saja**).
- Mahasiswa: **banyak sesi per minggu**, semua terikat `week_id`.
- Bacaan, rekomendasi, RAG chat sesi, sitasi AI, dan goal Bloom selaras minggu dengan aturan di bawah.

---

## 2. Dosen

| Topik | Keputusan |
|--------|-----------|
| Upload | Bebas → **pool materi** course |
| Kartu minggu | `week_index` + **judul**; **tanpa deskripsi** |
| Assign | Pilih file dari pool → masuk minggu (banyak file, bisa pindah) |
| UI | Detail mata kuliah (Materi / Minggu), bukan wajib dashboard global |

---

## 3. Mahasiswa — sesi & tampilan

- **Banyak ruang/sesi per minggu** — OK; wajib **`week_id`** sama untuk minggu itu.
- Tampilkan **`week_id` + judul minggu** di: pilih sesi, pre-read, header chat, panel bacaan.

---

## 4. Akses materi & rekomendasi (cap minggu N)

| Boleh | Tidak |
|--------|--------|
| Materi minggu **1 … N** | Minggu **N+1, …** |

- **Prioritas UI:** fokus **Minggu N**; minggu 1…N−1 collapsible “materi sebelumnya”.
- **Enforce** di API download/view, bukan hanya UI.
- **Bukan** section terpisah “rekomendasi bacaan” di panel chat — daftar bacaan = **materi minggu** (+ minggu lalu) di panel; sitasi AI di blok bawah (§6).

---

## 5. Alur mahasiswa (urutan final)

```
Buat / pilih sesi diskusi (pilih week_id)
    ↓
Pre-read: daftar bacaan/materi (≤ N, fokus N) — baca dulu
    ↓
Tombol "Lanjut"
    ↓
Buat goal (Bloom + validasi coherent vs judul + materi minggu)
    ↓
Chat room
```

Pre-read **setelah** sesi ada, **sebelum** goal — bukan sebelum buat sesi.

---

## 6. Panel kanan (chat)

**Tidak ada** blok terpisah “rekomendasi bacaan” — bacaan = **materi minggu sesi** + **materi minggu sebelumnya** (sumber yang sama seperti pre-read, cap ≤ N).

**Urutan atas → bawah:**

1. **Materi minggu N** (assign dosen)
2. **Materi minggu sebelumnya** (opsional, collapsible)
3. **“Dikutip dalam diskusi”** — hanya sumber yang **disitasi AI** di jawaban chat sesi ini; **selalu di bawah** blok materi minggu (supaya minggu tidak tenggelam)

Sitasi baru → nambah di section 3 (dedupe). File yang sudah ada di materi minggu 1–2 **tidak perlu diduplikasi** di “Dikutip” kecuali produk ingin badge “dari AI” — default: chip inline + buka via modal; panel bawah untuk sumber sitasi yang belum obvious di list atas (kebijakan UI bisa dedupe ke satu entry).

Ganti sidebar dummy “Sumber Daya Bersama” di `chat/room.tsx`.

---

## 7. Sitasi AI (scaffolding)

- **Chip kecil inline** di teks jawaban (seperti ChatGPT/Gemini).
- Klik chip → buka dokumen (hanya sumber `≤ N`).
- Panel bawah mengumpulkan sumber yang disitasi di sesi.

---

## 8. Modal viewer dokumen (satu untuk semua)

**Satu komponen modal viewer** untuk:

- Klik **chip sitasi** di chat
- Klik **file di panel materi minggu / pre-read**

**Tidak** buka tab baru sebagai default — tetap di app, tidak pindah-pindah tab.

Opsional nanti: “buka di tab baru” di dalam modal jika dibutuhkan.

---

## 9. RAG — chat sesi mahasiswa (Minggu N)

| Aturan | Detail |
|--------|--------|
| Corpus | Chunk materi **`week_index ≤ N`** saja |
| Prioritas | Utamakan **Minggu N** |
| Pengecualian | Minggu 1…N−1 ikut hanya jika **similarity/score lebih relevan** vs kandidat terbaik minggu N |
| Minggu depan | **Tidak** untuk chat mahasiswa |

---

## 10. RAG / retrieval — catatan untuk nanti (bukan scope MVP)

**Bukan** longgaran chat sesi mahasiswa. Hanya catatan jika nanti ada fitur lain:

| Konteks | Corpus (contoh) |
|---------|------------------|
| Chat sesi mahasiswa (Minggu N) | **≤ N** (aturan di §9) |
| AI / tools dosen | Bisa seluruh course atau minggu bebas |
| Rekomendasi topik di halaman course (`fr-ai-04`) | KB course — endpoint terpisah dari chat sesi |
| Indexing sistem | Index semua minggu; **filter per endpoint** |

Implementasi “mode lain” **ditunda**; chat grup mahasiswa tetap cap ≤ N.

---

## 11. Goal + Bloom

- Goal harus **coherent** dengan **judul minggu + materi assign minggu itu** (bukan cuma judul).
- **Tidak terlalu strict** — variasi OK, bahasan minggu bisa luas.
- **Tolak / minta revisi:** balas **Socratic hint** yang mengait **draft goal mahasiswa** + minggu aktif — **bukan** mengganti topik goal lain.
- Topik lain hanya diarahkan balik kalau **jelas ngawur** (off minggu / tidak ada kaitan wajar).

---

## 12. Model data (konsep)

```
CourseWeek       — course_id, week_index, title
CourseMaterial   — pool
CourseWeekMaterial — pivot
ChatSpace        — week_id
Citation         — message, material_id, page (untuk chip + panel bawah)
```

Chunk indexing: `week_id` / `week_index` untuk RAG, sitasi, cap akses.

---

## 13. Sudah vs belum (codebase)

| Sudah | Belum / lanjutan |
|--------|--------|
| `CourseWeek` + pool + tab Minggu (lecturer) | Hapus sepenuhnya UI modul legacy (tab Materials = pool + banner) |
| Pre-read gate, cap N, panel materi minggu | Smoke manual: `docs/course-weeks-cross-service-smoke.md` (E2E terotomasi penuh opsional) |
| Modal viewer + sitasi inline + blok Dikutip | Feature flags opsional bila diperlukan |
| Goal week validation + `socratic_hint` + draft | RAG mode dosen/indeks penuh (§15) |

## 15. RAG mode lain (deferred)

- **Chat sesi mahasiswa:** indeks terfilter `week_index ≤ N`, boost minggu N (`week_rag.py`).
- **Dosen / indeks penuh course:** belum produk MVP; dokumentasi saja sampai ADR mode kedua disepakati.

---

## 14. Checklist keputusan

- [x] Minggu: `week_id` + judul; tanpa deskripsi
- [x] Upload bebas; assign per minggu
- [x] Banyak sesi per minggu; `week_id` wajib
- [x] Materi (panel & pre-read) ≤ N; prioritas N; **tanpa** section “rekomendasi bacaan” di panel chat
- [x] RAG sesi mahasiswa ≤ N; prioritas N; minggu lalu by score
- [x] Sitasi inline; panel sitasi **di bawah** bacaan minggu
- [x] **Satu modal viewer** — sitasi & daftar materi
- [x] Pre-read setelah sesi, sebelum goal
- [x] Goal: Socratic hint pada draft, bukan topik baru
- [x] RAG role lain: dokumentasi nanti, bukan MVP chat sesi

---

*Terakhir diperbarui dari diskusi spesifikasi produk Kolabri TA.*