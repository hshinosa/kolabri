## ADDED Requirements

### Requirement: Consent record model
The system SHALL maintain a ConsentRecord model with fields: id, userId, consentType, granted (boolean), grantedAt, revokedAt, createdAt, updatedAt.

#### Scenario: Consent record structure
- **WHEN** a consent record is created
- **THEN** it contains id, userId, consentType, granted, grantedAt, revokedAt, createdAt, updatedAt

### Requirement: Grant consent
The system SHALL expose POST /api/consent/grant accepting consentType in the body, creating a ConsentRecord with granted=true and grantedAt set to current timestamp.

#### Scenario: Grant consent successfully
- **WHEN** authenticated user sends POST /api/consent/grant with valid consentType
- **THEN** system creates ConsentRecord with granted=true, grantedAt=now, and returns 201 with the record

#### Scenario: Grant already granted consent
- **WHEN** user grants a consentType that is already granted and not revoked
- **THEN** system returns 200 with existing record (no duplicate)

#### Scenario: Invalid consent type
- **WHEN** user grants a consentType not in the allowed list
- **THEN** system returns 400 with validation error

### Requirement: Revoke consent
The system SHALL expose POST /api/consent/revoke accepting consentType, setting granted=false and revokedAt to current timestamp on the active record.

#### Scenario: Revoke consent successfully
- **WHEN** authenticated user sends POST /api/consent/revoke with valid consentType
- **THEN** system sets granted=false, revokedAt=now, and returns 200

#### Scenario: Revoke already revoked consent
- **WHEN** user revokes a consentType that is already revoked
- **THEN** system returns 200 with existing record (idempotent)

### Requirement: List consent records
The system SHALL expose GET /api/consent returning all consent records for the authenticated user, including current state and history.

#### Scenario: List consent records
- **WHEN** authenticated user sends GET /api/consent
- **THEN** system returns 200 with array of consent records for that user

#### Scenario: Filter by current state
- **WHEN** user sends GET /api/consent?current=true
- **THEN** system returns only the most recent record per consentType
