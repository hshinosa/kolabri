# ADR 002: Week id and material cap API contract

**Status:** Accepted  
**Date:** 2026-06-12  
**Change:** `openspec/changes/course-weeks-discussion-readings`  
**Depends on:** ADR 001

## Week id contract (Laravel ↔ core-api)

| Field | Type | Notes |
|-------|------|--------|
| `course_weeks.id` | UUID v4 | Laravel PK; stable for life of week row |
| `course_weeks.course_id` | UUID | Must match Prisma `courses.id` |
| `course_weeks.week_index` | int ≥ 1 | Official week number for cap/RAG (`1…N`) |
| `course_weeks.title` | string | Display only; no long description in MVP |
| `ChatSpace.week_id` | UUID nullable → required | Stores Laravel `course_weeks.id` |

**Validation (core-api on create/update chat space):**

1. `week_id` present (for new student discussion spaces once feature enabled).
2. BFF or internal call: week by id + `course_id` from `group.courseId` — week belongs to same course.
3. Reject if week missing or course mismatch (`400`).

**No Prisma FK** to `course_weeks`; Laravel owns week rows.

## Material cap semantics

For a chat space with session week **N** (`week_index = N`):

- **Allowed materials:** all `course_materials` assigned to weeks where `week_index ≤ N` for that `course_id`.
- **Denied:** any material only on weeks with `week_index > N`.

Cap applies to: pre-read list, chat panel lists, modal stream/view, citation resolution, server-side RAG filter.

### Pool ingest and RAG (unified Materi tab)

When a lecturer uploads to the **pool** (no week assign yet), KB ingest may create chunks **without** `week_index` in metadata. Session-scoped RAG with an active week cap (`max_week_index`) **must exclude** chunks where `week_index` is missing or null — pool-only vectors must not appear in week-capped chat retrieval until the material is assigned and re-ingested with `week_index`.

Implementation: `Kolabri-ai-engine/app/services/week_rag.py` → `week_metadata_filter()`; tests in `tests/test_unit/test_week_rag.py`.

## BFF / Laravel endpoints (existing + planned)

### Existing (lecturer; extend for weeks)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/lecturer/courses/{course}/materials` | List modules/materials (evolve to weeks) |
| POST | `/lecturer/courses/{course}/materials` | Upload to pool |
| POST | `/lecturer/courses/{course}/materials/{materialId}/view` | Record view |

Prefix `/lecturer` per `routes/web.php` middleware group.

### Planned (student / session) — tasks §3, §5, §6

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/student/groups/{group}/chat-spaces/{chatSpace}/materials` | Panel + pre-read lists (cumulative ≤ N) |
| GET | `/student/courses/{course}/materials/{materialId}/stream` | Modal viewer; **403** if week > session N |
| GET | `/lecturer/courses/{course}/weeks` | Week CRUD list (task 2.1) |
| POST | `/lecturer/courses/{course}/weeks/{weekId}/materials` | Assign from pool (triggers ADR 001 ingest) |

## core-api (illustrative internal)

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/internal/knowledge-base/link-course-material` | Create/update KB from Laravel material + `week_index` |
| PATCH | `/internal/knowledge-base/{id}/week` | Update week metadata on reassign |

## core-api chat space API change

`GroupService.createChatSpace` accepts `week_id` (task 4.4):

```ts
createChatSpace(groupId, { name, description?, week_id }, userId, userRole)
```

## References

- `Kolabri-core-api/src/services/group.service.ts` — `createChatSpace` today: `{ name, description? }` only.
- `openspec/.../specs/week-material-access/spec.md`
- `openspec/.../specs/session-week-binding/spec.md`