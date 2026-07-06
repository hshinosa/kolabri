## ADDED Requirements

### Requirement: Cascade anonymize on account deletion
When a user deletes their account, the system SHALL anonymize user-authored chat messages by replacing PII fields with "[REDACTED]".

#### Scenario: Chat messages anonymized
- **WHEN** user account is soft-deleted
- **THEN** all chat messages authored by the user have content replaced with "[REDACTED]" and username set to "Deleted User"

#### Scenario: Referential integrity preserved
- **WHEN** chat messages are anonymized
- **THEN** message records remain with original IDs so conversation threads stay intact

### Requirement: Delete AI-generated content on account deletion
The system SHALL delete AI chat sessions, AI-generated messages, goals, and reflections owned by the deleted user.

#### Scenario: AI data deleted
- **WHEN** user account is soft-deleted
- **THEN** all AI chat sessions, AI messages, goals, and reflections for that user are hard-deleted immediately

### Requirement: Retain audit log on account deletion
The system SHALL retain audit log entries for deleted users. Audit entries SHALL reference the user by ID only, not by name or PII.

#### Scenario: Audit log preserved
- **WHEN** user account is soft-deleted
- **THEN** audit log entries for that userId remain in the database

#### Scenario: Audit log has no PII
- **WHEN** audit log entries are queried for a deleted user
- **THEN** entries contain userId but no user name, email, or other PII

### Requirement: 30-day hard delete schedule
The system SHALL schedule a hard delete of all remaining user data (anonymized messages, user record) 30 days after soft deletion.

#### Scenario: Hard delete after 30 days
- **WHEN** 30 days have passed since account soft-deletion
- **THEN** system permanently deletes the user record and all remaining associated data

#### Scenario: Account recovery before 30 days
- **WHEN** user requests account recovery within 30 days of deletion
- **THEN** system restores the account and cancels the scheduled hard delete

### Requirement: Admin force hard delete
The system SHALL allow admins to force immediate hard deletion via DELETE /api/admin/users/:id/hard, bypassing the 30-day window.

#### Scenario: Admin force delete
- **WHEN** admin sends DELETE /api/admin/users/:id/hard
- **THEN** system immediately and permanently deletes all user data
