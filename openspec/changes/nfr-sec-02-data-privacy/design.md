## Context

Kolabri is a journaling app with AI chat features. Current state: soft delete on account exists (DELETE /api/user/account), hard delete for admins (DELETE /api/admin/users/:id/hard). No consent tracking, no privacy policy endpoint, no data export, no privacy preferences, no cascade on delete. Audit log already redacts sensitive fields.

## Goals / Non-Goals

**Goals:**
- Provide transparency: users can read privacy policy and see what data categories exist
- Enable consent management: users can grant/revoke consent for specific data processing
- Enable data portability: users can export all their data as a JSON zip bundle
- Ensure clean deletion: account deletion cascades to anonymize/delete related records
- Add privacy preference controls: analytics visibility, AI interaction consent, data sharing consent

**Non-Goals:**
- GDPR/CCPA legal compliance certification (this is a technical foundation, not legal review)
- Right-to-rectification endpoint (users can already edit their data)
- Data Processing Impact Assessment (DPIA) automation
- Multi-tenant privacy isolation (single tenant app)

## Decisions

### 1. ConsentRecord as separate model vs. embedded in User

**Decision**: Separate ConsentRecord model with userId, consentType, granted, grantedAt, revokedAt fields.

**Rationale**: Consent is temporal and auditable. A separate model preserves full history (grant/revoke cycles), supports querying current state, and keeps User model clean. Embedding would lose history and make auditing harder.

**Alternatives**: JSON column on User (loses queryability, no history), event sourcing (overkill for this scope).

### 2. Async data export with job queue vs. synchronous generation

**Decision**: POST /api/user/data-export triggers async job, returns 202 with job ID. User downloads when ready. Uses a shared `ExportJob` model (with `exportType` discriminator) that is also used by nfr-data-02 for course data exports.

**Rationale**: Export bundles can be large (journal entries + AI chats + reflections). Synchronous generation would timeout and block the event loop. Job queue pattern fits existing architecture. Sharing the ExportJob model with nfr-data-02 avoids duplicate infrastructure.

**Alternatives**: Synchronous with streaming (complex, poor UX for large exports), pre-generated snapshots (stale data), separate job models per export type (duplicated infrastructure).

### 3. Cascade strategy: anonymize chat, delete AI data, keep audit log

**Decision**: On account deletion, anonymize user chat messages (replace PII with "[REDACTED]"), delete AI chat sessions/goals/reflections, retain audit log entries, schedule hard delete after 30 days.

**Rationale**: Chat messages may be referenced in shared contexts, so anonymization preserves referential integrity while removing PII. AI-generated content has no shared references and can be fully deleted. Audit logs must be retained for security compliance. 30-day window allows recovery from accidental deletion.

**Alternatives**: Full immediate delete (breaks referential integrity, no recovery window), full anonymization only (leaves unnecessary data).

### 4. Privacy preferences as columns on existing Settings model

**Decision**: Add analyticsVisibility, aiInteractionConsent, dataSharingConsent boolean columns to existing Settings/UserPreferences model.

**Rationale**: Privacy preferences are user settings. Extending the existing model avoids a new table and keeps the settings API consistent. These are simple boolean flags, not complex consent records.

**Alternatives**: Separate PrivacyPreferences model (unnecessary indirection for 3 booleans), JSON column (loses type safety).

### 5. Privacy policy as static endpoint vs. CMS-managed

**Decision**: Static endpoint returning markdown/JSON from config file. Data categories endpoint returns structured JSON.

**Rationale**: Privacy policy changes are infrequent and should be version-controlled with the app. CMS adds complexity and a dependency. Data categories are derived from the codebase structure and should be maintained by developers.

**Alternatives**: Database-stored policy (adds admin UI complexity), external CMS (deployment dependency).

## Risks / Trade-offs

- **Export contains sensitive data** → Rate limit to 1 export per 24h, zip encrypted with user's password hash derivative, auto-expire download after 48h
- **Consent revocation breaks features** → Check consent before AI interactions, graceful degradation with user notification
- **30-day hard delete window** → Admin can force immediate hard delete; scheduled job must be idempotent
- **Anonymization incomplete** → Use structured anonymization map per model, test with PII detection
- **Migration: existing users have no consent records** → Default consent state is "not granted", prompt on next login
- **Scope and execution order**: This change has 27 tasks across 5 sections. Recommended execution split: **Phase A** (sections 1, 2, 5 = privacy policy + consent + preferences, ~12 tasks) ships independently as it has no cross-dependencies. **Phase B** (sections 3, 4 = data export + cascade delete, ~15 tasks) is heavier and depends on the ExportJob model (shared with nfr-data-02). Phase A can be implemented and tested before Phase B starts.
