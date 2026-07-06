## ADDED Requirements

### Requirement: All API endpoints MUST validate request bodies using Zod schemas

The system SHALL validate all incoming request bodies against defined Zod schemas before processing. Controllers SHALL NOT access `req.body` directly without prior schema validation.

#### Scenario: Valid request passes validation
- **WHEN** client sends request with valid body matching schema
- **THEN** request proceeds to controller logic

#### Scenario: Invalid request rejected with 400
- **WHEN** client sends request with invalid body (missing required fields, wrong types, out-of-range values)
- **THEN** system returns 400 Bad Request with detailed validation errors

#### Scenario: Validation middleware applied to all routes
- **WHEN** new route is added to API
- **THEN** route MUST include validation middleware before controller handler

### Requirement: Schema validation MUST cover all input fields

Validation schemas SHALL define constraints for all expected input fields including type, format, length, range, and pattern requirements.

#### Scenario: String length validated
- **WHEN** schema defines maxLength constraint
- **THEN** requests exceeding length limit are rejected

#### Scenario: Numeric range validated
- **WHEN** schema defines min/max constraints
- **THEN** requests outside range are rejected

#### Scenario: Enum values validated
- **WHEN** schema defines allowed values
- **THEN** requests with invalid values are rejected

### Requirement: Validation errors MUST provide actionable feedback

Error responses SHALL include field-level error messages indicating which fields failed validation and why.

#### Scenario: Multiple validation errors returned
- **WHEN** request has multiple invalid fields
- **THEN** response includes all validation errors in structured format

#### Scenario: Error messages are user-friendly
- **WHEN** validation fails
- **THEN** error messages describe the constraint violation clearly (e.g., "title must be between 1 and 100 characters")
