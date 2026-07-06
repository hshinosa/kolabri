## 0. Implementation gates (see `gates.md`)

- [x] 0.1 G4: Session RAG excludes chunks with null/missing `week_index` when week cap active (ai-engine and/or core-api + test)
- [x] 0.2 G5: Align Materi upload MIME allowlist with ingest capability or explicit non-indexed UX (UI partial; full MIME matrix manual)
- [x] 0.3 G7: Material `destroy` unlinks or soft-deletes linked KB rows (internal call)
- [x] 0.4 G6: Empty internal secret — warning UX + test
- [x] 0.5 Confirm G1–G3 + G8 checklist in `gates.md` before starting §3

**Do not start §3 or §4 until 0.5 and backend gates (G1–G4, G7) are done.**

## 1. Core-api — KB contract & pool queue

- [x] 1.1 Add `CourseMaterialKbService.queuePoolMaterial()` (nullable week, pending → ingest, idempotent with link)
- [x] 1.2 Add `POST /api/internal/knowledge-base/queue-course-material` + Zod schema + tests
- [x] 1.3 Extend `KnowledgeBaseService.getCourseFiles` to return `courseMaterialId` in each row
- [x] 1.4 Unit/integration tests: queue on upload payload; assign still uses link endpoint

## 2. Laravel — hooks & BFF

- [x] 2.1 Add `CoreApiInternalClient::queueCourseMaterial()` calling new internal route
- [x] 2.2 Call queue from `LecturerMaterialsController::store` after successful create (absolute file path)
- [x] 2.3 Map `course_material_id` in `CourseController::knowledgeBaseIndex` JSON
- [x] 2.4 **(G1 — mandatory)** Aggregated `GET` lecturer materials-hub: all `course_materials` + weeks + assignments; pool = not assigned to any week regardless of `module_id` (no triple-fetch-only workaround)
- [x] 2.5 Feature tests: material upload triggers mocked internal queue; KB index includes `course_material_id`

## 3. Frontend types & UnifiedMaterialsTab

- [x] 3.1 Extend `KnowledgeBase` type with `course_material_id?: string`
- [x] 3.2 Create `UnifiedMaterialsTab.tsx`: upload (POST `/materials`), flat material list with vector badge (join by `course_material_id`), week CRUD + assign/unassign + drag-reorder (`POST weeks/reorder`), single `fetchHub` + poll KB while in-flight
- [x] 3.3 Advanced upload options: extract_images / perform_ocr — wired Laravel → core-api → ai-engine; checkboxes default on in `UnifiedMaterialsTab`
- [ ] 3.4 Legacy orphan KB subsection (read-only) if rows without matching material id
- [x] 3.5 Remove module CRUD from UI; do not mount `MaterialsTab` / `CourseWeeksTab`

## 4. Course detail shell cleanup

- [x] 4.1 `CourseDetailTabs`: single `materi` tab replaces `materials` + `weeks`
- [x] 4.2 `show.tsx`: render only `UnifiedMaterialsTab`; **delete** Basis Pengetahuan section (upload form, KB lists, hybrid localMaterials fallback)
- [x] 4.3 Remove orphaned state from `show.tsx`: `knowledgeBase`, `kbPolling`, KB `useForm`, `materialModules`, `unassignedMaterials`, `localMaterials`, hybrid stat derivations — replace stats with hub-driven or course-only metrics
- [x] 4.4 Update copy that references “tab Materials” / Basis Pengetahuan upload

## 5. Docs, QA, archive

- [x] 5.1 Update `docs/course-weeks-cross-service-smoke.md`: one Materi tab for upload + assign + wait for vector ready
- [ ] 5.2 Manual QA: upload → pending → ready without KB batch; assign week → pre-read; secret missing (G6); upload non-PDF per G5; chat RAG after pool-only ingest does not leak null-week chunks (G4)
- [x] 5.3 Regression: Laravel hub/weeks/KB tests + `LecturerMaterialKbHooksTest` + `internal.controller.test.ts`
- [x] 5.4 Archive change; merge specs into `openspec/specs/` (2026-06-12)
