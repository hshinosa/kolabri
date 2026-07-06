## Context

Kolabri uses Prisma (PostgreSQL) for relational data and MongoDB (Mongoose) for ChatLog. Five models have soft delete via `deletedAt: DateTime?`: User, Course, Group, ChatSpace, KnowledgeBase. ChatLog uses `isDeleted: boolean` instead, breaking the pattern. No automated cleanup exists; soft-deleted records persist forever. The OpenSpec spec for Course specifies cascade behavior (Course → Group → ChatSpace) but it is not implemented.

## Goals / Non-Goals

**Goals:**
- Unify soft delete pattern across all models (ChatLog adopts `deletedAt`)
- Provide configurable retention periods per data type
- Automate archival and purging of expired soft-deleted data
- Implement soft delete cascade for the Course → Group → ChatSpace → KnowledgeBase chain
- Give admins a UI to manage retention policies

**Non-Goals:**
- Hard delete cascade (permanent delete still removes one entity at a time)
- Per-user or per-tenant retention policies (system-wide only for now)
- Retention for audit logs or system logs (separate concern)
- Real-time event streaming on purge (no webhook/event bus)

## Decisions

### 1. ChatLog migration: `isDeleted` → `deletedAt`

**Decision**: Add `deletedAt` field to ChatLog Mongoose schema, migrate existing `isDeleted: true` docs to set `deletedAt = now`, then remove `isDeleted`.

**Alternatives considered**:
- Keep both fields: Adds query complexity, no real benefit.
- Use a MongoDB TTL index on `deletedAt`: TTL indexes only work on Date fields and delete immediately, no archive window. Not flexible enough.

**Rationale**: Consistency with the rest of the codebase. All soft-delete queries use the same `deletedAt != null` pattern.

### 2. Retention policy storage: Prisma model

**Decision**: New `DataRetentionPolicy` Prisma model with fields: `id`, `dataType` (enum), `retentionDays`, `archiveAfterDays`, `autoPurge` (boolean), `createdAt`, `updatedAt`.

**Alternatives considered**:
- JSON config file: No admin UI, no audit trail, harder to change at runtime.
- Environment variables: Same drawbacks, plus no per-data-type granularity.

**Rationale**: Prisma model gives CRUD API for free, supports admin UI, and persists across deploys.

### 3. Cleanup job: node-cron in the Next.js API layer

**Decision**: Use `node-cron` to run a daily cleanup job within the Next.js server process. The job queries policies, finds expired soft-deleted records, archives (if `archiveAfterDays` met), then purges (if `retentionDays` met and `autoPurge` true).

**Alternatives considered**:
- External cron (systemd, k8s cronjob): Requires separate infra, overkill for current scale.
- Bull/BullMQ job queue: Adds Redis dependency, unnecessary for a simple daily job.
- Vercel Cron: Platform-specific, Kolabri may not deploy on Vercel.

**Rationale**: node-cron is zero-dependency (beyond the package), runs in-process, and matches Kolabri's current architecture (Next.js monolith).

### 4. Soft delete cascade: application-level transaction

**Decision**: When a Course is soft-deleted, a Prisma transaction sets `deletedAt` on all associated Groups, ChatSpaces, and KnowledgeBases. Same for Group → ChatSpace → KnowledgeBase.

**Alternatives considered**:
- Database-level cascade: Prisma doesn't support `ON UPDATE` cascade for arbitrary fields, only `onDelete`.
- Event-driven cascade: Over-engineered for the current scale.

**Rationale**: Prisma interactive transactions give atomicity and are easy to reason about. The cascade chain is short and well-defined.

### 5. Admin UI: table in existing settings page

**Decision**: Add a "Data Retention" tab to the admin settings page with a table of policies and inline edit/create/delete.

**Rationale**: Reuses existing layout, no new routes needed.

## Risks / Trade-offs

- **ChatLog migration failure** → Migration script runs in a try/catch with dry-run mode. Rollback: re-add `isDeleted` field, revert code.
- **Cleanup job purges data too aggressively** → `autoPurge` defaults to `false`. Admin must explicitly enable. First run logs what *would* be purged before actually purging.
- **Cascade performance on large datasets** → Batch updates in chunks of 500 within the transaction. Add timeout guard.
- **node-cron job lost on server restart** → Job is idempotent (checks `deletedAt` timestamps). Missed runs just delay cleanup by one cycle. No data loss.
- **No undo for purge** → Purged data is gone. Mitigation: archive step runs first, soft-deleted data sits in "archived" state for `archiveAfterDays` before purge window opens.
- **ChatLog schema coordination (BREAKING)**: This change replaces `isDeleted` with `deletedAt` on ChatLog (MongoDB). This is a BREAKING change that affects all ChatLog queries. Other changes also modify ChatLog: nfr-mnt-02 adds 6 nullable fields, nfr-reliability-02 adds `version`, nfr-usability-04 adds `isRelevant`. **This migration MUST run first** before the additive fields from other changes, because removing `isDeleted` and adding `deletedAt` is a structural change that all subsequent queries depend on. The consolidated migration order is: (1) DATA-01: `isDeleted` → `deletedAt`, (2) MNT-02 + RELIABILITY-02 + USABILITY-04: add their respective fields.
