# Course weeks migration notes

**Change:** `course-weeks-discussion-readings` (tasks 1.2, 1.4)

## Module → week mapping (1.2)

- Each legacy `material_modules` row becomes one `course_weeks` row per course.
- `week_index` is assigned **in `sort_order` order** within each `course_id` (1, 2, 3, …).
- `title` is copied from module title (may not match “Minggu N” pattern; lecturer can rename).
- Materials with `module_id` set are linked via `course_week_materials` pivot.

## Orphans

- **`course_materials` with `module_id` null:** remain in the **pool** only; not auto-assigned to any week.
- **`material_modules` with zero materials:** still create an empty week card.
- **Chat spaces without `week_id` (Prisma):** run internal backfill when ready:
  - `POST /api/internal/chat-spaces/backfill-week-ids?course_id={uuid}` with header `X-Internal-Secret` (`CORE_API_INTERNAL_SECRET`).
  - Assigns each unbound chat space in that course (or all courses if `course_id` omitted) to the **lowest `week_index`** week for the group’s course.
- **Lecturer fix for wrong/missing week:** `PATCH /api/groups/chat-spaces/:id/week` with `{ "week_id": "..." }` (BFF proxies when wired; core-api `GroupService.updateChatSpaceWeek`).

## Rollback

- Laravel migration `2026_06_12_000002_*` truncates `course_weeks` / pivot only; does not restore `module_id` links.

## Prisma

- Run `npx prisma migrate dev` in `Kolabri-core-api` after pulling schema changes for `week_id`, pre-read, KB columns.

## Smoke (10.1)

- Manual cross-service checklist: `docs/course-weeks-cross-service-smoke.md`.