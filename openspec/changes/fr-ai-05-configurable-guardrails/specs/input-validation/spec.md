## ADDED Requirements

### Requirement: Guardrail configuration inputs must be validated consistently
The system SHALL validate course guardrail configuration payloads and reject unsupported or contradictory policy values.

#### Scenario: Invalid guardrail policy is rejected
- **WHEN** a lecturer submits a guardrail configuration with unsupported values or contradictory actions
- **THEN** the system rejects the request with structured validation errors
