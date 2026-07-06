## ADDED Requirements

### Requirement: Course soft delete cascade
When a Course is soft-deleted, the system SHALL soft-delete all associated Groups, ChatSpaces, and KnowledgeBases within the same Prisma transaction.

#### Scenario: Course soft delete cascades
- **WHEN** a Course with `deletedAt` set to current timestamp
- **THEN** all Groups belonging to that Course get `deletedAt` set to the same timestamp, and all ChatSpaces and KnowledgeBases belonging to those Groups also get `deletedAt` set to the same timestamp

#### Scenario: Course with no children
- **WHEN** a Course with no associated Groups is soft-deleted
- **THEN** only the Course's `deletedAt` is set, no cascade needed

### Requirement: Group soft delete cascade
When a Group is soft-deleted, the system SHALL soft-delete all associated ChatSpaces and KnowledgeBases within the same Prisma transaction.

#### Scenario: Group soft delete cascades
- **WHEN** a Group's `deletedAt` is set
- **THEN** all ChatSpaces and KnowledgeBases belonging to that Group get `deletedAt` set to the same timestamp

### Requirement: Cascade restore
When a Course is restored (deletedAt set to null), the system SHALL restore all associated Groups, ChatSpaces, and KnowledgeBases that were soft-deleted at the same timestamp.

#### Scenario: Course restore cascades
- **WHEN** a Course's `deletedAt` is set to null (restore)
- **THEN** all Groups, ChatSpaces, and KnowledgeBases that have `deletedAt` matching the Course's previous `deletedAt` value are also restored (deletedAt set to null)

#### Scenario: Partial restore not allowed
- **WHEN** a Group is restored but its parent Course is still soft-deleted
- **THEN** the system SHALL reject the restore with an error indicating the parent Course must be restored first

### Requirement: Cascade batch limit
The cascade operation SHALL process child records in batches of 500 to avoid transaction timeouts on large datasets.

#### Scenario: Large course cascade
- **WHEN** a Course has more than 500 associated child records
- **THEN** the cascade processes them in batches of 500 within the same transaction, and all batches complete before the transaction commits
