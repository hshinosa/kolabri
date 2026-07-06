## 1. ChatLog Delete Pattern Standardization

- [ ] 1.1 Add `deletedAt: Date | null` field to ChatLog Mongoose schema (default null)
- [ ] 1.2 Update all ChatLog queries to use `deletedAt` instead of `isDeleted` (find, aggregate, count)
- [ ] 1.3 Update ChatLog soft-delete logic to set `deletedAt = new Date()` instead of `isDeleted = true`
- [ ] 1.4 Write MongoDB migration script: convert `isDeleted: true` → `deletedAt: <now>`, remove `isDeleted` field
- [ ] 1.5 Add `--dry-run` flag to migration script that logs changes without applying
- [ ] 1.6 Add backward-compatible query support (check both `isDeleted` and `deletedAt`) for transition period
- [ ] 1.7 Remove `isDeleted` field from Mongoose schema and backward-compat queries after migration confirmed

## 2. Retention Policy Model & API

- [ ] 2.1 Add `DataType` enum to Prisma schema (USER, COURSE, GROUP, CHAT_SPACE, KNOWLEDGE_BASE, CHAT_LOG)
- [ ] 2.2 Add `DataRetentionPolicy` model to Prisma schema with all fields per spec
- [ ] 2.3 Run `npx prisma migrate dev` to create the migration
- [ ] 2.4 Create seed script for default policies (one per dataType, retentionDays: 365, archiveAfterDays: 180, autoPurge: false)
- [ ] 2.5 Create GET /api/retention-policies endpoint (admin-only, returns all policies sorted by dataType)
- [ ] 2.6 Create POST /api/retention-policies endpoint (admin-only, validates unique dataType)
- [ ] 2.7 Create PUT /api/retention-policies/:id endpoint (admin-only, updates policy fields)
- [ ] 2.8 Create DELETE /api/retention-policies/:id endpoint (admin-only, deletes policy)
- [ ] 2.9 Add auth middleware to all retention policy routes (reject non-admin with 403)

## 3. Retention Admin UI

- [ ] 3.1 Add "Retensi Data" tab to settings page tab navigation (admin-only visibility)
- [ ] 3.2 Create retention policy table component with columns: dataType, retentionDays, archiveAfterDays, autoPurge, actions
- [ ] 3.3 Implement inline edit mode for policy rows (input fields replace static text)
- [ ] 3.4 Add "Tambah Kebijakan" button with create flow (select dataType, fill fields)
- [ ] 3.5 Add delete button with confirmation dialog
- [ ] 3.6 Add autoPurge toggle with auto-save (no "Simpan" button needed)
- [ ] 3.7 Add deep link support: /settings?tab=retensi-data

## 4. Scheduled Cleanup Job

- [ ] 4.1 Install node-cron package
- [ ] 4.2 Create cleanup job module with daily schedule (default 02:00 UTC, configurable via env)
- [ ] 4.3 Implement archive phase: query soft-deleted records older than `archiveAfterDays`, log archival events
- [ ] 4.4 Implement purge phase: permanently delete records older than `retentionDays` where `autoPurge: true`
- [ ] 4.5 Add ChatLog purge support (MongoDB deleteMany for records past retention with autoPurge)
- [ ] 4.6 Add skip logic for records where `autoPurge: false` (log warning)
- [ ] 4.7 Add summary logging: archived count, purged count, skipped count, errors
- [ ] 4.8 Register cleanup job on Next.js server startup

## 5. Soft Delete Cascade

- [ ] 5.1 Add cascade logic to Course soft-delete: transactional update of Groups, ChatSpaces, KnowledgeBases
- [ ] 5.2 Add cascade logic to Group soft-delete: transactional update of ChatSpaces, KnowledgeBases
- [ ] 5.3 Add cascade restore logic to Course restore: restore children with matching `deletedAt` timestamp
- [ ] 5.4 Add parent-check guard on Group restore: reject if parent Course is still soft-deleted
- [ ] 5.5 Implement batch processing (chunks of 500) for cascade operations to avoid transaction timeouts
- [ ] 5.6 Add integration tests for cascade: Course delete → Group → ChatSpace → KnowledgeBase chain
- [ ] 5.7 Add integration tests for cascade restore and parent-check rejection
