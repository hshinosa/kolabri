## Why

Kolabri handles personal journal entries, AI chat history, and user reflections but lacks basic data privacy controls required by NFR-SEC-02. Users have no way to view what data is collected, grant or revoke consent, export their data, or understand the privacy policy. Account deletion exists but doesn't cascade to associated records, leaving orphaned sensitive data in the system.

## What Changes

- Add privacy policy and data category transparency endpoints
- Add consent tracking model and endpoints (accept, revoke, list)
- Add user data export (JSON zip bundle, async, rate limited)
- Add cascade delete/anonymize on account deletion (anonymize chat, delete AI chats/goals/reflections, keep audit log, 30-day hard delete schedule)
- Add privacy preferences (analyticsVisibility, aiInteractionConsent, dataSharingConsent)

## Capabilities

### New Capabilities
- `privacy-policy`: Transparency endpoints for privacy policy and data categories
- `consent-tracking`: Consent record model and CRUD endpoints for user consent management
- `data-export`: Async user data export as JSON zip bundle with rate limiting
- `cascade-delete`: Cascade anonymize/delete on account deletion with 30-day hard delete schedule
- `privacy-preferences`: User privacy preference fields (analyticsVisibility, aiInteractionConsent, dataSharingConsent)

### Modified Capabilities
- `settings`: Adding privacy preference fields to user settings

## Impact

- **API**: 8+ new endpoints across /api/privacy/*, /api/user/data-export, /api/user/account
- **Database**: New ConsentRecord model, new privacy preference columns on User/Settings
- **Dependencies**: Possible archiver library for zip generation, job queue for async export
- **Existing code**: Account deletion flow needs cascade logic, settings model needs privacy fields
