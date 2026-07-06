## ADDED Requirements

### Requirement: Lecturers shall configure AI guardrail policy per course
The system SHALL allow a lecturer to define AI guardrail behavior for a specific course using supported policy controls.

#### Scenario: Lecturer saves valid guardrail policy
- **WHEN** a lecturer submits a supported guardrail configuration for a course
- **THEN** the system saves the policy and applies it to future AI interactions in that course

### Requirement: AI requests must enforce the active course guardrail policy
The system SHALL evaluate AI requests and responses against the active guardrail policy for the course before returning results to users.

#### Scenario: Guardrail policy blocks a request or response
- **WHEN** an AI interaction violates the configured guardrail policy for the course
- **THEN** the system blocks, rewrites, or flags the interaction according to the configured policy outcome

### Requirement: Guardrail outcomes must be auditable and understandable
The system SHALL record guardrail decisions and present understandable feedback when a guardrail policy changes the user-visible outcome.

#### Scenario: User receives policy-aware feedback
- **WHEN** an AI interaction is blocked or modified by guardrails
- **THEN** the system provides feedback that explains the interaction was limited by course AI safety policy

#### Scenario: Audit log stores guardrail decision
- **WHEN** a guardrail policy is triggered
- **THEN** the system stores structured audit metadata describing the triggered rule and resulting action
