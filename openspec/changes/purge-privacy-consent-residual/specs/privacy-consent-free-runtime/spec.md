## ADDED Requirements

### Requirement: No product privacy or consent HTTP surfaces
Core API and Client App BFF SHALL NOT serve privacy-policy, privacy-preferences, consent grant/revoke/list, or user personal-data export portability endpoints as product features.

#### Scenario: Removed privacy paths unhandled by app
- **WHEN** a client requests `/api/privacy/policy`, `/api/user/privacy-preferences`, or `/api/consent/*` (or equivalent)
- **THEN** no active application route module is registered for that product behavior

#### Scenario: Wayfinder has no privacy proxy exports
- **WHEN** Client App route generation is refreshed after proxy cleanup
- **THEN** generated JS/TS route helpers do not export privacyPolicy / privacyPreferences product actions

### Requirement: No product privacy settings UI
Client App settings SHALL NOT render a privacy preferences tab, consent management UI, retention-policy product tab, or privacy-only data export control.

#### Scenario: Settings open without privacy tab
- **WHEN** an authenticated user opens Settings
- **THEN** available tabs exclude Privacy and Retention Policy product UIs removed by this change

### Requirement: No consent persistence in active schema
Active Prisma schema SHALL NOT define `ConsentRecord` / `consent_records` or user fields `aiInteractionConsent`, `dataSharingConsent`, `analyticsVisibility` (mapped privacy columns).

#### Scenario: Schema validate without consent models
- **WHEN** `prisma validate` runs on Core API
- **THEN** validation succeeds without those models/fields in schema

### Requirement: AI and discussion do not require consent flags
Socket and HTTP AI interactions SHALL NOT deny access solely because a privacy-consent boolean is false or absent.

#### Scenario: AI interaction without consent flag
- **WHEN** an authenticated entitled user triggers AI facilitation or AI personal chat
- **THEN** authorization does not read a user consent privacy flag to allow/deny

### Requirement: Operational admin deletion preserved
Admin hard-delete of user data for operational purposes SHALL remain available.

#### Scenario: Admin hard-delete still callable
- **WHEN** an admin invokes documented admin user hard-delete
- **THEN** the operation remains available and is not rebranded as end-user privacy rights UI

### Requirement: OAuth provider consent prompt preserved
Google OAuth integration SHALL keep provider `prompt=consent` if required for account linking.

#### Scenario: OAuth URL still includes provider consent prompt
- **WHEN** Google OAuth authorization URL is built
- **THEN** `prompt=consent` may still appear as OAuth protocol parameter

### Requirement: Course analytics export not confused with privacy portability
Lecturer course analytics export endpoints that implement FR-028 SHALL remain if they export course/group metrics and not a user privacy data-package.

#### Scenario: Distinguish export types during cleanup
- **WHEN** implementer classifies export modules
- **THEN** only user privacy portability (`ExportJob` user dump, student “download all my data”) is removed unless inventory proves dual use
