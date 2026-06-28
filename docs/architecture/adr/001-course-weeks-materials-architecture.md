# ADR 001: Course weeks, materials, chat sessions, and knowledge base

**Status:** Accepted  
**Date:** 2026-06-12  
**Change:** `openspec/changes/course-weeks-discussion-readings`  
**Related:** `docs/weekly-readings-discussion-spec.md`, `openspec/.../design.md` §0

## Context

Kolabri today has:

- **Laravel:** `material_modules`, `course_materials` (pool + optional `module_id`), file storage, lecturer UI (`LecturerMaterialsController`).
- **core-api (Prisma):** `chat_spaces` without `week_id`, `knowledge_bases` per course (lecturer upload → ai-engine ingest), group chat RAG without week cap.
- **Shared DB** `kolabri-db` — see `Kolabri-client-app/docs/DATABASE_ARCHITECTURE.md`.

Product requires official **course weeks**, material assign per week, student **discussion sessions** bound to a week, pre-read, panel materials, citations, and RAG capped at session week N.

## Decision

### 1. Source of truth by domain

| Concern | Owner | Storage |
|--------|--------|---------|
| Course weeks (`week_index`, `title`) | **Laravel** | `course_weeks` (or evolved `material_modules` + `week_index`) + pivot to `course_materials` |
| Material pool & files | **Laravel** | `course_materials`, disk/`file_path` |
| Chat spaces, goals, messages | **core-api** | Prisma `chat_spaces`, `learning_goals`, `chat_messages` |
| Pre-read completion | **core-api** | Prisma `chat_space_pre_read_completions` (per user per space) |
| Vector corpus for RAG | **core-api** | Prisma `knowledge_bases` + ai-engine index |

Laravel **must not** alter Prisma-owned tables directly. Week assign side-effects call **core-api** over HTTP (ingest/reindex, internal service token).

### 2. Week id contract

- Week primary key: **UUID** (`course_weeks.id`), generated in Laravel.
- `ChatSpace.week_id` (Prisma): **opaque UUID**, no FK to Laravel table; validated at create/update via BFF or internal API (week exists, `course_id` matches group's course).

### 3. Canonical material id (student UX)

- **Panel, pre-read, modal viewer, citation chips:** `course_materials.id` (Laravel UUID).
- **KB row:** optional `course_material_id`, `week_index`, optional `week_id` after assign (Prisma migration §1.5).
- **Citations on messages:** reference `course_material_id`, not `knowledge_bases.id`.

### 4. Laravel → core-api ingest trigger (MVP)

**Chosen:** **On week assign** (and on **reassign** / move between weeks), Laravel calls core-api to create or update `knowledge_bases` and trigger ai-engine ingestion for that file.

**Pool upload alone** does **not** require KB row until the material is assigned to a week (or explicitly linked). Rationale: avoids indexing unused pool files; week metadata is known at assign time.

**Reindex:** When `week_index` / `week_id` changes on assign, core-api updates KB fields and re-tags or reindexes chunks.

**Legacy path:** Existing lecturer **course KB upload** via core-api (`KnowledgeBaseService.uploadFile`) remains for non–course-material flows until unified; new week-based materials use Laravel file + assign → core-api link API (task 7.0).

**Alternative rejected:** Ingest on every pool upload — duplicates work and leaves chunks without `week_index`.

### 5. KB week metadata

On assign/reindex, ingestion MUST set `week_index` (and `week_id` when available) on `knowledge_bases` and chunk metadata used for **session RAG** (`session-rag-week-cap`).

## Consequences

- Implement Laravel week CRUD and pivot before enforcing `ChatSpace.week_id`.
- core-api needs internal endpoints: link material → KB, patch week fields, optional cap-check helpers (ADR 002).
- Two upload paths temporarily coexist (legacy KB upload vs Laravel pool); converge in later phase if needed.

## Compliance

- Tasks: `0.1`, `0.3`, `1.5`, `7.0` in `openspec/changes/course-weeks-discussion-readings/tasks.md`.