# Implementation gates (blocking)

Tidak boleh merge / ship UI unified (§3–§4) sampai **semua gate G1–G8** lulus. Gate dicatat di PR / handoff.

## G1 — Pool & hub data (P0)

- [x] Lecturer hub returns **every** `course_materials` row for the course (including former `module_id` children).
- [x] Unassigned pool = no week pivot link (not “only unassigned AND module_id null”).
- [x] Bukti: `LecturerMaterialsHubApiTest` (modul-only in pool).

## G2 — KB list join key (P0)

- [x] `GET` knowledge-base (core-api + BFF) includes `course_material_id` / `courseMaterialId` per row when set.
- [x] Bukti: `CourseControllerTest::test_knowledge_base_index_returns_snake_case_rows`.

## G3 — Upload → queue ingest (P0)

- [x] `LecturerMaterialsController::store` calls internal `queue-course-material` after create (when secret set).
- [x] `CourseMaterialKbService.queuePoolMaterial` creates/updates KB with `course_material_id`, nullable week, triggers ingest.
- [x] Assign path still uses `link-course-material` without regression (`LecturerCourseWeeksApiTest`).
- [x] Bukti: `LecturerMaterialKbHooksTest` (upload queue + destroy delete) + `internal.controller.test.ts` (queue/delete).

## G4 — Session RAG excludes null-week chunks (P0)

Pool ingest may leave `week_index` null on chunks until assign. **Session-scoped group chat RAG** MUST NOT treat null `week_index` as eligible when `max_week_index` / week cap filter is active.

- [x] Document behavior in `docs/adr/002-week-id-and-material-cap-contract.md` (pool ingest + RAG).
- [x] Implement filter in ai-engine and/or core-api RAG request path (exclude missing `week_index` when cap applies).
- [x] Bukti: `pytest tests/test_unit/test_week_rag.py` (5 passed).

## G5 — Upload MIME vs ingest (P1, blocking for non-PDF)

- [x] UI: accept list + copy PDF utama; badge skipped / Tidak diindeks (`UnifiedMaterialsTab`).
- [ ] Full parity zip/gif vs ai-engine — manual verify (optional before archive).
- [x] Bukti: G5 spot-check line in `docs/course-weeks-cross-service-smoke.md` § A.

## G6 — Internal secret degraded mode (P1)

- [x] When `CORE_API_INTERNAL_SECRET` empty: upload materi succeeds; UI shows **konfigurasi indeks AI tidak aktif** (not silent).
- [x] Bukti: `LecturerMaterialKbHooksTest::test_upload_skips_queue_when_internal_secret_empty` + UI copy in `UnifiedMaterialsTab`.

## G7 — Material delete vs KB (P1)

- [x] `LecturerMaterialsController::destroy` soft-deletes or marks KB rows linked by `course_material_id` (core-api internal unbind/delete), **or** documented exception with follow-up task ID in this change.
- [x] Bukti: `LecturerMaterialKbHooksTest::test_destroy_posts_delete_course_material_kb` (BFF hook); core-api `softDeleteForCourseMaterial` in service.

## G8 — Regression before UI cutover (P0)

- [x] `php artisan test` — `LecturerCourseWeeksApiTest`, `CourseControllerTest` (KB index), `LecturerMaterialsHubApiTest`.
- [x] `npm test:run` — `internal.controller.test.ts` (queue/delete); full suite optional.
- [x] `StudentPreReadGateTest` / `WeekMaterialAccessServiceTest` pass (no student regression).

---

## Phase order (hard)

| Phase | Sections | Allowed when |
|-------|----------|--------------|
| A | §1 + §2 + G1–G3, G4, G7 | Always start here |
| B | §3 `UnifiedMaterialsTab` | G1–G3 + G8 (backend) green |
| C | §4 strip `show.tsx` | B smoke: upload→badge→assign→pre-read |
| D | §5 archive | All G1–G8 checked |

## Optional (post-MVP, not blocking ship)

- OCR/extract on material ingest path (task 3.3 backend wiring).
- Legacy orphan KB footer (3.4) if no orphans in env.
