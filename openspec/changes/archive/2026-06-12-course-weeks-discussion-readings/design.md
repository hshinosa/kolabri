## Context

Kolabri memiliki pool materi course (`MaterialsTab`, modul manual), chat spaces tanpa `week_id`, sidebar chat dengan placeholder, goal Bloom tanpa validasi minggu, dan RAG tanpa filter minggu sesi. Spesifikasi produk lengkap: `docs/weekly-readings-discussion-spec.md`.

Stack: Laravel BFF (`Kolabri-client-app`), Express + Prisma (`Kolabri-core-api`), FastAPI RAG (`Kolabri-ai-engine`).

**Ground truth (audit):** `ChatSpace` / `LearningGoal` / `KnowledgeBase` live in **core-api Prisma**. `MaterialModule` + `CourseMaterial` + file storage today live in **Laravel only** (`LecturerMaterialsController`). There is no `week_id` on chat spaces, no pre-read, no citation metadata on messages.

## Goals / Non-Goals

**Goals:**

- Minggu resmi per course (`week_index`, `title` only) + assign materi dari pool.
- Chat space wajib terikat minggu; banyak sesi per minggu.
- Alur mahasiswa: sesi → pre-read → goal → chat.
- Panel chat: materi minggu N, minggu lalu, dikutip AI (bawah); satu modal viewer.
- RAG chat sesi: `week_index ≤ N`, boost minggu N, exception by score.
- Goal validation longgar + Socratic hint pada draft.
- Enforce cap materi di API view/download dan retrieval.

**Non-Goals:**

- Deskripsi panjang per minggu.
- Section “rekomendasi bacaan” terpisah di panel chat.
- RAG full silabus / mode dosen di chat mahasiswa (dokumentasi nanti).
- Redesign dashboard dosen global.
- Mengganti `fr-ai-04` course-page recommendation flow.

## Decisions

### 0. Material & week source of truth (Laravel + core-api)

**Decision:** **Course weeks and week–material assignment remain in Laravel** (extend existing `MaterialModule` → `CourseWeek` semantics or add `course_weeks` table in Laravel DB with `week_index` + `title`, pivot to `course_materials`). **core-api** stores `ChatSpace.week_id` (UUID referencing Laravel week id), pre-read completion, goal/RAG orchestration, and enforces cap by calling BFF/internal APIs or shared IDs. **Do not** duplicate full `CourseMaterial` binary metadata in Prisma unless a later sync phase is explicitly added.

**KnowledgeBase (Prisma):** On material assign/reindex, ingestion MUST set `week_index` (and/or `week_id`) on KB rows/chunks used for session RAG.

**Shared database (`kolabri-db`):** Core tables (`chat_spaces`, `knowledge_bases`, …) are **Prisma-owned**; `course_materials` / week tables are **Laravel-owned** (see `Kolabri-client-app/docs/DATABASE_ARCHITECTURE.md`). Laravel MUST NOT alter Prisma core tables directly; week assign side-effects call core-api ingest/reindex (HTTP or internal job).

**Canonical material id (student UX):** Panel, pre-read, modal viewer, and citation chips use **`course_materials.id`** (Laravel UUID). Each `knowledge_bases` row used for RAG SHOULD store **`course_material_id`** (nullable until linked) plus **`week_index`** after assign. Citations in AI messages reference **`course_material_id`**, not KB id, so cap checks and file open use one id.

**Laravel → KB pipeline (MVP):** On upload or week assign (or existing course KB upload flow if separate), core-api creates/updates `knowledge_bases` and vector index with `course_material_id` + `week_index`. Document exact trigger in ADR §0.1 (assign-only vs upload+assign).

**Alternatives considered:**
- Full material move to Prisma — rejected for MVP (large migration, duplicate storage).
- Weeks only in core-api without Laravel — rejected (upload/UI already Laravel).

### 1. `CourseWeek` + pivot (Laravel), link ChatSpace in core-api

**Decision:** Week entity: `week_index`, `title` only; pivot assign pool materials. Migrate existing `MaterialModule` rows to weeks where titles imply “Minggu N”. `ChatSpace.week_id` in Prisma points to Laravel week id.

**Alternatives:** Reuse `MaterialModule` name without `week_index` — rejected (cap RAG/pre-read needs explicit index).

### 2. `ChatSpace.week_id` required for new student discussion spaces

**Decision:** New/create flows require week selection; existing spaces migration script assigns default week or prompts lecturer fix.

**Alternatives:** Optional week — rejected (breaks cap RAG and pre-read).

### 3. Pre-read as dedicated route/step, not part of goal page

**Decision:** Inertia page or gated middleware: `chat_space` without `pre_read_completed_at` (or goal) redirects to pre-read until “Lanjut”.

**Alternatives:** Embed in goal create — rejected per product order.

### 4. Single `DocumentViewerModal` component

**Decision:** Shared React modal; BFF proxies signed/stream URL with week cap check.

**Alternatives:** New tab default — rejected per UX agreement.

### 5. Citations as structured AI response + persistence

**Decision:** AI/engine returns `citations[]` on scaffolding messages; core-api stores on message metadata; client renders inline chips and appends unique materials to “Dikutip” panel (below week lists, dedupe with week list).

### 6. RAG week filter at orchestration layer (core-api → ai-engine)

**Decision:** Pass `max_week_index`, `session_week_index`, `course_id`; engine boosts chunks where `week_index === session_week_index`, allows lower weeks only if score beats top session-week candidate threshold.

**Alternatives:** Client-side filter only — rejected (security + consistency).

### 7. Goal validation via AI engine or core-api LLM call

**Decision:** On goal submit, send `draft`, `week.title`, material titles/snippets; return `accepted | revise` + `socratic_hint` (no alternate goal topic unless `severely_off_topic`).

**Alternatives:** Keyword-only — rejected (too strict/loose per product).

## Risks / Trade-offs

- **[Risk] KB chunks lack week metadata** → Mitigation: backfill on assign/reindex; block RAG week cap until indexed.
- **[Risk] Two material paths (Laravel file vs `knowledge_bases`) diverge** → Mitigation: `course_material_id` on KB; single canonical id for UI/citations; ingest on assign per ADR 0.3.
- **[Risk] Migration breaks existing chat spaces** → Mitigation: default week + lecturer UI to reassign.
- **[Risk] Modal PDF large files** → Mitigation: paginated viewer, loading state, optional download within cap.
- **[Risk] Citation spam fills panel** → Mitigation: dedupe by `material_id`, section fixed at bottom.

## Migration Plan

1. Deploy schema + APIs (weeks, assign) without enforcing chat `week_id`.
2. Lecturer creates weeks, assigns materials; migrate modules → weeks.
3. Enable week required on new chat spaces; backfill `week_id`.
4. Enable pre-read gate + panel + modal.
5. Enable RAG week cap + citations + goal validation.
6. Rollback: feature flags per surface (pre-read, RAG filter, goal AI check).

## Open Questions

- PDF viewer: embed only vs download-only for unsupported types?
- Exact score threshold for “older week beats current week” in RAG (tune in ai-engine config; default documented in ai-engine config).

## Resolved (implementation default)

- **Pre-read completion:** Persist **per user per chat space** (`user_id` + `chat_space_id` + `pre_read_completed_at`). Re-entering the same space after completion skips pre-read; new space requires pre-read again.
