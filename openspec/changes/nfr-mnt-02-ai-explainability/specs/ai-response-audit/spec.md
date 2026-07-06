## ADDED Requirements

### Requirement: Audit log for all AI responses
The system SHALL create an audit log entry of type `ai_response_generated` for every AI response, including responses with no guardrail trigger. The entry SHALL contain all metadata fields from the orchestration result.

#### Scenario: AI response with guardrail trigger
- **WHEN** the AI Engine returns a response that triggered a guardrail
- **THEN** the system SHALL create both an `ai_response_generated` audit entry and the existing `guardrail_triggered` entry, each with the full metadata

#### Scenario: AI response with no guardrail trigger
- **WHEN** the AI Engine returns a normal response with no guardrail intervention
- **THEN** the system SHALL create an `ai_response_generated` audit entry containing the response metadata (scaffoldingLevel, qualityScore, and null guardrail fields)

### Requirement: Audit entry metadata format
Each `ai_response_generated` audit entry SHALL include: sessionId, chatLogId, guardrailReason, guardrailOutcome, interventionType, interventionReason, scaffoldingLevel, qualityScore, and timestamp.

#### Scenario: Audit entry structure
- **WHEN** an `ai_response_generated` audit entry is created
- **THEN** it SHALL contain all specified fields and the timestamp SHALL be the server time at response generation

### Requirement: Audit entries are queryable by session
The system SHALL support querying audit entries by sessionId to retrieve the full AI response history for a session.

#### Scenario: Query audit log for a session
- **WHEN** a lecturer queries audit entries for session "abc-123"
- **THEN** the system SHALL return all `ai_response_generated` entries for that session in chronological order
