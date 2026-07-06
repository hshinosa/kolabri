## ADDED Requirements

### Requirement: Scheduled cleanup execution
The system SHALL run a cleanup job daily at a configurable time (default: 02:00 UTC) using node-cron. The job SHALL be idempotent and safe to re-run.

#### Scenario: Daily job triggers
- **WHEN** the scheduled time is reached
- **THEN** the cleanup job queries all DataRetentionPolicy records and processes each dataType

#### Scenario: Job runs after server restart
- **WHEN** the server restarts and the next scheduled time arrives
- **THEN** the job runs normally, processing any records that would have been processed in missed cycles

### Requirement: Archive phase
The cleanup job SHALL archive soft-deleted records that have been deleted for longer than `archiveAfterDays`. Archiving means the record remains in the database but is marked as archived (no schema change, just a logical state based on `deletedAt` age).

#### Scenario: Record archived
- **WHEN** a soft-deleted Course has `deletedAt` older than `archiveAfterDays` for its policy
- **THEN** the system logs the archival event with the record ID and dataType

#### Scenario: Record not yet eligible
- **WHEN** a soft-deleted Course has `deletedAt` newer than `archiveAfterDays`
- **THEN** the system skips the record

### Requirement: Purge phase
The cleanup job SHALL permanently delete soft-deleted records that have been deleted for longer than `retentionDays` AND whose policy has `autoPurge: true`. Records with `autoPurge: false` SHALL NOT be purged.

#### Scenario: Auto-purge enabled
- **WHEN** a soft-deleted User has `deletedAt` older than `retentionDays` and `autoPurge` is `true`
- **THEN** the system permanently deletes the record from the database

#### Scenario: Auto-purge disabled
- **WHEN** a soft-deleted User has `deletedAt` older than `retentionDays` and `autoPurge` is `false`
- **THEN** the system skips the record and logs a warning that manual purge is needed

#### Scenario: ChatLog purge
- **WHEN** a soft-deleted ChatLog has `deletedAt` older than `retentionDays` and `autoPurge` is `true`
- **THEN** the system permanently deletes the MongoDB document

### Requirement: Cleanup logging
The cleanup job SHALL log each action (archive, purge, skip) with the dataType, record ID, and action taken. Logs SHALL be accessible via the application's standard logging mechanism.

#### Scenario: Job completes
- **WHEN** the cleanup job finishes processing all data types
- **THEN** a summary log is emitted with counts: archived, purged, skipped, errors
