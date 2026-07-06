## 0. Architecture alignment

- [x] 0.1 Document ADR: weeks + materials in Laravel; `ChatSpace.week_id` + pre-read in core-api; KB week metadata on assign/reindex
- [x] 0.2 Define week id contract (UUID shared Laravel ↔ core-api) and BFF endpoints core-api may call for material cap checks
- [x] 0.3 ADR: Laravel→core-api ingest trigger (upload vs week assign); canonical `course_material_id` for panel, viewer, citations

## 1. Data model & migration

- [x] 1.1 Laravel: `course_weeks` (or evolve `MaterialModule` with `week_index`) + week–material pivot; keep pool upload on `course_materials`
- [x] 1.2 Laravel migration: map existing modules to weeks; orphan handling doc
- [x] 1.3 Prisma: `ChatSpace.week_id`, `ChatSpacePreReadCompletion` (user_id, chat_space_id, completed_at)
- [x] 1.4 Backfill `week_id` on existing chat spaces; lecturer path to fix unassigned spaces
- [x] 1.5 Prisma: extend `KnowledgeBase` with `week_index`, optional `week_id`, `course_material_id` (migration + generate)

## 2. Course weeks API & lecturer UI

- [x] 2.1 Laravel API: CRUD weeks, assign/unassign/reorder materials on weeks
- [x] 2.2 BFF: proxy week APIs + lecturer course tab "Minggu" (title only, assign from pool)
- [x] 2.3 Deprecate or align legacy `MaterialModule` UI with week cards (single UX)
- [x] 2.4 Tests: week CRUD, assign, lecturer auth

## 3. Week material access enforcement

- [x] 3.1 Service (Laravel or BFF): allowed materials for session week N (`week_index ≤ N`)
- [x] 3.2 Enforce cap on material view/download/stream (used by modal viewer)
- [x] 3.3 Student API/BFF: list materials for chat space (week N primary + earlier collapsible)
- [x] 3.4 Tests: deny week N+1, allow cumulative 1…N

## 4. Session week binding (student)

- [x] 4.1 Require `week_id` on chat space create (client + core-api); week picker on create modal
- [x] 4.2 Show week title on chat-spaces list, pre-read, goal header, chat room (pre-read UI deferred to §5)
- [x] 4.3 Tests: create without week fails; multiple spaces same week OK
- [x] 4.4 core-api `group.service` / create chat space API: accept and persist `week_id` (validate week belongs to course)

## 5. Pre-read gate

- [x] 5.1 BFF routes: pre-read show + complete (`web.php` + controller)
- [x] 5.2 Pre-read Inertia page: material list per week-material-access rules
- [x] 5.3 Guards: redirect goal/chat until pre-read complete (per user per space)
- [x] 5.4 Flow: create space → pre-read → goals/create → chat (update `getChatSpaceUrl` / redirects)
- [x] 5.5 Feature tests / e2e smoke for gate order

## 6. Chat panel & document viewer (client-app)

- [x] 6.1 Replace dummy "Sumber Daya Bersama" with week materials + earlier weeks + dikutip (bottom)
- [x] 6.2 Shared `DocumentViewerModal` (panel + pre-read + citation chips)
- [x] 6.3 Fetch materials by `chat_space_id` / week context

## 7. KB indexing & session RAG (ai-engine + core-api)

- [x] 7.0 On assign/move material: update `KnowledgeBase` / chunk `week_index` (reindex job)
- [x] 7.1 Pass `session_week_index`, `max_week_index` on group chat AI retrieval
- [x] 7.2 Ranking: boost week N; older weeks only if score beats top week-N candidate (config threshold)
- [x] 7.3 Tests: no future-week retrieval; boost behavior

## 8. AI citations (ai-engine + core-api + client)

- [x] 8.0 Prisma: store citations on `ChatMessage` (JSON/metadata column or `chat_message_citations` table) with `course_material_id`
- [x] 8.1 Structured `citations[]` on scaffolding responses (`course_material_id`, page, label); strip future-week refs server-side
- [x] 8.2 Persist citations on message metadata (core-api)
- [x] 8.3 Inline chips in chat; modal on click
- [x] 8.4 "Dikutip" panel: append only if not already in week lists (dedupe by material_id)
- [x] 8.5 Tests: cap citations; panel order; dedupe

## 9. Week-aligned goal validation

- [x] 9.1 Orchestration: validate with week title + material titles/snippets (ai-engine or core-api)
- [x] 9.2 API contract: `accepted` | `revise` + `socratic_hint` on failure (fix goal.service return shape)
- [x] 9.3 `goals/create.tsx`: show hint, keep draft on revise
- [x] 9.4 Tests: coherent accept; revise hint; severe off-topic steer

## 10. Verification, rollout & docs

- [x] 10.1 Cross-service smoke: lecturer week + assign → student session → pre-read → goal → chat panel (checklist: `docs/course-weeks-cross-service-smoke.md`; automated slices in §F)
- [x] 10.2 Feature flags (optional): pre-read gate, RAG week filter, goal week validation — per design migration
- [x] 10.3 Update `docs/weekly-readings-discussion-spec.md` when shipped
- [x] 10.4 Deferred RAG modes (lecturer/full index): design note only
