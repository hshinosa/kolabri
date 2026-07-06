## Why

Kolabri has no data retention policy. Soft-deleted records accumulate indefinitely, ChatLog uses an inconsistent `isDeleted` boolean instead of the `deletedAt` timestamp pattern, and there is no automated cleanup or TTL mechanism. This violates NFR requirements for data retention and creates compliance risk as the platform grows.

## What Changes

- Standardize ChatLog soft delete from `isDeleted: boolean` to `deletedAt: DateTime | null` (with migration script) **BREAKING**
- Add a `DataRetentionPolicy` model to configure retention periods per data type (archive window, purge window, auto-purge toggle)
- Add admin UI for managing retention policies (CRUD table in settings)
- Add a scheduled cleanup job that archives and purges data based on configured policies
- Implement soft delete cascade: Course → Group → ChatSpace → KnowledgeBase (soft deleting a parent cascades to children)

## Capabilities

### New Capabilities
- `retention-policy-model`: Prisma model and CRUD API for configuring retention periods per data type
- `retention-cleanup-job`: Scheduled job that archives and purges data according to active policies
- `soft-delete-cascade`: Cascading soft delete from Course → Group → ChatSpace → KnowledgeBase
- `chatlog-delete-standardize`: Migration and code change to replace `isDeleted` with `deletedAt` on ChatLog

### Modified Capabilities
- `settings`: Admin settings UI gains a retention policy management table

## Impact

- **Prisma schema**: New `DataRetentionPolicy` model; ChatLog model field change (`isDeleted` → `deletedAt`)
- **MongoDB migration**: Script to convert ChatLog documents from `isDeleted` to `deletedAt`
- **API**: New CRUD endpoints for retention policies; modified ChatLog queries; cascade logic on Course/Group/ChatSpace delete
- **Admin UI**: New retention policy table in settings page
- **Background jobs**: New cron-based cleanup job (likely node-cron or similar)
- **Breaking**: ChatLog `isDeleted` field removed; any code querying it must update to `deletedAt`
