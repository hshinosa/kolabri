## ADDED Requirements

### Requirement: Privacy policy endpoint
The system SHALL expose GET /api/privacy/policy returning the current privacy policy as structured JSON with version, lastUpdated, and content fields.

#### Scenario: Fetch privacy policy
- **WHEN** client sends GET /api/privacy/policy
- **THEN** system returns 200 with JSON containing version, lastUpdated date, and policy content

#### Scenario: Unauthenticated access
- **WHEN** unauthenticated client sends GET /api/privacy/policy
- **THEN** system returns 200 with the privacy policy (public endpoint)

### Requirement: Data categories endpoint
The system SHALL expose GET /api/privacy/data-categories returning a list of data categories the system collects, with name, description, purpose, and retentionPeriod fields.

#### Scenario: Fetch data categories
- **WHEN** client sends GET /api/privacy/data-categories
- **THEN** system returns 200 with array of data categories including name, description, purpose, and retentionPeriod

#### Scenario: Categories reflect actual data model
- **WHEN** client fetches data categories
- **THEN** response includes categories for: account data, journal entries, AI chat history, reflections, goals, audit logs, and usage analytics
