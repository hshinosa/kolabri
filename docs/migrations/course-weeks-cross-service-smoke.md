# Cross-service smoke: course weeks → pre-read → goal → chat (§10.1)

**Change:** `openspec/changes/course-weeks-discussion-readings/` task 10.1  
**Type:** manual QA checklist (automated E2E optional later).

## Prerequisites

| Service | Port | Env |
|---------|------|-----|
| Laravel BFF | 8000 | Session JWT; `services.api.base_url` → core-api |
| core-api | 3000 | Prisma migrated; Mongo for chat logs |
| ai-engine | 8001 | RAG / goal validation reachable from core-api |

**Secrets (assign → KB ingest):** `CORE_API_INTERNAL_SECRET` same on Laravel (`services.api.internal_secret`) and core-api internal routes. If missing, assign still works in Laravel but KB link is skipped (log warning).

**Test accounts:** one **lecturer**, one **student** enrolled in the same course with an active **group** and at least one **chat space** (or create via UI).

---

## A. Lecturer — Materi (unified tab: upload + weeks + KB status)

1. Login lecturer → open course detail → tab **Materi** (single hub; no separate Materials / Minggu / Basis Pengetahuan).
2. **Upload:** PDF from `docs/sample-materials/*.pdf` (e.g. IF211 `bc0061ab-decf-430a-842e-e7e8ea11afa0`) → badge **Menunggu indeks** / **Memproses** → **Siap AI** when ingest done (poll ~3s while in-flight).
3. If `CORE_API_INTERNAL_SECRET` unset: banner **Konfigurasi indeks AI tidak aktif**; upload still succeeds.
4. **Create week:** `week_index=1`, title e.g. `Pendahuluan`.
5. **Assign** pool material to week 1 → material on week card; pool count decreases.
6. **Verify API:** `GET /lecturer/courses/{course}/materials-hub` → `materials`, `pool`, `weeks`, `kb_by_material_id`.
7. **Verify KB (secret set):** after upload, KB row with `course_material_id`, nullable week; after assign, `week_id` + `week_index=1`.

**Automated partial:** `LecturerCourseWeeksApiTest`, `LecturerMaterialsHubApiTest`, `CourseControllerTest` (KB `course_material_id`).

**G5 spot-check:** PDF → Siap AI; docx/pptx/txt → ingest or Gagal badge; zip → upload OK, index may fail.

---

## B. Chat space bound to week (core-api + BFF)

1. Ensure group chat space has `week_id` = UUID from step A (create new space after weeks exist, or `PATCH` week on space / run backfill per `docs/course-weeks-migration-notes.md`).
2. Student sees **week title** on session list / chat header.

**Automated partial:** `GroupChatSpaceWeekBindingTest` (Laravel feature).

---

## C. Student — pre-read gate (BFF → core-api)

1. Login student → open course → enter chat space for week 1 **before** completing pre-read.
2. Expect redirect or block to **pre-read** flow: `GET …/chat-spaces/{id}/pre-read`.
3. Open materials in modal viewer (week cap ≤ N).
4. **Complete pre-read:** `POST …/pre-read/complete` → can proceed to goal.

**Automated partial:** `StudentPreReadGateTest`.

---

## D. Goal — week-aligned validation

1. Navigate to `…/chat-spaces/{id}/goal`.
2. Submit **off-topic** goal → response `revise` + `socratic_hint` in UI; draft preserved.
3. Submit **coherent** goal (references week topic/materials) → `accepted` → enter chat.

**Automated partial:** core-api `goal.service.test.ts`, `WeekContextService` mocks.

---

## E. Chat — panel + citations (client + core-api + ai-engine)

1. Send message that should trigger scaffolding/RAG (week-filtered).
2. **Panel:** week materials listed; **Dikutip** section appends cited materials (dedupe vs week list).
3. **Inline citation chips** on assistant message → click opens **same modal viewer** as panel.
4. History reload: citations present on `chat_history` / pagination payloads.

**Automated partial:**

- core-api: `citationFilter.test.ts`
- client: `cited-materials.test.ts`, `citationFilter` / `mapSocketDisplayMessage` tests
- ai-engine: `pytest tests/test_unit/test_week_rag.py`

---

## F. Sign-off

| Step | Pass | Notes |
|------|------|-------|
| A Lecturer week + assign | ☑ | Playwright 2026-06-12: IF211 tab Minggu, created **Minggu 1: Smoke Pendahuluan** (assign skipped — pool 0 materi). Screenshot `smoke-a-lecturer-minggu.png`. |
| B `week_id` on chat space | ☐ | Sesi demo **Diskusi Utama** masuk chat langsung; judul minggu tidak tampil di header — kemungkinan `week_id` belum di-bind (data lama). |
| C Pre-read gate | ☐ | URL pre-read → redirect ke chat; goal sudah ada (data demo). Gate: `StudentPreReadGateTest` pass. |
| D Goal accept / revise | ☐ | Tidak diuji UI (goal sudah terset). Unit: `goal.service.test.ts` pass. |
| E Chat panel + citations | ◐ | Chat load + panel **Materi diskusi** (memuat); kirim pesan/@ai tidak diuji (WS error sporadis). Unit tests pass. |

Date / tester: **2026-06-12 / agent Playwright smoke**

**Infra during run:** core-api was **down** until fix `GroupController.leave` + `removeMember` (routes referenced undefined handlers). After fix: `/health` 200. Laravel :8000 OK. ai-engine :8001 up.

---

## Quick command bundle (regression, not full smoke)

```bash
cd Kolabri-client-app && php artisan test \
  tests/Feature/LecturerCourseWeeksApiTest.php \
  tests/Feature/LecturerMaterialsHubApiTest.php \
  tests/Feature/LecturerMaterialKbHooksTest.php \
  tests/Feature/StudentPreReadGateTest.php \
  tests/Feature/GroupChatSpaceWeekBindingTest.php

cd Kolabri-core-api && npm test -- --run citationFilter goal.service 2>/dev/null || npx vitest run src/utils/citationFilter.test.ts src/services/goal.service.test.ts

cd Kolabri-ai-engine && python3 -m pytest tests/test_unit/test_week_rag.py -q
```