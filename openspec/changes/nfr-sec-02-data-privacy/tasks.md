## Status (P0)

Gate: `docs/p0-release-gate.md`. Bagian export/consent/cascade penuh = P1+.

## 1. Privacy Policy Endpoints

- [x] 1.1 Privacy policy config / content source
- [x] 1.2 GET /api/privacy/policy
- [ ] 1.3 GET /api/privacy/data-categories (P1 if not in smoke)
- [ ] 1.4 Dedicated tests for both endpoints (partial via integration/smoke)

## 2. Consent Tracking

- [ ] 2.1 Create ConsentRecord model (id, userId, consentType, granted, grantedAt, revokedAt, createdAt, updatedAt)
- [ ] 2.2 Run migration for consent_records table
- [ ] 2.3 Implement POST /api/consent/grant with idempotent handling and consentType validation
- [ ] 2.4 Implement POST /api/consent/revoke with idempotent handling
- [ ] 2.5 Implement GET /api/consent with optional ?current=true filter
- [ ] 2.6 Add tests for grant, revoke, list, duplicate handling, and invalid consentType

## 3. User Data Export

- [ ] 3.1 Create ExportJob model (id, userId, exportType [USER_DATA|COURSE_DATA], courseId nullable, status, createdAt, completedAt, filePath) — shared with nfr-data-02
- [ ] 3.2 Implement POST /api/user/data-export (async, returns 202 with jobId, 409 if pending job exists for same userId+exportType)
- [ ] 3.3 Add 24h rate limiting per user for export requests
- [ ] 3.4 Implement export job worker: bundle profile, journals, AI chats, reflections, goals, consent records, privacy preferences into JSON zip
- [ ] 3.5 Implement GET /api/user/data-export/:jobId (200 with zip if complete, 202 if processing, 410 if expired)
- [ ] 3.6 Add 48h auto-expiry cleanup for export files (scheduled job or TTL)
- [ ] 3.7 Add tests for export flow, rate limiting, expiry, and concurrent request handling

## 4. Cascade Delete on Account Deletion

- [ ] 4.1 Update account deletion handler: anonymize user chat messages (content → "[REDACTED]", username → "Deleted User")
- [ ] 4.2 Add hard delete for AI chat sessions, AI messages, goals, and reflections on account deletion
- [ ] 4.3 Verify audit log entries are retained (no PII in audit entries for deleted users)
- [ ] 4.4 Implement 30-day scheduled hard delete job for remaining user data
- [ ] 4.5 Implement account recovery within 30-day window (cancel scheduled hard delete, restore account)
- [ ] 4.6 Verify admin force hard delete (DELETE /api/admin/users/:id/hard) bypasses 30-day window
- [ ] 4.7 Add tests for cascade anonymization, AI data deletion, audit log retention, 30-day schedule, and recovery

## 5. Privacy Preferences (P0)

- [x] 5.1–5.2 Preference fields on user/settings model
- [x] 5.3 PUT /api/user/privacy-preferences
- [x] 5.4 GET /api/user/privacy-preferences (smoke + BFF)
- [ ] 5.5 AI chat 403 without aiInteractionConsent — verify / test (P0 manual or P1 test)
- [x] 5.6 Privacy tab (`PrivacyTab.tsx`, Settings)
- [ ] 5.7 Full test matrix for preferences + consent gate
