## Why

Diskusi dan materi kuliah saat ini belum terikat **minggu perkuliahan** secara konsisten: dosen mengelola file lewat modul manual, mahasiswa membuat ruang diskusi tanpa konteks minggu, panel bacaan di chat masih placeholder, dan goal Bloom tidak divalidasi terhadap topik minggu. Tanpa `week_id` dan cap akses materi, AI chat tidak bisa dipercaya untuk scaffolding yang selaras silabus.

Perlu satu alur: dosen assign materi per minggu (judul saja) → mahasiswa sesi per minggu (banyak sesi OK) → pre-read → goal → chat dengan materi panel, sitasi inline, RAG cap minggu N, dan validasi goal longgar + Socratic hint.

Referensi produk: `docs/weekly-readings-discussion-spec.md`.

## What Changes

- **Course weeks:** entitas minggu (`week_index`, `title` only) + pivot assign materi dari pool upload bebas.
- **Chat spaces:** wajib `week_id`; tampilkan judul minggu di seluruh alur sesi.
- **Mahasiswa:** gate **pre-read** setelah sesi dibuat, sebelum goal; daftar materi ≤ minggu N (fokus N).
- **Panel kanan chat:** materi minggu N, materi minggu lalu (collapsible), **Dikutip dalam diskusi** di bawah — **tanpa** section terpisah “rekomendasi bacaan”.
- **Modal viewer** tunggal untuk chip sitasi dan klik file di panel/pre-read.
- **AI chat sesi:** sitasi inline; RAG corpus `week_index ≤ N`, prioritas minggu N, minggu lalu hanya jika skor relevansi lebih baik.
- **Goal:** validasi coherent vs judul + materi minggu (longgar); revisi via **Socratic hint** pada draft mahasiswa, bukan topik goal baru.
- **API enforce:** view/download materi dan retrieval patuh cap minggu sesi.

Tidak mengubah kontrak `fr-ai-04` rekomendasi topik di halaman course (endpoint terpisah). RAG “mode lain” (dosen/full index) **out of scope** MVP — hanya dicatat di design.

## Capabilities

### New Capabilities

- `course-weeks`: CRUD minggu per course, assign/unassign materi dari pool, judul saja.
- `session-week-binding`: Chat space terikat minggu; banyak sesi per minggu; label minggu di UI.
- `week-material-access`: Cap akses materi `week_index ≤ N`; prioritas tampilan minggu aktif.
- `discussion-pre-read`: Layar daftar materi setelah buat/pilih sesi, sebelum goal, dengan Lanjut.
- `chat-week-materials-panel`: Sidebar chat — materi minggu, minggu lalu, dikutip AI (bawah).
- `document-viewer-modal`: Modal in-app untuk preview/buka dokumen (sitasi + panel).
- `ai-citation-chips`: Chip sitasi inline di jawaban AI scaffolding + persist untuk panel dikutip.
- `session-rag-week-cap`: Filter/boost RAG chat grup mahasiswa per minggu sesi.
- `week-aligned-goal-validation`: Validasi goal Bloom coherent + Socratic hint on reject.
- `knowledge-week-metadata`: Week fields on KB/chunks when materi di-assign ke minggu.

### Modified Capabilities

- `reading-recommendations` (change `fr-ai-04`): Tetap untuk course-page by topic; **tidak** menggantikan panel materi minggu di chat sesi.

## Impact

- **Kolabri-client-app (Laravel):** Course weeks + material assign (extend/evolve `MaterialModule` / `course_materials`), BFF pre-read routes, tab Minggu, material stream with week cap, week picker on session create.
- **Kolabri-core-api:** Prisma `ChatSpace.week_id`, pre-read completion, chat space create validation, goal validation orchestration, citation metadata on messages, RAG request params to ai-engine.
- **Kolabri-ai-engine:** Chunk `week_index`, ranking boost N, structured citations; reject/filter future-week sources.
- **Docs:** `docs/weekly-readings-discussion-spec.md`, `DATABASE_ARCHITECTURE.md`, design §0 (material SoT + `course_material_id` ↔ KB).
