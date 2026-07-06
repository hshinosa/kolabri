## ADDED Requirements

### Requirement: ChatLog deletedAt field
The ChatLog Mongoose schema SHALL replace the `isDeleted: boolean` field with `deletedAt: Date | null`. All queries that previously checked `isDeleted` SHALL check `deletedAt` instead.

#### Scenario: New soft delete
- **WHEN** a ChatLog message is soft-deleted
- **THEN** the `deletedAt` field is set to the current timestamp and `isDeleted` is no longer used

#### Scenario: Query soft-deleted messages
- **WHEN** the system queries for non-deleted ChatLog messages
- **THEN** it filters by `deletedAt: null` instead of `isDeleted: false`

### Requirement: ChatLog migration script
The system SHALL provide a migration script that converts existing ChatLog documents from `isDeleted: true` to `deletedAt: <current date>` and removes the `isDeleted` field.

#### Scenario: Migrate deleted documents
- **WHEN** the migration script encounters a ChatLog document with `isDeleted: true`
- **THEN** it sets `deletedAt` to the current date and removes the `isDeleted` field

#### Scenario: Migrate non-deleted documents
- **WHEN** the migration script encounters a ChatLog document with `isDeleted: false` or no `isDeleted` field
- **THEN** it sets `deletedAt` to `null` and removes the `isDeleted` field

#### Scenario: Dry run mode
- **WHEN** the migration script is run with `--dry-run` flag
- **THEN** it logs the changes it would make without actually modifying any documents

### Requirement: Backward compatibility period
During the migration, the system SHALL support both `isDeleted` and `deletedAt` in queries for one release cycle. After migration is confirmed complete, `isDeleted` support SHALL be removed.

#### Scenario: Transitional query
- **WHEN** the system queries ChatLog during the transition period
- **THEN** it checks both `isDeleted` and `deletedAt` to handle unmigrated documents
