## ADDED Requirements

### Requirement: DataRetentionPolicy model
The system SHALL provide a `DataRetentionPolicy` Prisma model with the following fields: `id` (auto-increment int), `dataType` (enum: USER, COURSE, GROUP, CHAT_SPACE, KNOWLEDGE_BASE, CHAT_LOG), `retentionDays` (int, days before purge), `archiveAfterDays` (int, days after soft delete before archiving), `autoPurge` (boolean, default false), `createdAt` (DateTime), `updatedAt` (DateTime).

#### Scenario: Policy created with defaults
- **WHEN** a new DataRetentionPolicy is created with only `dataType` and `retentionDays`
- **THEN** `archiveAfterDays` defaults to half of `retentionDays`, `autoPurge` defaults to `false`, and `createdAt`/`updatedAt` are set automatically

#### Scenario: Duplicate dataType rejected
- **WHEN** a DataRetentionPolicy is created with a `dataType` that already has a policy
- **THEN** the system SHALL reject the creation with a unique constraint error

### Requirement: Policy CRUD API
The system SHALL expose REST API endpoints for managing retention policies: GET (list), POST (create), PUT (update), DELETE (delete). All endpoints SHALL require admin authentication.

#### Scenario: Admin lists policies
- **WHEN** an admin sends GET /api/retention-policies
- **THEN** the system returns all DataRetentionPolicy records sorted by dataType

#### Scenario: Non-admin rejected
- **WHEN** a non-admin user sends any request to /api/retention-policies
- **THEN** the system returns 403 Forbidden

#### Scenario: Admin updates policy
- **WHEN** an admin sends PUT /api/retention-policies/:id with updated `retentionDays`
- **THEN** the policy is updated and `updatedAt` is refreshed

### Requirement: Policy seeding
The system SHALL seed default retention policies on first run if no policies exist. Default: each dataType gets `retentionDays: 365`, `archiveAfterDays: 180`, `autoPurge: false`.

#### Scenario: First run seeding
- **WHEN** the application starts and the DataRetentionPolicy table is empty
- **THEN** one policy per dataType is created with default values
