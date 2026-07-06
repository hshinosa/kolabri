## Context

Hari ini:

| Permukaan | Data | KB |
|-----------|------|-----|
| Materials tab | Laravel `/materials`, modul + unassigned | Tidak |
| Minggu tab | `/weeks` pool (`whereDoesntHave weeks`) + assign | Hanya **on assign** via `link-course-material` |
| Basis Pengetahuan | `POST` batch core-api + poll GET KB | Ya, tanpa `course_material_id` |

Internal `link-course-material` **wajib** `week_id` + `week_index` (Zod). Upload materi **tidak** memanggil internal client.

User intent: **full unify** — tidak masalah ubah banyak file.

## Goals / Non-Goals

**Goals:**

- Satu tab **Materi**: upload, flat list semua file course, kolom/status vector, kartu minggu + assign/unassign/reorder.
- Upload Laravel → **selalu** queue KB (jika secret configured) dengan `course_material_id`, week null sampai assign.
- Assign minggu → update week metadata + re-ingest jika perlu (existing `linkCourseMaterial`).
- Hapus Basis Pengetahuan section dari halaman kelas; satu coordinator polling di tab Materi.
- Join UI deterministik via `course_material_id` (bukan `file_name` fallback kecuali legacy orphan KB).
- Stat cards “materi / proses” dari aggregated unified state atau simplified counts.

**Non-Goals:**

- Drop tabel `material_modules` atau migrasi data modul ke minggu otomatis.
- Redesign student materials browser (kecuali broken link).
- Menghapus core-api batch upload API (bisa tetap untuk tooling); hanya **bukan** UX utama dosen.

## Decisions

### 1. Full UI merge (bukan incremental cross-link)

**Decision:** Replace `materials` + `weeks` tabs with `materi`; delete KB upload/list section from `show.tsx`; implement `UnifiedMaterialsTab` as sole lecturer material surface.

**Rationale:** User explicitly accepts large refactor for clean UX.

### 2. New internal endpoint: queue pool material

**Decision:** Add `POST /api/internal/knowledge-base/queue-course-material` with body: `course_id`, `course_material_id`, `file_path`, `file_name`, `mime_type`, `file_size`, `uploaded_by`; `week_id` / `week_index` **optional**.

**Service:** `CourseMaterialKbService.queuePoolMaterial()` — create/update KB row, `weekId`/`weekIndex` null if omitted, set `pending`, call `ingestDocument` with metadata (week fields null). Reuse idempotency: if `ready` and path unchanged, skip re-ingest.

**Assign path:** Keep existing `link-course-material` (required week) — updates week fields and re-ingest if needed.

**Rationale:** Current Zod schema cannot represent pool-only upload; extending link schema would blur semantics.

### 3. Laravel hook on every material upload

**Decision:** `LecturerMaterialsController::store` after create → `CoreApiInternalClient::queueCourseMaterial(...)` (new method), mirror assign’s absolute path resolution.

**Rationale:** Satisfies “no second upload” without lecturer using KB batch.

### 4. Unified material list semantics

**Decision:** Materi tab loads:

1. **All** `CourseMaterial` for course (flat), including former module children.
2. **Weeks** + assignments from existing `/weeks` API.
3. **KB rows** from BFF GET with `course_material_id`.

Pool UI = materials **not assigned to any week** (computed client-side or server flag `assigned_week_ids[]`). Assigned materials appear on week cards **and** may be hidden from “pool” column — not duplicate upload paths.

**Change:** Weeks `index` pool query SHOULD align: pool = materials with no week assignment (regardless of `module_id`), OR unified endpoint `GET /lecturer/courses/{id}/materials-hub` returning `{ materials[], weeks[], kbByMaterialId{} }` — **prefer single BFF aggregate in same change** to avoid triple fetch races.

**Rationale:** Modul-hidden files must not disappear when deprecating Materials tab.

### 5. KB list contract

**Decision:** `KnowledgeBaseService.getCourseFiles` and Laravel `knowledgeBaseIndex` mapping include `course_material_id` / `courseMaterialId`.

**Rationale:** Required for per-row vector badge; background review confirmed no join today.

### 6. Basis Pengetahuan on course page

**Decision:** **Remove** from `show.tsx`. Optional “Unggah langsung ke indeks (legacy)” only if product insists — default **removed**.

OCR/extract toggles move to unified upload **advanced** section (same options forwarded to ingest if ai-engine supports on material path).

### 7. Orphan KB rows (no `course_material_id`)

**Decision:** Show in Materi tab footer “File indeks tanpa materi kelas (legacy)” read-only + delete/retry if API exists; do not mix into main list join.

## Implementation gates

Blocking checklist: **`gates.md`** (G1–G8). UI cutover (§3–§4) only after backend gates and G8 regression green.

### G4 — RAG null-week (added per review)

**Decision:** When session chat uses week cap (`max_week_index`), retrieval filter MUST exclude vector chunks whose metadata has **no** `week_index` (pool-only ingest before assign). Prevents unassigned corpus from appearing in week N sessions.

**Where:** Prefer `week_metadata_filter` extension in ai-engine (`week_rag.py`) or equivalent filter in core-api before calling ai-engine.

### G5 — MIME vs ingest

**Decision:** Materi hub upload allowlist defaults to types proven on material ingest path (minimum `application/pdf`). Other types allowed for download/pre-read only with UI label “belum diindeks AI” until batch/ingest supports them.

### G7 — Delete material

**Decision:** Not optional for this change: `destroy` must call internal KB unlink/soft-delete for matching `course_material_id`.

## Risks / Trade-offs

- **[Risk] Double ingest upload + assign** → Mitigation: service checks `ready` + same path; assign only re-ingest if week/path changed.
- **[Risk] `CORE_API_INTERNAL_SECRET` empty** → Gate G6: UI + test; upload materi tetap untuk mahasiswa/pre-read.
- **[Risk] Delete material without KB cleanup** → Gate G7 (required).
- **[Trade-off] BFF aggregate** → Gate G1: materials-hub mandatory, not optional triple-fetch.

## Migration Plan

1. Backend: internal queue + KB list `course_material_id` + Laravel upload hook.
2. BFF aggregate (or aligned pool query) + tests.
3. `UnifiedMaterialsTab` + tab shell; feature-complete on staging.
4. Strip `show.tsx` KB section and hybrid stats; wire stats to hub or static course metrics only.
5. Update smoke doc; lecturer comms (modul & KB upload lama diganti).

## Open Questions (resolved for implementation)

- **Pool ingest on upload?** **Yes** — `queue-course-material` with null week.
- **OCR/extract?** **Yes** — advanced on unified upload; pass through to ingest options where supported (else document parity with batch).
