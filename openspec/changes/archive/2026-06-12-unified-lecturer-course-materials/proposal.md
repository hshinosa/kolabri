## Why

Dosen menghadapi **tiga permukaan** untuk file yang sama: tab **Materials** (modul), tab **Minggu** (pool + assign), dan section **Basis Pengetahuan** (upload batch terpisah ke vector). Modul adalah legacy `lecturer-course-detail`; spesifikasi `course-weeks` sudah mendefinisikan **pool + assign minggu** tanpa modul. Duplikasi membingungkan, memungkinkan file masuk RAG tanpa `course_material_id`/minggu, dan status “siap AI” terpisah dari pre-read/chat.

User meminta **disatukan sepenuhnya** — refactor besar diterima demi UX yang rapi dan satu mental model: **satu Materi hub** = upload, daftar file, assign minggu, status vector, tanpa upload kedua.

## What Changes

- **Satu tab “Materi”** menggantikan tab **Materials** + **Minggu** pada detail kelas dosen.
- **Hapus section Basis Pengetahuan** (upload + daftar terpisah) dari `show.tsx`; semua fungsi relevan pindah ke tab Materi.
- **Satu jalur upload** → `course_materials` (Laravel SoT); setelah upload sukses → **internal core-api** mengantri KB (`pending` → ingest) tanpa upload batch kedua.
- **Satu daftar materi** per course: semua `course_materials` (termasuk yang dulu di modul), badge **vector_status** per baris, assign ke minggu di UI yang sama.
- **API kontrak:** KB list dan BFF **wajib** menyertakan `course_material_id` untuk join UI; internal route baru untuk **queue ingest pool** (week opsional/null).
- **MaterialModule:** UI dosen dihapus (CRUD modul); data DB tetap; materi modul tampil flat di daftar unified. **BREAKING** UX lecturer.
- **Upload KB batch** (`CourseController::uploadKnowledgeBase`) tidak lagi pintu utama dosen; boleh dipertahankan hanya sebagai **lanjutan/admin** (collapse/hidden) atau dihapus dari halaman kelas — keputusan implementasi di design.
- Smoke doc + stat cards header diselaraskan dengan satu sumber kebenaran (unified tab / aggregated counts).

Tidak mengubah: cap materi mahasiswa per minggu, pre-read, goal, RAG week cap, alur student pre-read/chat.

## Capabilities

### New Capabilities

- `lecturer-unified-materials`: Satu hub dosen — upload, daftar lengkap, assign minggu, status KB, polling, tanpa modul/modul-tab/KB section terpisah.

### Modified Capabilities

- `course-weeks`: Lecturer SHALL manage pool + week assignment only from unified Materi hub; modul bukan organisasi wajib; pool SHALL include all course materials eligible for week assign (not only `whereDoesntHave(weeks)` subset yang mengabaikan modul).
- `knowledge-week-metadata`: KB ingest SHALL trigger on pool material upload (internal queue) and on week assign (existing link); metadata week diperbarui saat assign/unassign/move.
- `session-rag-week-cap`: Week-capped chat RAG SHALL exclude chunks without `week_index` (pool ingest sebelum assign).

### Implementation gates

Blocking sebelum UI cutover: `gates.md` (G1–G8).

## Impact

- **Kolabri-client-app:** `UnifiedMaterialsTab` (baru); `show.tsx` besar (hapus KB block ~300+ baris, state hybrid); `CourseDetailTabs`; deprecate `MaterialsTab`/`CourseWeeksTab` dari layout; `LecturerMaterialsController::store` + hook internal; optional `LecturerMaterialsController::index` unified shape; `CourseController::knowledgeBaseIndex` + `course_material_id`; types `KnowledgeBase`.
- **Kolabri-core-api:** `internal.controller` + route `queue-course-material`; `CourseMaterialKbService` pool queue; `KnowledgeBaseService.getCourseFiles` return `courseMaterialId`; tests.
- **Kolabri-ai-engine:** G4 null-week exclusion in week-capped RAG (`week_rag.py` / retrieval filter).
- **Docs/QA:** `gates.md`, `course-weeks-cross-service-smoke.md`, catatan migrasi dosen.
