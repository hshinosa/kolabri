## Context

SRS v2 + SCOPE_NOTES_2026-07-20 mendefinisikan Future Works. Routes product di `web.php` sudah di-strip. Residual files masih di repo.

## Goals / Non-Goals

**Goals:** dead-code free product surface; build/tests green; no orphan Wayfinder routes.

**Non-Goals:** fitur baru; full DB migration drop tables if still referenced by history (prefer soft remove app layer first).

## Decisions

1. **Strip routes first (done)** → then delete files in this change.
2. **Keep inline AI chat experience** (stream/send); only remove dedicated template/bookmark pages.
3. **Dosen analytics remain** (UC-012).
4. **Agent-owned execution** — implementer agent follows `tasks.md`; no drive-by deletes outside checklist.

## Risks

- Ziggy/typed routes break if names still referenced in TS
- Core-api still serves endpoints — orphan OK short-term, clean second phase
- Master-data UI may still show template panel UI chrome — remove panel JSX in tasks

## Migration Plan

1. Grep remaining imports of removed controllers/routes
2. Delete files + update seeder
3. Fix TS/PHP tests
4. Manual smoke: student chat, reflections history, ai-chat personal, admin master-data (no templates), lecturer analytics
