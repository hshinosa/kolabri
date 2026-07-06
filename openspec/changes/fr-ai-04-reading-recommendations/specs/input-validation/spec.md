## ADDED Requirements

### Requirement: Reading recommendation requests must be validated before processing
The system SHALL validate recommendation request inputs and reject malformed or incomplete requests before retrieval begins.

#### Scenario: Invalid recommendation request is rejected
- **WHEN** a client submits a recommendation request with missing course context or invalid topic input
- **THEN** the system rejects the request with structured validation errors

#### Scenario: Unsupported source scope is rejected
- **WHEN** a client requests recommendations from a source scope not allowed by system policy
- **THEN** the system rejects the request with an actionable validation response
